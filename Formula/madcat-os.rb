class MadcatOs < Formula
  desc "MADCAT MCP server and CLI (stdio and Streamable HTTP)"
  homepage "https://pypi.org/project/madcat-os/"
  url "https://files.pythonhosted.org/packages/ee/ad/3dc4454a5c5c14567f07ea0fe13e3c1cfa9519f4914a80e1f55465a89ef4/madcat_os-0.1.5.tar.gz"
  sha256 "47af600057a745f271f6282fbd2c60e0e5b9002efea10eba8572710bd548c98d"
  license "BUSL-1.1"

  livecheck do
    url :stable
    strategy :pypi
  end

  depends_on "uv" => :build
  depends_on "python@3.13"

  def install
    # Install the project and its locked dependencies (uv.lock ships in the sdist) into libexec.
    ENV["UV_PROJECT_ENVIRONMENT"] = libexec.to_s
    ENV["UV_PYTHON_DOWNLOADS"] = "never"
    system "uv", "sync", "--frozen", "--no-dev", "--no-editable", "--compile-bytecode",
           "--python", formula_opt_bin("python@3.13")/"python3.13"
    bin.install_symlink libexec/"bin/madcat"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/madcat --version")
    assert_match "pong", shell_output("#{bin}/madcat mcp call ping")
  end
end
