# Roadmap

<!-- The shape of a junglestyle docs/ROADMAP.md, for the made-up product in SPEC.md. No slice delivers
OUTPUT-3, so the roadmap defers it. -->

The order reachable gets built in. Each slice is usable on its own, names what a user would notice and the
[spec](SPEC.md) requirements it delivers, and has a done-when someone can demonstrate. A requirement not yet in
a slice stays in the spec and waits for one here.

## 1. Tracer bullet: check a list of URLs

Status: done

An operator can list URLs in a file and learn which ones answer:

```sh
reachable --targets ./targets.txt
```

They get one line per target on stdout, and the exit code says whether anything failed, so cron can mail them
only when it matters.

Delivers: TARGET-1, CHECK-1, OUTPUT-1, OUTPUT-2.

Done when: against a test server that answers one path with 200, one with 500 and one not at all, the command
prints three lines in the file's order, the second and third marked as not answering with the status and the
timeout, and exits 1; and a targets file with a bad line exits 2 naming the line.

## 2. Names and redirects

Status: planned

An operator can name each target so the output reads the way they think of their services, and a service that
moved behind a redirect still counts as up.

Delivers: TARGET-2, CHECK-2.

Done when: a named target's line shows its name; a target that redirects twice answers; and one that redirects
six times fails with the last URL it reached.

## 3. Certificates

Status: planned

An operator learns that a certificate is about to expire while there's still time to renew it.

Delivers: CHECK-3.

Done when: against test servers with a valid certificate, an expired one, and one expiring in a week, the first
answers, the second fails as invalid, and the third fails as expiring under the default `--cert-days` and
answers with `--cert-days 3`.
