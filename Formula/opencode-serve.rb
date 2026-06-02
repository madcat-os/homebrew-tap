class OpencodeServe < Formula
  desc "OpenCode server daemon (API + Web UI)"
  homepage "https://opencode.ai"
  license "MIT"
  head "https://github.com/madcat-os/homebrew-tap.git", branch: "main"
  version "0.1.0"

  # Service wrapper only — assumes opencode is installed via npm/bun
  def install
    (etc/"opencode").mkpath
    (etc/"opencode/serve.env").write <<~EOS
      # Environment for opencode serve daemon
      # Edit this file then: brew services restart opencode-serve
      # Add API keys here (sourced at startup)
    EOS

    (bin/"opencode-serve-wrapper").write <<~EOS
      #!/bin/bash
      # Wrapper for opencode serve daemon
      set -a
      [ -f #{Dir.home}/.credentials ] && . #{Dir.home}/.credentials
      [ -f #{etc}/opencode/serve.env ] && . #{etc}/opencode/serve.env
      set +a
      exec #{HOMEBREW_PREFIX}/bin/opencode serve --port 4096
    EOS
  end

  service do
    run [opt_bin/"opencode-serve-wrapper"]
    keep_alive crashed: true
    working_dir Dir.home
    log_path var/"log/opencode-serve.log"
    error_log_path var/"log/opencode-serve.log"
    environment_variables HOME: Dir.home,
                          PATH: "#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
  end

  def caveats
    <<~EOS
      OpenCode serve will run on http://localhost:4096

      To start the service:
        brew services start opencode-serve

      Logs are at:
        #{var}/log/opencode-serve.log

      API keys can be added to:
        #{etc}/opencode/serve.env
        or ~/.credentials (sourced first)
    EOS
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/opencode", "--version"
  end
end
