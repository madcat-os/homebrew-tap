class MarauderLifecycle < Formula
  desc "MARAUDER lifecycle daemon (Python/MQTT)"
  homepage "https://github.com/marauder-os/marauder-agent"
  license "PolyForm-Small-Business-1.0.0"
  version "0.1.0"
  url "https://github.com/marauder-os/homebrew-tap/archive/refs/heads/main.tar.gz"

  depends_on "uv"

  def install
    (etc/"marauder").mkpath
    (etc/"marauder/lifecycle.env").write <<~EOS
      # Environment for marauder lifecycle daemon
      # Edit this file then: brew services restart marauder-lifecycle
      MARAUDER_BROKER_HOST=10.8.0.1
      MARAUDER_BROKER_PORT=1883
      MARAUDER_BROKER_USERNAME=fuji
      MARAUDER_BROKER_PASSWORD=marauder
      MARAUDER_NODE_ID=fuji
    EOS

    (bin/"marauder-lifecycle").write <<~EOS
      #!/bin/bash
      # Wrapper for marauder lifecycle daemon
      set -a
      [ -f #{etc}/marauder/lifecycle.env ] && . #{etc}/marauder/lifecycle.env
      set +a
      export PYTHONUNBUFFERED=1
      exec #{HOMEBREW_PREFIX}/bin/uv run --quiet \\
        --directory "$HOME/Projects/marauder-agent" \\
        python scripts/lifecycle_daemon.py
    EOS
  end

  service do
    run [opt_bin/"marauder-lifecycle"]
    keep_alive true
    working_dir Dir.home + "/Projects/marauder-agent"
    log_path var/"log/marauder-lifecycle.log"
    error_log_path var/"log/marauder-lifecycle.err.log"
    environment_variables HOME: Dir.home,
                          PATH: "#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin",
                          PYTHONUNBUFFERED: "1",
                          MARAUDER_BROKER_HOST: "10.8.0.1",
                          MARAUDER_BROKER_PORT: "1883",
                          MARAUDER_BROKER_USERNAME: "fuji",
                          MARAUDER_BROKER_PASSWORD: "marauder",
                          MARAUDER_NODE_ID: "fuji"
  end

  test do
    assert_predicate etc/"marauder/lifecycle.env", :exist?
  end
end
