class MarauderMesh < Formula
  desc "MARAUDER MQTT mesh daemon"
  homepage "https://github.com/marauder-os/marauder-os"
  license "PolyForm-Small-Business-1.0.0"
  head "https://github.com/marauder-os/homebrew-tap.git", branch: "main"
  version "0.3.0"

  def install
    (etc/"marauder").mkpath
    unless (etc/"marauder/mesh.env").exist?
      (etc/"marauder/mesh.env").write <<~EOS
        # Environment for marauder mesh daemon
        # Edit this file then: brew services restart marauder-mesh
        RUST_LOG=marauder_os=info
      EOS
    end
    (share/"marauder"/"mesh.service").write "marauder mesh daemon v#{version}"
  end

  service do
    run [HOMEBREW_PREFIX/"bin/marauder", "mesh", "daemon"]
    keep_alive true
    log_path var/"log/marauder-mesh.log"
    error_log_path var/"log/marauder-mesh.log"
    environment_variables HOME: Dir.home,
                          PATH: "#{HOMEBREW_PREFIX}/bin:#{Dir.home}/.local/bin:/usr/bin:/bin"
  end

  test do
    assert_predicate etc/"marauder/mesh.env", :exist?
  end
end
