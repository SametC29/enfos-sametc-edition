# RELEASE PROCESS — DEV/BETA and LIVE

## Overview

This project maintains separate DEV/BETA and LIVE tracks for Workshop addon publishing.

- **DEV/BETA**: Risky or untested changes land here first.
- **LIVE**: Promoted from DEV/BETA after passing all gates.

## DEV/BETA → LIVE Promotion Checklist

Before promoting to LIVE, verify:

- [ ] **Smoke test**: Core game loop plays through representative waves
- [ ] **Compatibility audit**: All 30 Ascended parent items exist; hero selection works; courier works; shop works
- [ ] **Economy simulation**: Income targets met for 1–5 players across all difficulties
- [ ] **Localization validation**: All 4 languages pass coverage validator, no missing keys
- [ ] **Performance profiling**: No unbounded entity growth; cap system functional; no server hitches
- [ ] **Persistence migration**: Schema version incremented if changed; migration tested
- [ ] **Rollback plan**: Previous LIVE version can be restored within minutes
- [ ] **Patch notes**: Prepared in all 4 languages

## Git Branch Strategy

- `main` — production-ready, maps to LIVE Workshop addon
- `dev` — active development, maps to DEV/BETA Workshop addon
- Feature branches off `dev` for larger work

## Workshop Publishing

```
# DEV/BETA publish (from dev branch)
# Use Dota 2 Workshop Tools → Publish → select DEV addon ID

# LIVE promote (from main branch after merge)
# Use Dota 2 Workshop Tools → Publish → select LIVE addon ID
```

## Rollback

If a LIVE publish introduces a critical issue:
1. `git revert <bad-commit>` on main
2. Run full checks
3. Re-publish to LIVE
4. Never force-push or rewrite published history

## Version Numbering

Format: `MAJOR.MINOR.PATCH-tag`
- `0.x.y-dev` — Pre-release development
- `1.0.0` — First public LIVE release
- Tags: `-dev`, `-beta`, `-rc1`
