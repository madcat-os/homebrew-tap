class MadcatTts < Formula
  desc "TTS daemon — Chatterbox + Piper in-process, XTTS proxied"
  homepage "https://github.com/madcat-os/madcat-tts"
  license "MIT"
  version "0.3.0"

  depends_on "uv"

  def install
    # Install from PyPI into an isolated uv tool environment
    system "uv", "tool", "install",
           "--python", "3.11",
           "--force",
           "madcat-tts==#{version}"

    # uv tool install puts the binary in ~/.local/bin — symlink into brew prefix
    uv_bin = Pathname.new(Dir.home)/".local/bin/madcat-tts"

    # Wrapper script that delegates to the uv-managed entrypoint
    (bin/"madcat-tts").write <<~EOS
      #!/bin/bash
      export PYTHONUNBUFFERED=1
      exec "#{uv_bin}" "$@"
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
      Installed via `uv tool install madcat-tts==#{version}` from PyPI.

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
