# Native Glyph activation — 2026-10-01

Status: **CODE AND MOCK CHECKS PASS; OWNER ENGINE TEST PENDING**.

Source2Viewer-CLI 19.2 decompiled the installed Valve resource
`panorama/layout/hud/dota_hud_glyph.vxml_c` from the base-game VPK without
launching Dota. The layout places `DOTAHUDActivateGlyph()` on `NormalRoot`,
above the `GlyphButton` child. The spectator roots are `RadiantRoot` and
`DireRoot`, with `RadiantGlyphButton` and `DireGlyphButton` children.

The old opener override on `glyph`, and the later inner-button-only override,
did not replace the actual native parent activation. The controller now binds
the verified roots, enables their input despite native cooldown state, and
disables child hit testing to avoid two toggle handlers receiving one click.
Layouts without these roots retain a guarded button/container fallback.
Game and content scripts are identical. No new UI button or gameplay power is
introduced; existing requested HUD removals are unchanged.

Four HUD tests pass. The behavior test disables the native root, installs a
native activation that would fail the test if called, and verifies the
replacement opens/closes Spellbringer once per activation. It also checks that
the child has no second activation handler. These mocks do not establish
Source 2 hit testing, native C++ input handling or HUD rebuild acceptance.

Owner test: after restarting the local match, click the Glyph once while ready
and once while its native charge is unavailable. Spellbringer must toggle once
per click, and Fortification must not fire. Repeat with the minimap on the other
side and after a HUD rebuild/reconnect. No Dota launch or Workshop upload was
performed by Codex.
