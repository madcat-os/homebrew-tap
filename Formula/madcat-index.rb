class MadcatIndex < Formula
  desc "CLI for indexing code and docs into EEMS (Postgres+pgvector)"
  homepage "https://github.com/madcat-os/madcat-memory"
  license "MIT"
  version "0.1.0"

  CDN = "https://pub-74d54066bfe6435e908e11e9f3d14482.r2.dev/latest".freeze

  if OS.mac? && Hardware::CPU.arm?
    url "#{CDN}/madcat-index-darwin-arm64"
  elsif OS.linux? && Hardware::CPU.arm?
    url "#{CDN}/madcat-index-linux-arm64"
  else
    url "#{CDN}/madcat-index-linux-x64"
  end

  def install
    bin.install Dir["madcat-index-*"].first => "madcat-index"
    chmod 0755, bin/"madcat-index"
  end

  def caveats
    <<~EOS
      Requires ~/.config/madcat/config.toml with:

        [database]
        backend = "postgres"
        dsn = "postgresql://user:pass@host:5432/eems"

      Usage:
        madcat-index code ~/Projects/myrepo/src --project myrepo
        madcat-index clear --type code --repo myrepo
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/madcat-index --version")
  end
end
