# Jungle Style

Jungle Style is a philosophy I developed at my local gym where nobody re-racks their weights. At first it frustrated me. Then I realized that by working within the environment instead of against it, its flaws could add value. Now I look for setups already racked and work with what’s there. It saves time and adds variety.

That’s the whole philosophy. **Use what's already racked.** Arguing with reality gets you nowhere; working with it gets you leverage. The rest of this document is tactics.

---

## Attitude

**Wu Wei.** Don't force it. If the code is fighting you, the design is wrong. Step back before you push harder.

**Wabi Sabi.** Rough and honest beats polished and fake. An ugly script that works and says what it is is fine.

**Shoshin.** Beginner's mind. Read your own code as if a stranger wrote it, because in six months one did.

**Zen of Python.** Explicit over implicit. Flat over nested. Readability counts. Applies outside Python too.

## Building

**YAGNI.** Build nothing on speculation. No "we might need this later." Later can build it.

**KISS.** Do the dumbest thing that works.

**Bricolage.** Build from parts at hand (stdlib, Postgres, existing tools, the model) before making new parts.

**Boring technology.** Every project gets a few innovation tokens. Spend them only where the project is actually novel. Use the boring choice everywhere else.

**Rule of Three.** DRY, but not before the third repetition. A premature abstraction costs more than duplication.

**Gall's Law.** Working complex systems grow out of working simple ones. Don't design the big one up front.

**Worse is better.** Simple and shipped beats complete and correct.

**Satisfice.** Good enough is the target, not a compromise.

## Structure

**Explicit seams.** Hard boundaries between layers (ingestion, processing, presentation) with real interfaces between them. This keeps both humans and AI from mushing everything together.

**Clean context.** Pipelines run as discrete steps. Each step gets only the context it needs, not the full history.

**Pave desire paths.** Watch where usage actually flows and build there, not where the diagram says it should go.

## Discipline

**Pragmatic Programmer.** Tracer bullets: get something running end to end first. Orthogonality: changing one thing shouldn't break another. No broken windows.

**Rough, not rotten.** Wabi Sabi and Broken Windows don't conflict. Rough is ugly UI, hacky scripts, unfinished docs, and that's fine. Rotten is lying tests, swallowed errors, dead code pretending to be alive, and that gets fixed now.

**Chesterton's Fence.** Before you remove something you didn't build, find out why it's there.

**Evidence vs. inference.** Separate what you know, what you guessed, and what's still unknown. Say which is which.

**High-value tests.** Write a few tests at stable boundaries that catch real failures. Skip coverage theater, implementation-detail tests, and mock towers.

---

## For agents

Each repo's `AGENTS.md` / `CLAUDE.md` carries a short version of the **Building** and **Structure** sections, derived from this file. The attitude section is for humans.
