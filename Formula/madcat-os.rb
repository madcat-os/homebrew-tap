class MadcatOs < Formula
  desc "MADCAT MCP server and CLI (stdio and Streamable HTTP)"
  homepage "https://pypi.org/project/madcat-os/"
  url "https://files.pythonhosted.org/packages/9c/9c/042d517e38bd322cba8a297597ec8271eb1d2dd4956729410ff6b6cd98fd/madcat_os-0.1.6.tar.gz"
  sha256 "387519faf8cc7221bca2e3f6bd89ab6ed306986d2d66fa695a4ea93ff773f472"
  license "BUSL-1.1"

  livecheck do
    url :stable
    strategy :pypi
  end

  depends_on "uv" => :build
  depends_on "libpq"
  depends_on "python@3.13"

  def install
    # Install the project and its locked dependencies (uv.lock ships in the sdist) into libexec.
    ENV["UV_PROJECT_ENVIRONMENT"] = libexec.to_s
    ENV["UV_PYTHON_DOWNLOADS"] = "never"
    # psycopg-binary bundles libpq, OpenSSL and Kerberos dylibs without header padding, so Homebrew
    # cannot relocate them. Build psycopg's C implementation against Homebrew's libpq instead.
    system "uv", "sync", "--frozen", "--no-dev", "--no-editable", "--compile-bytecode",
           "--no-install-package", "psycopg-binary",
           "--python", formula_opt_bin("python@3.13")/"python3.13"
    python = libexec/"bin/python"
    psycopg = Utils.safe_popen_read(python, "-c",
                                    "import importlib.metadata as m; print(m.version('psycopg'))").strip
    ENV.prepend_path "PATH", formula_opt_bin("libpq")
    system "uv", "pip", "install", "--python", python, "--no-binary", "psycopg-c", "psycopg-c==#{psycopg}"
    bin.install_symlink libexec/"bin/madcat"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/madcat --version")
    assert_match "pong", shell_output("#{bin}/madcat mcp call ping")
    assert_equal "c", shell_output("#{libexec}/bin/python -c 'import psycopg; print(psycopg.pq.__impl__)'").strip
  end
end
