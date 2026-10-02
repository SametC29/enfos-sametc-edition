# Sven owner runtime checklist

Current source review: [2026-10-02](SVEN_REOPENED_REVIEW_2026-10-02.md).
All rows **PENDING** until owner observation plus current-build VConsole evidence.
Start a fresh local match; reloading an old match does not establish resource/rank
acceptance. Record build, ability ranks and Shard/Scepter/Blessing state.

| Check | Expected behavior | Status |
| --- | --- | --- |
| Start and progression | Level6, five spendable points, fifth passive rank1 free; max level50, all five skills max10. No talent tree/permanent bonuses. | PENDING |
| Q rank1/10 | Hammer travels, impact sound/flash at target away from map origin, magical AoE and stun; bosses at most0.6s before resistance. Lethal victims are not stunned. | PENDING |
| Q target edges | No explosion after dodge/target removal; no friendly primary detonation after team change. Test absorb/reflect and immunity separately. | PENDING |
| W self/ally | Cast head burst/audio; armor/speed increase; visible overhead armor shield on each buffed recipient, tooltip shows current armor and remaining barrier. | PENDING |
| W barrier | Damage consumes barrier, remainder decreases; recast replenishes without extra persistent shields. Armor buff lasts after barrier depletion. | PENDING |
| W taunt | Normal creeps attack Sven, runners unaffected, boss duration25%. Expiry/purge/Sven death release owned forced attack. Two Svens recasting switch target correctly. | PENDING |
| Shard | Adds25% Sven maxHP barrier per recipient; reflects40% physical damage actually taken, no magical/friendly/reflection recursion; fifth regen doubled strictly below40% HP. | PENDING |
| E normal/R | Lethal primary still cleaves others; attack damage/armor/cone fit rank curve. Native cleave effect at hit, stronger R variant. Break/illusions do not cleave. | PENDING |
| R rank1/10 | Damage/STR/defense increase, native burst and sustained transform, every1.5s physical pulse within450; expiration restores stats. Main buff cannot be purged. | PENDING |
| Scepter/Blessing | R +5s/+50% status resistance, nearby allied heroes +50% their own base damage/+10 armor refreshed1.8s; Q teleports during R. Verify removal/expiry and two Svens. | PENDING |
| Fifth passive | Live regen/maxHP/status resistance track rank; Break disables all three, removing source grants none; death/reconnect do not duplicate free ranks/points. | PENDING |
| Localization/audio/cleanup | EN/TR/RU/zh-CN tooltip names and values visible, all intended sounds audible, no errors or lingering/duplicated effects across recasts/death/reconnect. | PENDING |

W is a defense/taunt ability, not a direct damage spell. Without Shard reflection,
pressing W alone is not expected to reduce enemy HP. Its visible armor shield denotes
the continuing armor buff; the tooltip's remaining barrier is the absorption amount.
