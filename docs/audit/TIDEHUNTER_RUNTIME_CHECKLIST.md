# Tidehunter owner runtime checklist

Status: OWNER_RUNTIME PENDING. Gameplay source revision: `447084a`.
Installed reference: Dota ClientVersion6943 / SourceRevision11069754.
Owner launches/controls Dota; no agent launch or live control is authorized.
Start a fresh match after KV/asset changes. Record build, tested revision,
rank, upgrades, team and relevant VConsole excerpt for each result.

| Test | Measurable expected result | Result |
|---|---|---|
| Progression | Rank1 and10 available within level50; R gates5/10/…/50. Fifth free rank separate from49 spendable points; no talents or account progression. | PENDING |
| Q normal | Mana/CD match current rank; no damage before projectile impact; one valid enemy hit, armor/slow applied. Dodged/lost/dead/friendly target produces no impact. Test absorb/reflect separately. | PENDING |
| Q Scepter/Blessing | Point cursor replaces unit cursor. Pierces multiple enemies, range2200/width radius260/speed1500. Base cooldown min(normal,7); rank10 remains6 before other cooldown modifiers. Dropping Scepter restores ordinary cast; in-flight wave remains piercing. | PENDING |
| W block/regen | Compare received physical hits and health regeneration at rank1/10 with and without Break. No learned-source bonus when W is unlearned/removed. Compare current Strength contribution. | PENDING |
| W cleanse | Sustained positive damage crosses450 and removes strong-dispellable effects. Seven damage-free game-time seconds reset accumulation; pause does not consume this window. Observe remainder, lethal hit, self/allied/reflected damage and respawn. | PENDING |
| Shard | Cleanse with learned E produces one visible/audible reactive Smash at50% computed damage and ordinary E debuff; repeated cleanses within5s do not retrigger. Active E mana/CD unaffected; no generic350HP/15% reflection. Test item removal and Break. | PENDING |
| E | Damage = current average attack damage + ranked bonus +75% Strength before mitigation. Radius400 and effect edge agree; debuff affects base attack damage, not all damage. Test ordinary/immune/Boss targets and basic dispel. | PENDING |
| R | Inner ring immediate; outer rings visibly advance through1.3s. Stationary far target not hit instantly. Moving target receives at most one hit per cast; Refresher casts remain independent and origin stays fixed. | PENDING |
| R control | Boss stun no more than1s before status resistance. Basic dispel does not remove stun; strong dispel does. Test high resistance/immunity, source death/removal and pause; no lingering context errors. | PENDING |
| Fifth | Own health/armor and enemy slow/base-damage values match rank. Break disables owner effects; engine aura fade measured. Rank-up refresh, entering/leaving aura, two Tidehunters, illusions, immune targets and death/respawn tested separately. | PENDING |
| Presentation | Q/E/R cast animation, native sound and visible effects; reactive E gesture. Hover four secondary debuffs in EN/TR/RU/zh-CN: correct names/icons, signed current property values, no raw tokens. | PENDING |
| Cleanup/reconnect | Repeat casts and upgrade changes, kill targets during impacts, reconnect. No duplicated ranks/modifiers, endless audio/effects or accumulating cast contexts. | PENDING |
| Cold start / dense waves | Fresh match loads all particles/banks. Dense wave combat adds no relevant Lua traceback, missing resource/modifier/particle/sound warning or sustained log spam; capture performance observations. | PENDING |

Damage assertions must account for armor, magic resistance, spell amplification,
other modifiers and Boss rules. Mocks prove wiring/control flow only. Record
PASS/FAIL/PARTIAL with observations, never convert an untested row to PASS.
