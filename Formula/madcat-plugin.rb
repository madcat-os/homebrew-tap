class MadcatPlugin < Formula
  desc "Opencode plugin — EEMS memory, indexing, TTS, signal, and more"
  homepage "https://github.com/madcat-os/madcat-plugin"
  license "MIT"
  head "git@github.com:madcat-os/madcat-plugin.git", branch: "sin"
  version "0.1.0"

  depends_on "rust" => :build
  depends_on "opencode"

  resource "madcat-memory" do
    url "git@github.com:madcat-os/madcat-memory.git", branch: "main", using: :git
  end

  def install
    plugins_dir = Pathname.new(Dir.home)/".config"/"opencode"/"plugins"
    plugins_dir.mkpath

    # Build NAPI .node binary from madcat-memory
    resource("madcat-memory").stage do
      system "cargo", "build", "--release", "-p", "madcat-memory-napi"

      if OS.mac?
        napi_lib = "target/release/libmadcat_memory_napi.dylib"
        node_file = "madcat-memory.darwin-arm64.node"
      elsif Hardware::CPU.arm?
        napi_lib = "target/release/libmadcat_memory_napi.so"
        node_file = "madcat-memory.linux-arm64-gnu.node"
      else
        napi_lib = "target/release/libmadcat_memory_napi.so"
        node_file = "madcat-memory.linux-x64-gnu.node"
      end

      # Install .node to libexec and plugin tools dir
      libexec.install napi_lib => node_file
      cp libexec/node_file, buildpath/"src"/"tools"/node_file
    end

    # Install plugin source to libexec
    libexec.install Dir["src/*"]
    libexec.install "package.json" if File.exist?("package.json")

    # Symlink plugin entry point into opencode plugins dir
    (plugins_dir/"madcat-plugin").make_relative_symlink(libexec)
  end

  def caveats
    <<~EOS
      Plugin installed to: ~/.config/opencode/plugins/madcat-plugin
      NAPI binary built for the current platform.

      Restart opencode to pick up the plugin:
        brew services restart opencode-serve
    EOS
  end

  test do
    assert_predicate libexec/"index.ts", :exist?
  end
end
