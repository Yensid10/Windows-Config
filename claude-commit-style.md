# Claude commit-message guide (BCS personal style)

Reference for an AI assistant generating commit titles and descriptions for this developer's repos. Paste this file's contents into `CLAUDE.md` (or equivalent) in any repo where you want the assistant to follow it.

Style synthesised from genuine commits in the [GridJava](https://github.com/Yensid10/GridJava) main-branch history. Some commits in that repo were AI-assisted with the developer adjusting them — those came out **noticeably more manicured** (rigid 4-paragraph structure, exhaustively enumerated tests, sterilised tone). **Don't match that.** Match the older / unassisted commits instead — they're shorter, first-person, and conversational with parenthetical asides.

---

## Hard rule — the assistant never commits

The assistant **drafts** the proposed title and description, prints them to chat, and stops. The developer copy-edits and runs `git commit` themselves.

- ❌ Never invoke `git commit -m "..."`, `git commit -F file`, or any variant from a tool call, even when the user says "commit this".
- ❌ Never run `git push`.
- ✅ Output the title and body as plain text the developer can copy-paste.
- ✅ If the user explicitly says "go ahead and commit", **still ask once** to confirm before running git commands. Default is always: draft and hand over.

---

## Subject line

- **Length:** ~50–75 chars typical, under 100. One line, no period at the end.
- **Shape:** action verb + concrete object of the change. Past tense or present-imperative — both natural in the genuine history.
- **Verbs that fit the style:** Implemented · Added · Adjusted · Fixed · Removed · Refactored · Replaced · Created · Polished · Converted · Finalised · Built · Wired
- **Multiple distinct changes in one commit:** join with `;` or `&`. e.g., `Replace prints with logger; adjust DatabaseEngine API`.
- **Avoid:** vague labels (`Quick Commit`, `More Updates`, `Misc`), bare category words (`Refactor`, `Fix`) without an object, Conventional Commits prefixes (`feat:`, `fix(scope):` — not the style here).

### Subject examples — genuine

- `Replace prints with logger; adjust DatabaseEngine API`
- `Adjusted client/server communication & databse to use JSON format`
- `Removed unused provideInput helper from tests`
- `Refactored SearchEngine and added unit tests`
- `Added a polished Search Module to FinalPrograms`
- `Converted to HyperskillProjects multi-module build`
- `Polished encryption/decryption app/tests in a FinalProgram Directory`

### Subject examples — avoid

- `Quick Commit` — no information
- `More Report Work` — no scope
- `Post-Submission Push` — meta about the push, not the change
- `Fixing FTSE100` — vague (what about it?)

---

## Body

Body length is usually **1–3 paragraphs**. Even substantial work is rarely 4+ paragraphs in this voice. Skip the body only when the change is genuinely trivial AND the subject already captures everything (e.g., `Bumped Astro to 6.1.10`).

### Voice — this is where the AI tends to drift

- **First person dominates.** "I've added", "I changed", "I had to", "I've made sure", "I'm committing", "I've adjusted". This is the default opening for paragraphs and the natural way to describe what was done. Don't switch to detached / passive ("The cart gains a new helper…") — that's the AI tell.
- **Parenthetical asides are natural and welcome.** "(I've added the multiple requests as an extension myself)", "(allowing it to be runable)", "(an adaptation of Menu as it was not needed anymore)". Use them when there's context that doesn't earn a full sentence.
- **Trailing "..." for thought continuation** appears occasionally and is fine. e.g., *"I've made sure to include unit tests covering set/get/delete behavior, edge cases, and a few integration scenarios..."*
- **"To achieve this"** / **"To do so"** / **"I had to"** as framing introductions are common when explaining how something was implemented, sometimes followed by a bulleted list.
- **Slight redundancy** ("adjusted X, adjusted Y to work with Z") is natural — don't over-polish.
- **Excitement markers** sparingly OK (`...with more tests to be expanded on in the future!`).
- **British English** throughout — behaviour, favour, polish, finalise, organise, recognise.

### Length

- **Trivial / one-touch changes** (test assertion fix, comment edit, dependency rename, lint cleanup): 1–2 sentences.
- **Substantial changes:** 1–3 paragraphs is typical. Even big features rarely warrant more — the genuine commits are tighter than the AI-assisted ones.
- **Resist over-structuring.** The genuine commits don't follow a strict "para 1 = what / para 2 = how / para 3 = tests" formula. They flow — what got changed, how it works, tests, side notes — without rigid section breaks.

### What goes in

In rough order — include what's relevant, omit what isn't:

1. **What was added/changed**, named concretely. Class / file / function names, not "some helpers".
2. **How it works** when non-obvious — algorithm / pattern / structure choice. e.g., "uses ReentrantReadWriteLock so reads are concurrent", "via a static method, `inputToRequests`, that manually parses JSON".
3. **Why** — only when it's not obvious. Skip for self-explanatory mechanical changes; include when there's a constraint or a subtle decision worth flagging.
4. **Tests** — described, not exhaustively enumerated. *"I've added tests covering file persistence (write-through, cache load, round-trip), thread safety (concurrent reads, concurrent writes, mixed), concurrent server clients via ExecutorService, and file-based single and multi-request flows."* That style — categories with brief expansions — is the target. Don't list every individual test case.
5. **Bulleted lists** for genuinely list-like changes (e.g., several new files added at once). Use when it'd be clearer than prose; don't force it.
6. **Out-of-scope inclusions** flagged honestly. e.g., *"(not part of the spec necessarily but a notable side-product of how I did it)"* or *"I've added the multiple requests as an extension myself"*.
7. **Side effects / unchanged areas** worth flagging. e.g., *"I've kept the same logic for the menu and database engine, which has not been used for this stage."*
8. **What's planned next** — final sentence or short paragraph when something is in flight. e.g., *"Next I will populate the encdec project with the Encryption Decryption project files!"* or *"Now I will comment my other classes/files and make sure the code is neat before I try and finally compile it."* Concise, one-line is typical. Skip when there's no obvious follow-up.

### Body examples — genuine voice

> **Subject:** `Adjusted tests for DatabaseEngine changes`
>
> I had forgotten to adjust the tests for the change in DatabaseEngine, now they check for NotThrow & NotNull.

> **Subject:** `Replace prints with logger; adjust DatabaseEngine API`
>
> I've replaced `System.out.print(e)` with `java.util.logging.Logger` in client and server Main classes for proper logging. I've also updated DatabaseEngine: change `set(...)` to return void (remove "OK"), and have `delete(...)` return an empty string when a key is removed (previously returned "OK").

> **Subject:** `Added simple TCP client/server`
>
> To achieve this, I had to:
>
> - Add server Main (binds to 127.0.0.1:23456) that accepts one client, reads a message and replies using custom echo streams.
> - Add client Main that connects to the server, sends a test request and reads the reply.
> - Add `EchoDataInputStream` / `EchoDataOutputStream` wrappers that log read/write UTF messages for debugging/logging.
> - Add unit tests for `EchoDataStream` rountrip, and a full Server/Client integration test utilising a thread and a captured output stream to verify.
>
> I've kept the same logic for the menu and database engine, which has not been used for this stage.

> **Subject:** `Created a jsondb module with engine, server, and tests`
>
> I've created the first part of my JSON Database project, which is the jsondb Gradle module, that uses a new `build.gradle.kts`. It implement a simple DatabaseEngine with set/get/delete semantics and a CLI Menu that reads stdin; due to a necassary client/server infrastructure, there is a client Main placeholder for future socket work. I've made sure to include unit tests covering set/get/delete behavior, edge cases, and a few integration scenarios... I adjusted the `settings.gradle.kts` to include the new package (allowing it to be runable).

Note the style markers in those examples: parenthetical asides, "I've", trailing "...", "To achieve this", a single flowing paragraph rather than a forced multi-section structure, and tests described in clusters not enumerated.

---

## How the assistant should hand the message over

When asked to draft a commit message, the assistant produces two clearly-separated blocks the developer can copy-paste:

```
**Subject**

<the proposed subject>

**Body**

<the proposed body, in first person, 1–3 paragraphs typical>
```

- No surrounding triple-backtick fences around the *actual* title and body content (interferes with copy-paste).
- Use the `**Subject**` / `**Body**` markdown labels purely as separators.
- After the message blocks, optionally a 1-line note flagging anything the developer should sanity-check before committing (e.g., "I estimated ~120 tests — quick `npm run test` to verify the count").

---

## Things this guide intentionally does NOT do

- **Conventional Commits** (`feat:`, `fix(scope):`, etc.) — not the style here. Skip prefixes.
- **`(pt. N)` staged-work suffixes** — these appear in the historical examples because the developer was completing staged Hyperskill course assignments. Disregard for new commits unless the developer asks for it specifically.
- **Issue / ticket references** (`Closes #123`) — only include when the developer mentions the ticket explicitly. Don't fabricate.
- **`Co-authored-by:` trailers** — leave those to GitHub's UI / explicit user request. Never insert automatically.
- **Emojis / Gitmoji** — not the style here.
- **Subject + body separated by `BREAKING CHANGE:` footers** — not used.
- **Manicuring the voice.** Don't sterilise — first-person, parentheticals, "to achieve this", flowing paragraphs are *features*. Detached / passive descriptions and rigid multi-section structure are the AI tell to avoid.

---

## Quick reference — the shape of a good message

```
<verb> <concrete object of change>

I've <what I changed at the named-entity level, in first person, with how-it-works detail when non-obvious, possibly a parenthetical aside or two>. <Tests described in clusters.> <Side note / unchanged area / out-of-scope inclusion if relevant.>

<Optional: short "next up" sentence when in flight.>
```
