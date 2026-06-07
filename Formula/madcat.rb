class Madcat < Formula
  desc "MADCAT platform — memory, indexing, TTS, plugin, opencode serve"
  homepage "https://github.com/madcat-os"
  license "MIT"
  version "0.1.0"
  # No source — meta-formula that pulls in components
  url "https://github.com/madcat-os/homebrew-tap/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "282ceaec7670448a76a34915116033670903a9752f8c25b5059716ed7b2c6495"

  depends_on "opencode"
  depends_on "madcat-os/tap/madcat-index"
  depends_on "madcat-os/tap/madcat-plugin"
  depends_on "madcat-os/tap/opencode-serve"
  depends_on "madcat-os/tap/madcat-tts"

  def install
    # Create config directory
    (etc/"madcat").mkpath

    # Install template config if not present
    unless (etc/"madcat/config.toml").exist?
      (etc/"madcat/config.toml").write <<~EOS
        # MADCAT configuration
        # Copy to ~/.config/madcat/config.toml and edit

        [persona]
        cart = "bt7274"

        [database]
        backend = "postgres"
        dsn = "postgresql://madcat:PASSWORD@HOST:5432/eems?sslmode=disable"

        [embedding]
        url = "local"
      EOS
    end

    # Marker file
    (share/"madcat"/"installed").write "madcat #{version}\n"
  end

  def post_install
    config_dir = Pathname.new(Dir.home)/".config"/"madcat"
    config_dir.mkpath

    unless (config_dir/"config.toml").exist?
      cp etc/"madcat/config.toml", config_dir/"config.toml"
      ohai "Created ~/.config/madcat/config.toml — edit the [database].dsn"
    end
  end

  def caveats
    <<~EOS
      MADCAT platform installed. Next steps:

      1. Edit ~/.config/madcat/config.toml
         Set [database].dsn to your Postgres+pgvector instance.

      2. Start services:
         brew services start opencode-serve
         brew services start madcat-tts

      3. Index your code:
         madcat-index code ~/Projects/myrepo/src --project myrepo

      4. Restart opencode to pick up the plugin:
         brew services restart opencode-serve
    EOS
  end

  test do
    assert_predicate share/"madcat"/"installed", :exist?
  end
end
