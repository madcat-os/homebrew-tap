class MadcatOs < Formula
  desc "MADCAT MCP server and CLI (stdio and Streamable HTTP)"
  homepage "https://pypi.org/project/madcat-os/"
  url "https://files.pythonhosted.org/packages/3b/88/4946252c291784c551ed6bb599f5f0d2ed0c3848dd1f973bf9aa3b39e80f/madcat_os-0.1.4.tar.gz"
  sha256 "c79d5b1ef9619c941da1cbff1b44fa6dfd0329029f46e5f0291e82d8a056bde4"
  license "MIT"

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
