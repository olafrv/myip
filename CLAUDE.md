# Claude Code Instructions

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

## Version pins

`.nvmrc` is the single source of truth for the Node version; `engines.node` is
generated from it. To bump Node: edit `.nvmrc`, run `make sync`, commit both
files together. Never hand-edit `engines.node`.

The pnpm pin is separate: `PNPM_VERSION` in the `Makefile` is its source of
truth, and `make sync` writes it to `engines.pnpm`, `packageManager` and the
Docker build arg.

## Tests

`make test` needs Docker Compose, a `.env`, TLS certificates and the GeoLite2
database, so it does not run in CI and will not run in a bare sandbox.
