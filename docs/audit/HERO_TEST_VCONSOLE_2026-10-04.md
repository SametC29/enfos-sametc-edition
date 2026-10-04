# Hero test VConsole review — 2026-10-04

Source: owner-provided VConsole text attachment (SHA256
`A43657E041E5DC8E3AEFA5152C0BBEFE10CB6ED00479A6A0CF73AED9CD854B8A`).
Read 7,900+ lines; source line numbers below refer to the attachment. This is
engine evidence for observed events, not blanket ability acceptance.

Seven test sessions reached `hero_ready` at level 10 with 9 unspent points and
both upgrade flags: Bristleback (1648), Slark (2651), Luna (3610), Shadow Fiend
(4535), Tidehunter (5414), Ursa (6674), Anti-Mage (7870). No per-skill VFX, SFX or damage
PASS can be inferred from these readiness markers.

Confirmed failures:

- Bristleback return button: event entered Lua three times (1854, 1861, 1871)
  but every `SendToConsole` attempt was rejected with `missing required FCVAR
  flag` (1855, 1862, 1872). Owner resumed via manual console command (1890).
  Repaired to reuse the authored selection screen and engine hero replacement.
  New behavior remains live-test pending.
- Tidehunter: ten `Script Runtime Error` messages at 5444–5498 from
  `abilities/heroes/tidehunter/modifiers.lua:71`, calling `c:HasShard()` on an
  engine hero handle without that method. Repaired to use the existing
  AghanimManager Shard check. Runtime regression pending.
- Repeated `GetAbilityByIndex` warnings for indices 23–31 came from test-room
  refresh. Scan bounded at index 22.

Other observations for follow-up: the test map lacks an overview resource
(`resource/overviews/enfos_test.txt` warning each load); some custom modifiers
were reported unknown by the client after Tidehunter setup; Ursa and Tidehunter
reached level 11 later in testing despite targets being configured for zero
death XP. The latter may involve native hero-kill XP, and its cause needs an
engine trace before claiming a strict level-10 cap. Engine resource warnings
outside these paths were not classified as ability failures.
