class OpencodeServe < Formula
  desc "Brew service for opencode serve"
  homepage "https://opencode.ai"
  license "MIT"
  version "1.0.0"
  # No source — this is a service-only formula
  url "git@github.com:madcat-os/homebrew-tap.git", branch: "main"

  depends_on "opencode"

  def install
    # Wrapper script that sources credentials before exec
    (bin/"opencode-serve").write <<~EOS
      #!/bin/bash
      set -a
      [ -f "$HOME/.credentials" ] && . "$HOME/.credentials"
      set +a
      exec #{HOMEBREW_PREFIX}/bin/opencode serve
    EOS
    chmod 0755, bin/"opencode-serve"
  end

  service do
    run [opt_bin/"opencode-serve"]
    keep_alive true
    working_dir Dir.home
    log_path var/"log/opencode-serve.log"
    error_log_path var/"log/opencode-serve.log"
    environment_variables HOME: Dir.home,
                          PATH: "#{HOMEBREW_PREFIX}/bin:#{Dir.home}/.cargo/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  end

  def caveats
    <<~EOS
      Start the service:
        brew services start opencode-serve

      Logs at: #{var}/log/opencode-serve.log

      Credentials are sourced from ~/.credentials (if present).
      Add API keys and env vars there:
        ANTHROPIC_API_KEY=sk-...
    EOS
  end

  test do
    assert_predicate bin/"opencode-serve", :exist?
  end
end
