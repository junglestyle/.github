.PHONY: check

# Exact versions, so CI and a laptop check with the same tools.
SHELLCHECK = uvx --from shellcheck-py==0.11.0.1 shellcheck
RUFF = uvx --from ruff==0.17.2 ruff

# Offline once uv has the tools. ruff loads ruff.toml as its config, which also catches a rule it no longer knows.
check:
	$(SHELLCHECK) code-standards/sync.sh test.sh
	./test.sh
	$(RUFF) check --config code-standards/ruff.toml --no-cache --stdin-filename check.py - </dev/null
