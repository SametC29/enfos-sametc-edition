// Explicitly reviewed native aliases only; never excuse a missing Lua class.
// Source: docs/audit/LUNA_NATIVE_SOURCE_2026-10-03.json (installed build 6943).
// SF source: docs/audit/SHADOW_FIEND_NATIVE_SOURCE_2026-10-04.json (build 6943).
// BB source: docs/audit/BRISTLEBACK_NATIVE_SOURCE_2026-10-04.json (build 6943).
// Slark source: docs/audit/SLARK_NATIVE_SOURCE_2026-10-04.json (build 6943).
// Tidehunter source: docs/audit/TIDEHUNTER_NATIVE_SOURCE_2026-10-04.json (build 6943).
// Ursa source: docs/audit/URSA_NATIVE_SOURCE_2026-10-04.json (build 6943).
// Anti-Mage source: docs/audit/ANTIMAGE_NATIVE_SOURCE_2026-10-04.json (build 6943).
export const nativeHeroAbilities = new Map([
  ['enfos_luna_moon_glaives', 'luna_moon_glaive'],
  ['enfos_luna_lunar_orbit', 'luna_lunar_orbit'],
  ['enfos_luna_lucent_beam', 'luna_lucent_beam'],
  ['enfos_luna_lunar_blessing', 'luna_lunar_blessing'],
  ['enfos_luna_eclipse', 'luna_eclipse'],
  ['enfos_sf_presence_of_the_dark_lord', 'nevermore_dark_lord'],
  ['enfos_bb_warpath', 'bristleback_warpath'],
  ['enfos_bb_native_hairball', 'bristleback_hairball'],
  ['enfos_slark_dark_pact', 'slark_dark_pact'],
  ['enfos_slark_pounce', 'slark_pounce'],
  ['enfos_slark_shadow_dance', 'slark_shadow_dance'],
  ['enfos_tide_gush', 'tidehunter_gush'],
  ['enfos_tide_kraken_shell', 'tidehunter_kraken_shell'],
  ['enfos_tide_anchor_smash', 'tidehunter_anchor_smash'],
  ['enfos_tide_ravage', 'tidehunter_ravage'],
  ['enfos_ursa_enrage', 'ursa_enrage'],
  ['enfos_ursa_overpower', 'ursa_overpower'],
  ['enfos_ursa_earthshock', 'ursa_earthshock'],
  ['enfos_am_blink', 'antimage_blink'],
]);

export function isVerifiedNativeAbility(id, definition) {
  return nativeHeroAbilities.has(id)
    && definition?.BaseClass === nativeHeroAbilities.get(id)
    && definition.ScriptFile === undefined;
}
