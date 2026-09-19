# Package Manager Security Rules (pnpm)

> **🔒 HUMAN-OWNED SECURITY POLICY — DO NOT EDIT WITHOUT HUMAN APPROVAL.**
> This is governance, not regular documentation. Claude Code must **not** modify
> this file. It is hard-blocked by an `Edit`/`Write` deny rule in
> `.claude/settings.json`. If a code or dependency change requires a policy change,
> **propose** the diff in your response and let a human apply it (and lift the deny
> rule deliberately). Never weaken a control to make an install pass.

## For humans: make this policy effective

This file is just text. It does nothing on its own — it becomes effective only
when a human does two one-time setup steps: make your agent **read** it, and make
it unable to **edit** it. Both are already done in this repository (`CLAUDE.md`
carries the pointer, `.claude/settings.json` carries the deny rule, and
`scripts/check-deny-rules.mjs` runs in CI as the backstop), but the steps are
recorded here so the policy travels intact if it is copied elsewhere.

### 1. Bootstrap — make your agent read the policy

Agents read a per-tool instruction file, not arbitrary repo files. So a human
must **seed the pointer once**. (This is the one step no agent can do for itself:
it can't be told to read a file it has no pointer to.) After the seed, the block
below keeps every *other* instruction file in sync automatically (see
"Self-propagation").

**One-time bootstrap** — paste the block below into **every** agent-instruction
file your team's agents read (see the table). There is no single "canonical"
instruction file to sync the others against: `PNPM_SECURITY.md` is the one
always-present source of truth, and each instruction file must carry the policy
wherever it applies. A file may either paste the block in full or just point at
the source ("Package management: obey `PNPM_SECURITY.md`"). The rule is simply:
the statement is present in all agent-instruction files that exist.

| Agent              | Instruction file                   |
|--------------------|------------------------------------|
| Any (cross-tool)   | `AGENTS.md`                        |
| Claude Code        | `CLAUDE.md`                        |
| GitHub Copilot     | `.github/copilot-instructions.md`  |
| Cursor             | `.cursor/rules/pnpm-security.mdc`  |
| Windsurf           | `.windsurf/rules/pnpm-security.md` |
| Gemini CLI         | `GEMINI.md`                        |
| Aider              | `CONVENTIONS.md`                   |

```markdown
## Package management — MANDATORY

`PNPM_SECURITY.md` is binding policy. **Read it before any dependency,
`pnpm-lock.yaml`, or `pnpm-workspace.yaml` change, then obey every rule.** A
change that violates it must not be committed.

- **Core rules:** pnpm only (never `npm`/`yarn`), no `package-lock.json`,
  never `dangerouslyAllowAllBuilds`.
- **`PNPM_SECURITY.md` is human-owned — do not edit it.** Propose the diff and
  let a human apply it. If your tool has a file-level deny/permission rule
  (e.g. Claude Code's `.claude/settings.json` deny list), it must block
  `Edit`/`Write` on `PNPM_SECURITY.md`; when that config changes, confirm the
  deny is intact and propose restoring it if not.
- **Self-propagation — keep this block alive across agents.** When you work in
  this repo, ensure this block (or a pointer to it) exists in every agent
  instruction file present: `AGENTS.md`, `CLAUDE.md`,
  `.github/copilot-instructions.md`, `.cursor/rules/`, `.windsurf/rules/`,
  `GEMINI.md`, `CONVENTIONS.md`. If one is missing it, propose adding it. If
  you are an agent whose instruction file isn't in the table in
  `PNPM_SECURITY.md`, propose adding your file there too.
```

### 2. Enforce — make the policy read-only

The header above says this file is "hard-blocked by a deny rule" — but that
block is a **separate file that does not travel with this one**. Copying
`PNPM_SECURITY.md` into another repo gives you the policy text and none of the
enforcement, while the header still claims it's protected. Bootstrap (step 1)
makes agents *read* the policy; the deny rule makes them unable to *edit* it.

**Claude Code** — `.claude/settings.json` (committed, **not** gitignored, so the
protection travels with the repo and any removal shows up in review):

```json
{
  "permissions": {
    "deny": [
      "Edit(PNPM_SECURITY.md)",
      "Write(PNPM_SECURITY.md)"
    ]
  }
}
```

**Optional — self-deny the settings file too.** So an agent can't remove the rule
with its own edit tools, also deny edits to `.claude/settings.json` itself:

```json
"deny": [
  "Edit(PNPM_SECURITY.md)",
  "Write(PNPM_SECURITY.md)",
  "Edit(.claude/settings.json)",
  "Write(.claude/settings.json)"
]
```

**Other tools** — deny/permission mechanisms vary, and some agents have none.
Where there is no enforceable deny, the human-owned rule in the header is the
*only* thing standing in the way — so back it with the CI check below.

**Backstop (works for any tool).** A deny rule stops the easy path, but an agent
with shell access can still rewrite files out-of-band (`sed`, `echo >`). The only
check that does not depend on the agent's cooperation is a CI/test guard that
fails the build if the deny entries are missing — it catches removal by any path
and forces a human to see it. It runs in CI (see Enforced Security Measures →
CI/CD Checks).

## Best Practices

This project follows the recommendations in
[pnpm's Supply Chain Security guide](https://pnpm.io/supply-chain-security).
The controls below are enforced via `pnpm-workspace.yaml` (pnpm behavioral
settings), `.npmrc` (registry/auth only), `package.json` (the `packageManager`
pin + exact dependency versions), and `.nvmrc` (pinned Node version).

1. **Always commit `pnpm-lock.yaml`** — never add to `.gitignore`.
2. **Run `pnpm audit` in CI** — fail builds on moderate+ findings.
3. **Review lockfile changes** — don't blindly merge dependency updates.
4. **Use `--frozen-lockfile` in CI/production.**
5. **Add to `allowBuilds` deliberately** — never `dangerouslyAllowAllBuilds`.
6. **Keep pnpm updated** via the `packageManager` field + Corepack.
7. **Pin every dependency exactly** — no `^`/`~` in `package.json`; bump via
   `pnpm update <pkg>` and review the lockfile diff.

---

## Enforced Security Measures

Measures 1–8 hold at install time because pnpm reads `pnpm-workspace.yaml` /
`.npmrc` on every resolve. Measure 9 runs in CI on every push and pull request.

### 1. Exact Version Pinning
- All `dependencies` are pinned exactly (no `^`/`~`), and `saveExact: true` makes
  **future** `pnpm add` write exact versions.
- Bump versions deliberately (`pnpm update <pkg>` then review the lockfile diff),
  never via a floating range. (A hand-edited range is only caught by review.)
- The **Node runtime** is likewise exact-pinned in `.nvmrc` (the single source of
  truth); `package.json` `engines.node` is generated from it via
  `pnpm run sync:node-pin` (see Configuration → Node version).

### 2. Locked Dependencies (`pnpm-lock.yaml`)
- Ensures reproducible installs across all environments.
- Prevents accidental version upgrades.
- Detects dependency-confusion attacks.
- **Always commit it; never add to `.gitignore`.**

### 3. Minimum Release Age
- `minimumReleaseAge: 10080` in `pnpm-workspace.yaml` blocks packages published
  less than 7 days ago (pnpm v11+; the v11 default is `1440` = 1 day).
- Protects against newly published, not-yet-detected supply-chain compromises.
- `minimumReleaseAgeExclude` allows narrow, documented exceptions.
- Set to `0` to disable.

### 4. Blocked Build Scripts (`allowBuilds`)
- pnpm does **not** run dependency lifecycle scripts (`postinstall`, etc.) by
  default — the most common malware execution vector.
- Whitelist only the dependencies you trust to run build scripts via the
  `allowBuilds` **map** (`name: true|false`) in `pnpm-workspace.yaml`.
- This project currently declares **no** `allowBuilds` entries: none of its
  dependencies need a build script to install. Adding an entry is a deliberate
  act that belongs in review.
- **Never** use `dangerouslyAllowAllBuilds` — it globally re-enables script
  execution for every package.

### 5. Block Exotic Sub-Dependencies (`blockExoticSubdeps`)
- `blockExoticSubdeps: true` prevents transitive dependencies from resolving to
  git repositories or direct tarball URLs, which bypass the registry and its
  integrity checks.

### 6. Trust Policy (`trustPolicy`)
- `trustPolicy: no-downgrade` refuses a package whose trust level (signature /
  provenance) has decreased compared to a previous release.
- `trustPolicyExclude` — allow specific packages/versions to bypass the check.
  This project declares none.
- `trustPolicyIgnoreAfter` — ignore trust checks for older packages that predate
  signature/provenance data.

### 7. HTTPS Registry Only
- `registry=https://registry.npmjs.org/` in `.npmrc` prevents
  man-in-the-middle tampering during install.

### 8. Strict Peer Dependencies
- `strictPeerDependencies: true` in `pnpm-workspace.yaml`.
- Note: this is a **correctness/compatibility** control, not a supply-chain
  mitigation — it surfaces incompatible/missing peers instead of silently
  installing a mismatched tree.

### 9. CI/CD Checks
`.github/workflows/ci.yml` runs on every push to `main` and every pull request:
- **Policy deny-rule guard** — asserts the `Edit(PNPM_SECURITY.md)` /
  `Write(PNPM_SECURITY.md)` entries are still in `.claude/settings.json`'s
  `permissions.deny`, failing the build if removed. A deny rule blocks an agent's
  edit tools but not an out-of-band `sed`/`echo >`; this guard is the tamper-proof
  backstop, run in CI where a human reviews the failure. Implemented in
  `scripts/check-deny-rules.mjs`; run it with:
  ```bash
  pnpm run check:deny-rules
  ```
- **Node-pin sync** — `pnpm run sync:node-pin && git diff --exit-code package.json`
  fails the build if `engines.node` is stale relative to `.nvmrc` (i.e. someone
  edited `.nvmrc` without re-running the sync).
- **Frozen lockfile** — `pnpm install --frozen-lockfile` fails on lockfile/manifest
  drift. (`pnpm install` only auto-freezes when `CI=true`; locally you must pass
  the flag.)
- **Security audit** — `pnpm audit --audit-level=moderate` fails the build on
  known vulnerabilities.

`make test` is deliberately **not** part of CI: it needs Docker Compose, a `.env`,
TLS certificates and the GeoLite2 database, none of which a headless runner has.

---

## Setup Instructions

Install pnpm (via Corepack, bundled with Node) and the Node version pinned in
`.nvmrc`:

```bash
nvm install && nvm use          # match the pinned Node version
corepack enable                 # provides the pinned pnpm
pnpm install --frozen-lockfile  # reproducible install from the lockfile
```

`make install` does the same end to end, including installing nvm itself.

### Daily Development

```bash
pnpm install --frozen-lockfile  # install from lockfile (CI / fresh checkout)
pnpm start                      # node app.js
make run                        # build and run via Docker Compose
make test                       # build, start, and probe the API
```

---

## Package Management and Audits

```bash
pnpm add --save-exact <package>     # add a pinned dependency
pnpm update                         # update within ranges
pnpm outdated                       # show available updates
pnpm audit --audit-level=moderate   # check for known vulnerabilities
```

---

## Configuration

### `.npmrc` — registry / auth only (INI)
- `registry=https://registry.npmjs.org/` — HTTPS only.
- Put **only** registry URLs and auth tokens here.

### `pnpm-workspace.yaml` — pnpm behavioral settings (YAML)
pnpm v11+ reads behavioral settings from YAML, not `.npmrc`. Settings used here:

```yaml
minimumReleaseAge: 10080
blockExoticSubdeps: true
trustPolicy: no-downgrade
strictPeerDependencies: true
saveExact: true
overrides:                 # security floors for transitive dependencies
  qs: ">=6.16.0 <7.0.0"
```

> **Format note:** `allowBuilds` is an object **map** (`name: true|false`), not a
> list. The legacy `onlyBuiltDependencies`/`neverBuiltDependencies` arrays were
> removed in pnpm v11.

### `overrides` — security floors for transitive dependencies
When a vulnerable package is reached only transitively and no direct-dependency
bump clears it, force the floor with an `overrides` entry and record the CVE in
a comment beside it. Re-check the entry when the direct dependency catches up, so
overrides don't outlive their reason.

### Node version — single source of truth
The Node runtime is pinned to an **exact** version — never major-only (`24`) or a
range. It lives in two files, but **`.nvmrc` is the single source of truth**:

- **`.nvmrc`** — the version you edit; switches a developer's local runtime
  (`nvm install && nvm use`), and the `Makefile` reads `NODE_VERSION` from it.
- **`package.json` `engines.node`** — the machine-checkable declaration package
  managers validate against. It is **generated from `.nvmrc`**, never edited by hand.

**Rule — to bump Node:** edit `.nvmrc` to the new exact version, run `make sync`
(which runs `pnpm run sync:node-pin` to rewrite `engines.node` from `.nvmrc`, via
`scripts/sync-node-pin.mjs`), then commit both files together. Because
`engines.node` is generated, the two cannot drift as long as you sync after every
`.nvmrc` change — and CI fails the build if you forget.

### pnpm version — single source of truth
The pnpm pin is **not** derived from `.nvmrc`. Its single source of truth is the
`packageManager` field in `package.json`.

**Rule — to bump pnpm:** run `corepack use pnpm@<version>`. That rewrites
`packageManager` **with an integrity hash**, which Corepack verifies when it
fetches the tarball. Never hand-edit the field, and never regenerate it from a
version variable: writing a bare `pnpm@<version>` drops the hash and silently
removes that verification.

There is no `engines.pnpm`. It would be a weaker duplicate of `packageManager`
— no hash, and free to drift — so the pin lives in exactly one place.

The `Makefile` **reads** `packageManager` to feed the Docker build arg, so the
container and the host agree without the version being written out twice. It
parses the field with `sed` rather than `node`, so `make install` still resolves
it before a Node runtime exists.

### `pnpm-lock.yaml` — lock file
- **Always commit.** Ensures reproducible builds and prevents supply-chain drift.

---

## Security Benefits

| Risk | Mitigation |
|------|-----------|
| Typosquatting | Lockfile + exact-pinned dependencies (no `^`/`~`) |
| Dependency confusion | Lockfile + HTTPS registry resolution |
| Unreviewed version drift | Exact pins + `saveExact: true` |
| Malicious install scripts | Build scripts blocked by default; `allowBuilds` whitelist |
| Freshly compromised releases | `minimumReleaseAge` quarantine window |
| Non-registry / tampered sub-deps | `blockExoticSubdeps: true` |
| Trust/provenance downgrade | `trustPolicy: no-downgrade` |
| Registry tampering (MITM) | HTTPS-only registry |
| Vulnerable transitive deps | `overrides` security floors |
| Known vulnerabilities | `pnpm audit` in CI |
| Accidental downgrades | Frozen lockfile in CI |
| Policy tampering by an agent | Deny rule + `check:deny-rules` CI guard |
