class Marauder < Formula
  desc "MARAUDER platform — persona, memory, TTS, MCP server, mesh"
  homepage "https://github.com/marauder-os/marauder-os"
  license "PolyForm-Small-Business-1.0.0"
  head "https://github.com/marauder-os/marauder-os.git", branch: "master"
  version "0.3.0"

  depends_on "rust" => :build
  depends_on "pkg-config" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      The marauder binary requires access to private git dependencies.
      If `brew install --HEAD` fails, build manually:
        cd ~/Projects/marauder-os && cargo install --path . --root #{HOMEBREW_PREFIX}
      Or symlink an existing build:
        ln -sf ~/.local/bin/marauder #{HOMEBREW_PREFIX}/bin/marauder
    EOS
  end

  test do
    assert_match "marauder", shell_output("#{bin}/marauder --version")
  end
end
