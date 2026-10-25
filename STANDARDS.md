# Standards

Each principle from [PRINCIPLES.md](PRINCIPLES.md) turned into rules you can check in review. When they pull against each other, pick what works and is easiest to undo.

Each repo copies this into its own `docs/standards.md` and swaps in its own examples. Repo-specific rules go there too.

## Jungle Style

Use what's already racked.

- Use the stdlib first, then what's already in the stack, then the OS, the database, and the init system. A new dependency comes last and gets a one-line reason in the commit.
- Lean on the database's transactions, the OS's process model, and the supervisor's restarts before writing your own.

## DRY

One fact, one place. DRY is about knowledge, not text.

- A rule that both the code and the docs state (a default, a state name, an env var) is defined once in code. The docs name it; they don't restate its logic.
- Two blocks that look alike but would change for different reasons stay separate. Duplication is cheaper than the wrong abstraction.
- Extract on the third real use, not the second similar-looking one.

## YAGNI

Build the current milestone, not the imagined product.

- No plugin systems, factories, registries, base classes, config frameworks, or extension points without two real cases that need them today.
- No option, flag, or parameter that nothing sets.
- A deferred requirement gets a line in the spec or `docs/ROADMAP.md`, not a stub in code.

## Zen

From the Zen of Python, the parts that bite:

- Explicit over implicit: no import-time side effects, no hidden globals, no magic defaults that differ by environment.
- Flat over nested: early returns, shallow control flow, one module per concept.
- Errors never pass silently: catch only what you can handle, and say what you did with it.
- One obvious way: one code path that the CLI, API, and anything else share.

## Wabi sabi

Accept imperfection that's honest about itself.

- Plain, finished, and slightly rough beats polished and unfinished. Ship the small thing that works.
- Leave a sharp edge exposed rather than papering over it. A known limit goes in the docs or one comment, not in a workaround.
- Don't gold-plate output, logging, or UI. Good enough to read is good enough.

## Wu wei

Work with the grain. Don't force it.

- Prefer state the system converges to (expired leases requeue, stale locks clear) over steps someone must remember.
- Nothing should need tending. A feature that creates recurring work for its owner is a bug.

## Pragmatic Programmer

- Tracer bullets: get a thin slice working end to end before widening any layer.
- Crash early: an impossible state raises. It isn't logged and continued.
- Fix broken windows: leave each file you touch a little cleaner, within the change's scope.
- Reversible decisions: prefer the choice that's easy to undo, and record the ones that aren't as ADRs in `docs/stack.md`.
- Orthogonality: layers talk through explicit interfaces (an API, a schema, a file format) and don't know each other's internals.

## Testing

Few tests, at boundaries that stay put.

- Test what a user would notice: the behaviors the spec promises, and recovery after a crash.
- Don't test plumbing, getters, wording, or internal call order. Don't mock half the system to prove a call happened.
- Before adding a test, ask what realistic regression it catches and whether it survives a refactor. If the answer is weak, skip it.

## Running it

- One command runs local checks and CI. One maintained script installs it. Setup steps don't get scattered across docs.
- The README says what the project is and how to run it, in that order.

## Privacy

- Never commit hostnames, tokens, personal context, or deployment config. Use `.env.example` for config shape. In docs, name roles, not machines: "the NAS" or "a GPU host".

## Comments and names

- Names say what. Comments say why, and only when the why isn't obvious: a constraint, an invariant, a tradeoff.
- No comments that restate the code, and no commented-out code.
- Project names are dumb and Linuxy: short, lowercase, nothing producty.

## Prose

For docs, commit messages, and PR descriptions. Follow the rules in
[agent-style](https://github.com/yzhao062/agent-style/blob/7da99e0b0610aca4e4d340351bd802bfd448c894/RULES.md)
but skip its House Style section, which is for academic papers. These rules take precedence:

- Describe the project as it is meant to be. No dates, approval trails, or "replacing X"; history lives in git.
- Link instead of restating. Each fact has one home, the same as in code.
- Arrange sections in the order a reader needs them.
- Error messages, log lines, and CLI output are interface. Changing their wording is an interface change, not a style edit.
- Contractions are fine, and headings use sentence case.
- "X, not Y" is fine where it prevents a real confusion.
- When writing up a problem, separate evidence, inference, and unknowns, and label which is which.
