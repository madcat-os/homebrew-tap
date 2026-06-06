# homebrew-tap

Private Homebrew tap for the MADCAT platform.

## Install

```bash
brew tap madcat-os/tap git@github.com:madcat-os/homebrew-tap.git
brew install madcat-os/tap/madcat
```

## Formulas

| Formula | What it does |
|---------|-------------|
| `madcat` | Meta-formula — installs everything below |
| `madcat-index` | CLI for indexing code/docs into EEMS (Postgres+pgvector) |
| `madcat-plugin` | Opencode plugin — NAPI bindings + TypeScript tools |
| `opencode-serve` | Brew service for `opencode serve` |
| `madcat-tts` | Brew service for the TTS daemon (Chatterbox + Piper) |

## Services

```bash
brew services start opencode-serve
brew services start madcat-tts
brew services list
```

## Requirements

- SSH access to `github.com/madcat-os/*` repos (private)
- Rust toolchain (`brew install rust`)
- `~/.config/madcat/config.toml` with `[database].dsn` pointing at Postgres
- Python 3.11+ with `uv` for madcat-tts
