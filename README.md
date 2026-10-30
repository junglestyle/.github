# .github

The junglestyle organisation's shared files: [PRINCIPLES.md](PRINCIPLES.md), the
[code standards](code-standards/README.md) every repo copies, [sync.sh](code-standards/sync.sh), which writes and
checks those copies, the reusable workflow that runs that check in each repo's CI, and the organisation's profile.

`make check` shellchecks the scripts, tests `sync.sh` against scratch repos (`test.sh`), and loads `ruff.toml` with
ruff. It needs [uv](https://docs.astral.sh/uv/). CI runs it on every pull request and every push to main.

Decided changes to the copied text wait in [PENDING.md](PENDING.md), so that they ship together.
