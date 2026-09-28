# Hero reference workspace contract

Read the repository root AGENTS.md, `../HERO_ABILITY_DEVELOPMENT_GUIDELINES.md`
and relevant parts of `../HERO_ABILITY_REFERENCE.md`. Use README.md to select the
hero. Read its own AGENTS.md and ABILITIES.md before touching its kit.

These nested files automatically govern documentation beneath this directory.
The root contract explicitly requires reading them for shared gameplay/KV edits;
do not assume a docs-only scope automatically covers `game/` or `content/`.

- Preserve existing stable hero/ability IDs and production authority.
- Generated inventory is not a second content source or a runtime certificate.
- Refresh generated blocks with `node tools/hero_reference_docs.mjs --refresh`;
  preserve handwritten classification, resource records and test evidence.
- Classification may remain UNASSESSED during discovery, but a changed ability
  requires evidence-backed KEEP/TUNE/PVE-CONVERT/REPLACE before implementation.
- Never mark VFX/SFX/engine PASS from grep, asset existence or mocks.
- Cite source file, build/revision, observed date and evidence per acceptance area.
- Native slot and icon similarity do not prove a native counterpart.
- Use the shared reference for technical rules instead of copying it 40 times.
- Documentation generation does not authorize mass hero repairs or final balance.
