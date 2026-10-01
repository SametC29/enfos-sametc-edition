// Read numeric ability values from the current AbilityValues schema while
// retaining AbilitySpecial support for legacy definitions still in the addon.
export function getAbilityValues(definition = {}) {
  const values = {};
  for (const [key, raw] of Object.entries(definition.AbilityValues || {})) {
    if (raw && typeof raw === 'object') {
      if (raw.value !== undefined) values[key] = String(raw.value);
    } else if (raw !== undefined && raw !== null) {
      values[key] = String(raw);
    }
  }
  for (const row of Object.values(definition.AbilitySpecial || {})) {
    for (const [key, raw] of Object.entries(row || {})) {
      if (key !== 'var_type' && key !== 'LinkedSpecialBonus' && raw !== undefined && raw !== null) {
        values[key] = String(raw);
      }
    }
  }
  return values;
}
