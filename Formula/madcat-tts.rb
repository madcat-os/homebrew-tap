class MadcatTts < Formula
  desc "TTS daemon — Chatterbox + Piper in-process, XTTS proxied"
  homepage "https://github.com/madcat-os/madcat-tts"
  license "MIT"
  url "git@github.com:madcat-os/madcat-tts.git", branch: "main", using: :git
  version "0.2.0"

  depends_on "uv"

  def install
    # Install source to libexec
    libexec.install Dir["*"]

    # Create venv via uv
    system "uv", "venv", libexec/".venv", "--python", "3.11"
    system "uv", "pip", "install", "--python", libexec/".venv"/"bin"/"python",
           "-e", libexec.to_s

    # Wrapper script
    (bin/"madcat-tts").write <<~EOS
      #!/bin/bash
      export PYTHONUNBUFFERED=1
      exec #{libexec}/.venv/bin/python -m madcat_tts "$@"
    EOS
    chmod 0755, bin/"madcat-tts"

    # Default env config
    (etc/"madcat").mkpath
    unless (etc/"madcat/tts.env").exist?
      (etc/"madcat/tts.env").write <<~EOS
        # madcat-tts environment — edit then: brew services restart madcat-tts
        MADCAT_TTS_HOST=0.0.0.0
        MADCAT_TTS_PORT=14099
        MADCAT_TTS_LOG=info
        MADCAT_TTS_XTTS_URL=http://localhost:8020
        MADCAT_TTS_NORMALIZER_URL=http://localhost:8002
      EOS
    end
  end

  service do
    run [opt_bin/"madcat-tts"]
    keep_alive true
    working_dir Dir.home
    log_path var/"log/madcat-tts.log"
    error_log_path var/"log/madcat-tts.log"
    environment_variables HOME: Dir.home,
                          PATH: "#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin",
                          PYTHONUNBUFFERED: "1",
                          MADCAT_TTS_HOST: "0.0.0.0",
                          MADCAT_TTS_PORT: "14099",
                          MADCAT_TTS_LOG: "info",
                          MADCAT_TTS_XTTS_URL: "http://localhost:8020",
                          MADCAT_TTS_NORMALIZER_URL: "http://localhost:8002"
  end

  def caveats
    <<~EOS
      Start the service:
        brew services start madcat-tts

      Edit environment:
        #{etc}/madcat/tts.env

      Logs at: #{var}/log/madcat-tts.log

      Requires GPU for Chatterbox engine. Piper works on CPU.
      XTTS engine proxied to MADCAT_TTS_XTTS_URL (default: localhost:8020).
    EOS
  end

  test do
    assert_match "madcat", shell_output("#{bin}/madcat-tts --help 2>&1", 0)
  end
end
