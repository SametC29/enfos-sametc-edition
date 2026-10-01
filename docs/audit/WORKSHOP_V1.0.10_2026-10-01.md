# Workshop V1.0.10 publication — 2026-10-01

Updated the existing public item
[3809160125](https://steamcommunity.com/sharedfiles/filedetails/?id=3809160125)
under the owner's existing commit/deploy/Workshop authorization without waiting
for gameplay tests. No Dota was launched or controlled.

- Reveal native aura repair committed/pushed as `554eb28`.
- Full working-tree automated checks: zero failures. Isolated committed
  candidate: focused Reveal regression and 14 audit mock checks passed.
- Working-tree package includes preserved contributor changes, as previous
  releases did; these were not committed wholesale.
- Previous package/config retained in
  `release/rollback/V1.0.9-pre-v1.0.10-reveal`.
- Independent package check: 99 files, 10 protected maps, preview valid.
- Archive 23405123 bytes, SHA256
  `01ac3fe7e87ee8d33e42976e0f45ada9343c734e5781dab51efc17cc241b2336`.
- SteamCMD: Committing update...Success; upload log OK at 20:48 Istanbul,
  manifest `7179987740889975828`.
- Official public Steam API: result 1, visibility 0, title V1.0.10,
  time_updated 1790876882, same manifest, combined payload size 23405311 bytes.
- Upload acceptance/public metadata confirmed. Fresh client download equality
  and Reveal engine visibility remain unverified. Boss death/no-revival and
  talent '+' absence were separately confirmed by the owner.

Public API/package records live under `release/workshop`; credential cache is
not committed. Current research and pending visibility checks are recorded in
REVEAL_NATIVE_AURA_2026-10-01.md.
