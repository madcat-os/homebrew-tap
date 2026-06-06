class MadcatIndex < Formula
  desc "CLI for indexing code and docs into EEMS (Postgres+pgvector)"
  homepage "https://github.com/madcat-os/madcat-memory"
  license "MIT"
  head "git@github.com:madcat-os/madcat-memory.git", branch: "main"
  version "0.1.0"

  depends_on "rust" => :build
  depends_on "pkg-config" => :build

  def install
    # Platform-aware feature flags
    features = "fastembed,postgres"
    if OS.mac? && Hardware::CPU.arm?
      features += ",gpu-metal,gpu-coreml"
    elsif OS.linux? && Hardware::CPU.intel?
      features += ",gpu-cuda"
    end

    system "cargo", "build", "--release",
           "-p", "madcat-index",
           "--no-default-features",
           "--features", features

    bin.install "target/release/madcat-index"
  end

  def caveats
    <<~EOS
      Requires ~/.config/madcat/config.toml with:

        [database]
        backend = "postgres"
        dsn = "postgresql://user:pass@host:5432/eems"

      Usage:
        madcat-index code ~/Projects/myrepo/src --project myrepo
        madcat-index docs ~/Projects/myrepo/docs --project myrepo
        madcat-index clear --type code --repo myrepo
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/madcat-index --version")
  end
end
