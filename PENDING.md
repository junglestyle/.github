# Pending changes to the copied standards

Every repo copies `code-standards/README.md` and the topic files it declares, and a change to one turns every repo
that copies it red until it resyncs. So a decided change to that text waits here, one line each with its reason, and
the list ships together: one PR that makes every change and empties the list, then one resync round across the
repos.

What isn't copied ships on its own and doesn't go here: `sync.sh`, the workflows, `PRINCIPLES.md`, `ruff.toml`,
`.golangci.yml`, `.ansible-lint`, the examples and the org profile.

## Go standard: deviating from the current release needs an ADR

`code-standards/go.md` says `go.mod`'s `go` line names the current release. Some repos have to build on a host pinned to an older toolchain, for example one where `GOTOOLCHAIN=local` refuses a newer `go` line. Allow that, but only with an ADR in the repo that names the version, why it's needed, and what would move it forward. The `go` line stays an exact version either way, per the pins table.
