class MarauderSync < Formula
  desc "MARAUDER cr-sqlite sync daemon"
  homepage "https://github.com/marauder-os/marauder-os"
  license "PolyForm-Small-Business-1.0.0"
  head "https://github.com/marauder-os/homebrew-tap.git", branch: "main"
  version "0.3.0"

  def install
    (etc/"marauder").mkpath
    unless (etc/"marauder/sync.env").exist?
      (etc/"marauder/sync.env").write <<~EOS
        # Environment for marauder sync daemon
        # Edit this file then: brew services restart marauder-sync
        RUST_LOG=marauder_os=info,marauder_os::sync=debug
      EOS
    end
    (share/"marauder"/"sync.service").write "marauder sync daemon v#{version}"
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
