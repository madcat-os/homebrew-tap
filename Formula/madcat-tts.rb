class MadcatTts < Formula
  desc "TTS daemon — VoxCPM2 voice clone engine (30 langs, 48kHz)"
  homepage "https://github.com/madcat-os/madcat-tts"
  license "MIT"
  url "https://github.com/madcat-os/madcat-tts.git", tag: "v0.4.0", branch: "main"
  version "0.4.0"

  depends_on "uv"

  def install
    # Create a venv in the Cellar — no dependency on $HOME
    venv = libexec/"venv"
    system "uv", "venv", "--python", "3.12", venv.to_s

    # Install deps from pyproject.toml + the server code
    system "uv", "pip", "install",
           "--python", (venv/"bin/python").to_s,
           "voxcpm>=2.0.3",
           "fastapi>=0.124",
           "uvicorn[standard]>=0.38",
           "numpy<2",
           "pydantic-settings>=2.12",
           "pydub>=0.25",
           "python-dotenv>=1.2",
           "soundfile",
           "setproctitle>=1.3"

    # Copy server code into libexec
    libexec.install "run.py"
    libexec.install "server"
    libexec.install "voices"

    # Wrapper script
    (bin/"madcat-tts").write <<~EOS
      #!/bin/bash
      export PYTHONUNBUFFERED=1
      cd "#{libexec}"
      exec "#{venv}/bin/python" "#{libexec}/run.py" "$@"
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
                          MADCAT_TTS_LOG: "info"
  end

  def caveats
    <<~EOS
      VoxCPM2 engine (Apache 2.0 model, 30 languages, 48kHz output).

      First run downloads ~8GB model from HuggingFace (cached after).
      Requires NVIDIA GPU with ~8GB free VRAM.

      Start the service:
        brew services start madcat-tts

      Logs at: #{var}/log/madcat-tts.log
    EOS
  end

  test do
    assert_match "uvicorn", shell_output("#{bin}/madcat-tts --help 2>&1", 0)
  end
end
