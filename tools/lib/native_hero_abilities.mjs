// Explicitly reviewed native aliases only; never excuse a missing Lua class.
// Source: docs/audit/LUNA_NATIVE_SOURCE_2026-10-03.json (installed build 6943).
export const nativeHeroAbilities = new Map([
  ['enfos_luna_moon_glaives', 'luna_moon_glaive'],
]);

export function isVerifiedNativeAbility(id, definition) {
  return nativeHeroAbilities.has(id)
    && definition?.BaseClass === nativeHeroAbilities.get(id)
    && definition.ScriptFile === undefined;
}
