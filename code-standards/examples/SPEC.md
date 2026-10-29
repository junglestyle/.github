# Specification

<!-- The shape of a junglestyle docs/SPEC.md. The product is made up: reachable checks that a list of HTTP
endpoints answers. -->

## Problem

An operator keeps a handful of internal web services and finds out one is down when a user says so. A hosted
uptime service can't reach them, and a dashboard is more than the job needs: the operator wants to run one
command, from cron or by hand, and learn which endpoints don't answer and why.

reachable is one command that reads a list of endpoints, checks each once, and prints what it found. Each
requirement has an ID the [roadmap](ROADMAP.md) cites. A deferred requirement stays here and gets a later slice
there.

## Targets

- **TARGET-1: A file of URLs.** `--targets` names a file with one URL per line. Blank lines and lines starting
  with `#` are skipped. A line that isn't an `http` or `https` URL stops the run before any check, with the line
  number.
- **TARGET-2: A name per target.** A line may add a name after the URL, separated by whitespace. Output uses the
  name when there is one, and the URL otherwise.

## Checks

- **CHECK-1: One request per target.** Each target gets one `GET`, with a timeout of `--timeout` (default: 5s).
  A target answers when the response status is below 400.
- **CHECK-2: Redirects are followed, up to five.** A sixth redirect fails the check, and the output names the
  last URL reached.
- **CHECK-3: Certificates are checked.** An `https` target whose certificate is invalid or expires within
  `--cert-days` (default: 14) fails the check, and the output says which.

## Output

- **OUTPUT-1: JSON lines.** Stdout is one JSON object per target, in the file's order: the target, whether it
  answered, the status or the error, and the time taken.
- **OUTPUT-2: The exit code says if anything failed.** 0 when every target answered, 1 when any didn't, and 2
  when the run itself couldn't start, such as an unreadable `--targets`.
- **OUTPUT-3: A summary for people.** `--text` prints one plain line per target that didn't answer, and nothing
  when all did, in place of the JSON.

## Unknowns

What the spec assumes without having checked:

- That every target answers `GET` on its listed URL. One that only answers `HEAD`, or needs a header, would
  fail every check.

## Open questions

Raised here, not decided:

- **Concurrency.** Checking targets one at a time keeps output in order and is fast enough for a handful. A list
  of hundreds would need checks in parallel, with the output still in the file's order.
