class MadcatPlugin < Formula
  desc "Opencode plugin — EEMS memory, indexing, TTS, signal, and more"
  homepage "https://github.com/madcat-os/madcat-plugin"
  license "MIT"
  url "ssh://git@github.com/madcat-os/madcat-plugin.git", branch: "sin", using: :git
  version "0.1.0"

  CDN = "https://pub-74d54066bfe6435e908e11e9f3d14482.r2.dev/latest".freeze

  depends_on "opencode"

  if OS.mac? && Hardware::CPU.arm?
    resource "napi" do
      url "#{CDN}/madcat-memory.darwin-arm64.node"
    end
  elsif OS.linux? && Hardware::CPU.arm?
    resource "napi" do
      url "#{CDN}/madcat-memory.linux-arm64-gnu.node"
    end
  else
    resource "napi" do
      url "#{CDN}/madcat-memory.linux-x64-gnu.node"
    end
  end

  def install
    plugins_dir = Pathname.new(Dir.home)/".config"/"opencode"/"plugins"
    plugins_dir.mkpath

    # Determine node file name
    if OS.mac?
      node_file = "madcat-memory.darwin-arm64.node"
    elsif Hardware::CPU.arm?
      node_file = "madcat-memory.linux-arm64-gnu.node"
    else
      node_file = "madcat-memory.linux-x64-gnu.node"
    end

    # Install NAPI binary into plugin tools dir
    resource("napi").stage do
      # The resource is a single binary file downloaded to a temp dir
      napi_bin = Dir["*"].first || Dir[".*"].reject { |f| f.start_with?(".", "..") }.first
      if napi_bin
        cp napi_bin, buildpath/"src"/"tools"/node_file
      end
    end

    # Install plugin source to libexec
    libexec.install Dir["src/*"]
    libexec.install "package.json" if File.exist?("package.json")

    # Symlink into opencode plugins dir
    ln_sf libexec, plugins_dir/"madcat-plugin"
  end

  def caveats
    <<~EOS
      Plugin installed to: ~/.config/opencode/plugins/madcat-plugin
      NAPI binary (prebuilt) for the current platform included.

      Restart opencode to pick up the plugin:
        brew services restart opencode-serve
    EOS
  end

  test do
    assert_predicate libexec/"index.ts", :exist?
  end
end
