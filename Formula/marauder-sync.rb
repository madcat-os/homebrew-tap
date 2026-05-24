class MarauderSync < Formula
  desc "MARAUDER cr-sqlite sync daemon"
  homepage "https://github.com/marauder-os/marauder-os"
  license "PolyForm-Small-Business-1.0.0"
  version "0.3.0"
  url "https://github.com/marauder-os/homebrew-tap/archive/refs/heads/main.tar.gz"

  depends_on "marauder-os/tap/marauder"

  def install
    (etc/"marauder").mkpath
    (etc/"marauder/sync.env").write <<~EOS
      # Environment for marauder sync daemon
      # Edit this file then: brew services restart marauder-sync
      RUST_LOG=marauder_os=info,marauder_os::sync=debug
    EOS
  end

  service do
    run [HOMEBREW_PREFIX/"bin/marauder", "sync", "daemon"]
    keep_alive true
    log_path var/"log/marauder-sync.log"
    error_log_path var/"log/marauder-sync.log"
    environment_variables HOME: Dir.home,
                          PATH: "#{HOMEBREW_PREFIX}/bin:#{Dir.home}/.local/bin:/usr/bin:/bin",
                          RUST_LOG: "marauder_os=info,marauder_os::sync=debug"
  end

  test do
    assert_predicate etc/"marauder/sync.env", :exist?
  end
end
