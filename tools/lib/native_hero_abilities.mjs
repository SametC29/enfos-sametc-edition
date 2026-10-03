// Explicitly reviewed native aliases only; never excuse a missing Lua class.
// Source: docs/audit/LUNA_NATIVE_SOURCE_2026-10-03.json (installed build 6943).
// SF source: docs/audit/SHADOW_FIEND_NATIVE_SOURCE_2026-10-04.json (build 6943).
export const nativeHeroAbilities = new Map([
  ['enfos_luna_moon_glaives', 'luna_moon_glaive'],
  ['enfos_luna_lunar_orbit', 'luna_lunar_orbit'],
  ['enfos_luna_lucent_beam', 'luna_lucent_beam'],
  ['enfos_luna_lunar_blessing', 'luna_lunar_blessing'],
  ['enfos_luna_eclipse', 'luna_eclipse'],
  ['enfos_sf_presence_of_the_dark_lord', 'nevermore_dark_lord'],
]);

export function isVerifiedNativeAbility(id, definition) {
  return nativeHeroAbilities.has(id)
    && definition?.BaseClass === nativeHeroAbilities.get(id)
    && definition.ScriptFile === undefined;
}
