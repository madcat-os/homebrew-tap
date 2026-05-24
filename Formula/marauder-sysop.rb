class MarauderSysop < Formula
  desc "MARAUDER system metrics daemon"
  homepage "https://github.com/marauder-os/marauder-os"
  license "PolyForm-Small-Business-1.0.0"
  head "https://github.com/marauder-os/homebrew-tap.git", branch: "main"
  version "0.3.0"

  def install
    (etc/"marauder").mkpath
    unless (etc/"marauder/sysop.env").exist?
      (etc/"marauder/sysop.env").write <<~EOS
        # Environment for marauder sysop daemon
        # Edit this file then: brew services restart marauder-sysop
        RUST_LOG=marauder_os=info,marauder_os::sysop=debug
        INTERVAL_SECS=10
      EOS
    end
    (share/"marauder"/"sysop.service").write "marauder sysop daemon v#{version}"
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
