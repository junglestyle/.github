#!/usr/bin/env bash
# Copies the org's code standards into a repo, or checks its copies. Run it from the repo's root.
#
#   sync.sh sync <dir> <sha>   write the copies from <dir>/code-standards, headed by <sha>
#   sync.sh check <dir>        fail if a copy differs from <dir>/code-standards, is missing, or isn't declared
#
# <dir> holds a checkout of junglestyle/.github. README.md always applies and is copied to
# docs/org-standards.md. Each topic listed in .org-standards (whitespace-separated, # starts a comment)
# is copied from <topic>.md to docs/org-standards-<topic>.md. Every repo has .org-standards, even if it lists none.
set -euo pipefail

usage() {
    echo "usage: sync.sh sync <dir> <sha> | sync.sh check <dir>" >&2
    exit 2
}

# Prints the declared topics, one per line. A missing .org-standards is an error.
topics() {
    [[ -f .org-standards ]] || { echo "no .org-standards in $PWD: create it and list the repo's topics, or none" >&2; return 1; }
    sed 's/#.*//' .org-standards | tr -s '[:space:]' '\n' | while read -r topic; do
        [[ -n $topic ]] || continue
        if [[ ! $topic =~ ^[a-z0-9-]+$ ]]; then
            echo ".org-standards: bad topic name '$topic' (use a-z, 0-9 and -)" >&2
            exit 1
        fi
        echo "$topic"
    done | sort -u
}

# Prints "<source file> <copy>" for the general doc and each declared topic.
pairs() {
    local list topic
    list=$(topics) || return 1
    echo "README.md docs/org-standards.md"
    for topic in $list; do
        echo "$topic.md docs/org-standards-$topic.md"
    done
}

# Succeeds if copy $1 is one of the pairs in $2.
declared() {
    local file copy
    while read -r file copy; do
        [[ $copy == "$1" ]] && return 0
    done <<<"$2"
    return 1
}

sync() {
    local src=$1/code-standards sha=$2 list file copy
    [[ -f $src/README.md ]] || { echo "no code-standards/README.md in $1: is it a junglestyle/.github checkout?" >&2; return 1; }
    list=$(pairs)
    while read -r file copy; do
        [[ -f $src/$file ]] || { echo "unknown topic ${file%.md}: no code-standards/$file in junglestyle/.github" >&2; return 1; }
    done <<<"$list"

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    while read -r file copy; do
        { echo "<!-- junglestyle/.github code-standards/$file at $sha. Change it there, then run make sync-standards. -->"
          cat "$src/$file"; } >"$tmp/${copy##*/}"
    done <<<"$list"
    mkdir -p docs
    while read -r file copy; do
        mv "$tmp/${copy##*/}" "$copy"
    done <<<"$list"

    for copy in docs/org-standards-*.md; do
        [[ -e $copy ]] || continue
        declared "$copy" "$list" || rm "$copy"
    done
}

check() {
    local src=$1/code-standards list file copy failed=0
    [[ -f $src/README.md ]] || { echo "no code-standards/README.md in $1: is it a junglestyle/.github checkout?" >&2; return 1; }
    list=$(pairs)
    while read -r file copy; do
        if [[ ! -f $src/$file ]]; then
            echo "unknown topic ${file%.md} in .org-standards: no code-standards/$file in junglestyle/.github" >&2
            failed=1
        elif [[ ! -f $copy ]]; then
            echo "$copy is missing: run make sync-standards" >&2
            failed=1
        elif ! diff -u "$src/$file" <(tail -n +2 "$copy"); then
            echo "$copy differs from the org's code-standards/$file: run make sync-standards" >&2
            failed=1
        fi
    done <<<"$list"

    for copy in docs/org-standards-*.md; do
        [[ -e $copy ]] || continue
        if ! declared "$copy" "$list"; then
            echo "$copy isn't declared in .org-standards: add its topic there, or delete it" >&2
            failed=1
        fi
    done
    return "$failed"
}

case ${1:-} in
    sync) [[ $# -eq 3 ]] || usage; sync "$2" "$3" ;;
    check) [[ $# -eq 2 ]] || usage; check "$2" ;;
    *) usage ;;
esac
