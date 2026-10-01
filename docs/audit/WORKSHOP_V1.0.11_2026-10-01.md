# Workshop V1.0.11 publication — 2026-10-01

The owner explicitly requested uploading the current build to Workshop and GitHub.
This request authorizes this publication only; it does not restore standing
publication permission. Gameplay testing was not performed or claimed.

- Source and publication helper committed and pushed as `4211943` on
  `codex/project-hardening`.
- Full `npm run check` and installed-native-model verification passed.
- Independent candidate package verification passed: 103 files, 10 protected
  map files and PNG preview. No map recompilation or Dota launch was performed.
- Rollback package preserved at `release/rollback/V1.0.10-pre-v1.0.11/`.
- Candidate archive: 23506203 bytes; SHA-256
  `8e96d8de6a76de5953d787db0959e9e2e801761f3322ff05399b6785211434b9`.
- Official Steamworks desktop-session upload returned result 1 for the existing
  item `3809160125`, public visibility requested, no legal-agreement action.
  No password or credential files were accessed.
- Official public Steam API returned result 1, visibility 0, title
  `Enfos Team Survival - SametC Edition V1.0.11`, `time_updated` 1790887304,
  content handle `6400994044218353951`, combined payload size 23506391 bytes.
- A newly bootstrapped, anonymous SteamCMD client successfully downloaded the
  item, but delivered the previous V1.0.10 archive: 23405123 bytes; SHA-256
  `01ac3fe7e87ee8d33e42976e0f45ada9343c734e5781dab51efc17cc241b2336`.
  The download therefore does **not** match the candidate. Upload acceptance and
  public metadata are confirmed; delivery of V1.0.11 to players remains pending.
  The cause of this delivery difference has not been established.

Local upload, public API and download records are under `release/`; they are not
committed. Runtime visibility, native special-creep behavior, VFX and balance
acceptance remain pending owner Dota testing.

Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3809160125
