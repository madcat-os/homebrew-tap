# homebrew-tap

Homebrew tap for MADCAT.

## Install

```bash
brew tap madcat-os/tap
brew trust madcat-os/tap
brew install madcat-os/tap/madcat-os
```

Homebrew 7 refuses to load formulae from a tap you have not trusted, so `brew trust` comes first.

## Formulas

| Formula | What it does |
|---------|-------------|
| `madcat-os` | MADCAT MCP server and CLI (`madcat`), the [madcat-os](https://pypi.org/project/madcat-os/) package from PyPI |

The formula installs the release's `uv.lock` dependency set into its own virtualenv on Homebrew's
`python@3.13`.

## Updating

On a new PyPI release, set `url` and `sha256` in `Formula/madcat-os.rb` to the release's sdist
(`https://pypi.org/pypi/madcat-os/<version>/json`, `packagetype: sdist`), then:

```bash
brew install --build-from-source madcat-os/tap/madcat-os && brew test madcat-os/tap/madcat-os
```
