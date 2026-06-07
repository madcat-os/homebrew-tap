class MadcatTts < Formula
  desc "TTS daemon — Chatterbox + Piper in-process, XTTS proxied"
  homepage "https://github.com/madcat-os/madcat-tts"
  license "MIT"
  url "https://files.pythonhosted.org/packages/0c/3e/7348a3754cde3e6e7ae7bfaf439e8706906958d0cb5bfc935ff988421d6e/madcat_tts-0.3.0.tar.gz"
  sha256 "3a2c407eb0a7a919b0757f0b639f4536ffa9d7059fbc40656b5566d655af76e8"
  version "0.3.0"

  depends_on "uv"

  def install
    # Create a venv in the Cellar — no dependency on $HOME
    venv = libexec/"venv"
    system "uv", "venv", "--python", "3.11", venv.to_s
    system "uv", "pip", "install",
           "--python", (venv/"bin/python").to_s,
           "madcat-tts==#{version}"

    # Wrapper script that runs from the cellar venv
    (bin/"madcat-tts").write <<~EOS
      #!/bin/bash
      export PYTHONUNBUFFERED=1
      exec "#{venv}/bin/madcat-tts" "$@"
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
    working_dir HOMEBREW_PREFIX
    log_path var/"log/madcat-tts.log"
    error_log_path var/"log/madcat-tts.log"
    environment_variables PATH: "#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin",
                          PYTHONUNBUFFERED: "1",
                          MADCAT_TTS_HOST: "0.0.0.0",
                          MADCAT_TTS_PORT: "14099",
                          MADCAT_TTS_LOG: "info",
                          MADCAT_TTS_XTTS_URL: "http://localhost:8020",
                          MADCAT_TTS_NORMALIZER_URL: "http://localhost:8002"
  end

  def caveats
    <<~EOS
      Installed via `uv pip install` into a Cellar-local venv.

      Start the service:
        brew services start madcat-tts

      Upgrade:
        brew upgrade madcat-tts

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
