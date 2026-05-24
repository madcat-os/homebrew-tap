class MarauderSysop < Formula
  desc "MARAUDER system metrics daemon"
  homepage "https://github.com/marauder-os/marauder-os"
  license "PolyForm-Small-Business-1.0.0"
  version "0.3.0"
  url "https://github.com/marauder-os/homebrew-tap/archive/refs/heads/main.tar.gz"

  depends_on "marauder-os/tap/marauder"

  def install
    (etc/"marauder").mkpath
    (etc/"marauder/sysop.env").write <<~EOS
      # Environment for marauder sysop daemon
      # Edit this file then: brew services restart marauder-sysop
      RUST_LOG=marauder_os=info,marauder_os::sysop=debug
      INTERVAL_SECS=10
    EOS
  end

  service do
    run [HOMEBREW_PREFIX/"bin/marauder", "sysop", "daemon", "--interval-secs", "10"]
    keep_alive true
    log_path var/"log/marauder-sysop.log"
    error_log_path var/"log/marauder-sysop.log"
    environment_variables HOME: Dir.home,
                          PATH: "#{HOMEBREW_PREFIX}/bin:#{Dir.home}/.local/bin:/usr/bin:/bin",
                          RUST_LOG: "marauder_os=info,marauder_os::sysop=debug"
  end

  test do
    assert_predicate etc/"marauder/sysop.env", :exist?
  end
end
