#!/usr/bin/env bash
# Tests code-standards/sync.sh against scratch repos: each case sets one up, runs sync or check, and asserts the
# exit status and, for a run that should fail, that it wrote nothing. Messages aren't checked: only people read
# them. Run it from anywhere: ./test.sh
# Bash 3.2-safe, like sync.sh, since make runs sync.sh on macOS.
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)
sync=$root/code-standards/sync.sh
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cases=0
failures=0

pass() { cases=$((cases + 1)); }
fail() { cases=$((cases + 1)); failures=$((failures + 1)); echo "FAIL: $*" >&2; }

# A scratch repo whose .org-standards holds $1, or none when $1 is "-".
repo() {
    local dir
    dir=$(mktemp -d "$work/repo.XXXXXX")
    if [[ $1 != - ]]; then printf '%s\n' "$1" >"$dir/.org-standards"; fi
    echo "$dir"
}

# Runs sync.sh in repo $1 with the rest as its arguments, quietly.
run() {
    local dir=$1
    shift
    (cd "$dir" && "$sync" "$@" >/dev/null 2>&1)
}

# Every file in a repo with its checksum, to show a failed run changed nothing.
state() { (cd "$1" && find . -type f | LC_ALL=C sort | while read -r f; do cksum "$f"; done); }

# expect_ok <case> <repo> <args...>: the run succeeds.
expect_ok() {
    local name=$1 dir=$2
    shift 2
    if run "$dir" "$@"; then pass; else fail "$name: sync.sh $* failed"; fi
}

# expect_fail <case> <repo> <args...>: the run fails and leaves the repo as it was.
expect_fail() {
    local name=$1 dir=$2 before
    shift 2
    before=$(state "$dir")
    if run "$dir" "$@"; then
        fail "$name: sync.sh $* succeeded"
    elif [[ $(state "$dir") != "$before" ]]; then
        fail "$name: sync.sh $* failed but changed the repo"
    else
        pass
    fi
}

# expect_usage <case> <repo> <args...>: the run exits 2, sync.sh's usage status, and changes nothing.
expect_usage() {
    local name=$1 dir=$2 before status=0
    shift 2
    before=$(state "$dir")
    run "$dir" "$@" || status=$?
    if [[ $status != 2 ]]; then
        fail "$name: sync.sh $* exited $status, not 2"
    elif [[ $(state "$dir") != "$before" ]]; then
        fail "$name: sync.sh $* changed the repo"
    else
        pass
    fi
}

# expect_copies <case> <repo> <copy...>: docs/ holds exactly these copies, each its source under one header line
# naming the commit.
expect_copies() {
    local name=$1 dir=$2 want got copy source
    shift 2
    want=$(printf '%s\n' "$@" | LC_ALL=C sort)
    got=$(cd "$dir/docs" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)
    if [[ $got != "$want" ]]; then
        fail "$name: docs/ holds [${got//$'\n'/ }], not [${want//$'\n'/ }]"
        return
    fi
    for copy in "$@"; do
        source=${copy#org-standards}
        source=${source#-}
        source=${source%.md}
        source=$root/code-standards/${source:-README}.md
        if ! head -1 "$dir/docs/$copy" | grep -q "at test-sha"; then
            fail "$name: $copy's first line doesn't name the commit"
            return
        fi
        if ! tail -n +2 "$dir/docs/$copy" | cmp -s - "$source"; then
            fail "$name: $copy isn't $source under its header"
            return
        fi
    done
    pass
}

# Synced: the copies each topic list should produce, and check accepts them.
d=$(repo '# no topics yet')
expect_ok "comment-only" "$d" sync "$root" test-sha
expect_copies "comment-only" "$d" org-standards.md
expect_ok "comment-only" "$d" check "$root"

d=$(repo python)
expect_ok "python" "$d" sync "$root" test-sha
expect_copies "python" "$d" org-standards.md org-standards-python.md
expect_ok "python" "$d" check "$root"

d=$(repo 'python go')
expect_ok "python go" "$d" sync "$root" test-sha
expect_copies "python go" "$d" org-standards.md org-standards-go.md org-standards-python.md
expect_ok "python go" "$d" check "$root"

d=$(repo "$(printf 'python python\npython')")
expect_ok "duplicates" "$d" sync "$root" test-sha
expect_copies "duplicates" "$d" org-standards.md org-standards-python.md
expect_ok "duplicates" "$d" check "$root"

d=$(repo "$(printf 'python  # the language\n# go is commented out')")
expect_ok "comments" "$d" sync "$root" test-sha
expect_copies "comments" "$d" org-standards.md org-standards-python.md
expect_ok "comments" "$d" check "$root"

# A resync drops the copy of a topic no longer declared.
d=$(repo 'python go')
run "$d" sync "$root" test-sha
printf 'python\n' >"$d/.org-standards"
expect_ok "dropped topic" "$d" sync "$root" test-sha
expect_copies "dropped topic" "$d" org-standards.md org-standards-python.md
expect_ok "dropped topic" "$d" check "$root"

# Check reads past the header line, so a copy synced at another commit still passes.
d=$(repo python)
run "$d" sync "$root" another-sha
expect_ok "header from another commit" "$d" check "$root"

# Refused: no topic list, or one with a name that isn't a topic.
d=$(repo -)
expect_fail "no .org-standards" "$d" sync "$root" test-sha
expect_fail "no .org-standards" "$d" check "$root"
for topics in nosuch Go '*' 'python nosuch'; do
    d=$(repo "$topics")
    expect_fail "topics '$topics'" "$d" sync "$root" test-sha
    expect_fail "topics '$topics'" "$d" check "$root"
done

# Check fails on a copy that's been edited, is missing, or isn't declared.
d=$(repo python)
run "$d" sync "$root" test-sha
echo "a local edit" >>"$d/docs/org-standards-python.md"
expect_fail "hand-edited copy" "$d" check "$root"

d=$(repo python)
run "$d" sync "$root" test-sha
rm "$d/docs/org-standards-python.md"
expect_fail "missing copy" "$d" check "$root"

d=$(repo python)
run "$d" sync "$root" test-sha
cp "$d/docs/org-standards-python.md" "$d/docs/org-standards-go.md"
expect_fail "undeclared copy" "$d" check "$root"

# Bad arguments: usage, with nothing written.
d=$(repo python)
expect_usage "no arguments" "$d"
expect_usage "unknown command" "$d" frob "$root"
expect_usage "sync without a commit" "$d" sync "$root"
expect_usage "check without a source" "$d" check
expect_usage "check with extra arguments" "$d" check "$root" extra

# A source that isn't a junglestyle/.github checkout.
empty=$(mktemp -d "$work/source.XXXXXX")
mkdir "$empty/code-standards"
d=$(repo python)
expect_fail "source without README.md" "$d" sync "$empty" test-sha
expect_fail "source without README.md" "$d" check "$empty"

echo "$((cases - failures)) of $cases passed"
[[ $failures == 0 ]]
