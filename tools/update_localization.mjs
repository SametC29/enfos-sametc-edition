import fs from 'node:fs';
import path from 'node:path';
import { root, SOURCE_LANG } from './localization.mjs';

// ─────────────────────────────────────────────────────────
// Creep / Boss ability tokens — ONLY TURKISH (source of truth)
// Other languages auto-mirror from Turkish via localization.mjs
// ─────────────────────────────────────────────────────────

const abilityTokens = {
  DOTA_Tooltip_Ability_enfos_creep_runner_passive: "Depar",
  DOTA_Tooltip_Ability_enfos_creep_runner_passive_Description: "Hareket hızını {{bonus_ms}} artırır ve birim çarpışmasını yok sayar.",
  DOTA_Tooltip_Ability_enfos_creep_frostguard_aura: "Ayaz Halesi",
  DOTA_Tooltip_Ability_enfos_creep_frostguard_aura_Description: "{{radius}} menzildeki düşmanların hareket hızını %{{slow_pct|percent}} yavaşlatır.",
  DOTA_Tooltip_Ability_enfos_creep_venomous_poison: "Zehirli Vuruş",
  DOTA_Tooltip_Ability_enfos_creep_venomous_poison_Description: "Saldırılar hedefe {{duration}} saniye boyunca saniyede {{poison_damage}} büyü hasarı verir.",
  DOTA_Tooltip_Ability_enfos_creep_healer_heal: "Şifa Dalgası",
  DOTA_Tooltip_Ability_enfos_creep_healer_heal_Description: "{{radius}} menzil içindeki dost minyonları {{heal_amount}} can iyileştirir.",
  DOTA_Tooltip_Ability_enfos_creep_shieldbearer_carapace: "Dikenli Zırh",
  DOTA_Tooltip_Ability_enfos_creep_shieldbearer_carapace_Description: "+{{bonus_armor}} zırh kazandırır ve gelen fiziksel saldırı hasarını {{damage_block}} engeller.",
  DOTA_Tooltip_Ability_enfos_creep_mindstealer_burn: "Mana Yakımı",
  DOTA_Tooltip_Ability_enfos_creep_mindstealer_burn_Description: "Saldırılarda {{mana_burn}} mana yakar ve {{burn_damage}} hasar verir.",
  DOTA_Tooltip_Ability_enfos_creep_conqueror_slam: "Savaş Ezmesi",
  DOTA_Tooltip_Ability_enfos_creep_conqueror_slam_Description: "Yere vurarak {{radius}} alanda {{damage}} fiziksel hasar verir ve hedefleri {{stun_duration}} saniye sersemletir.",
  DOTA_Tooltip_Ability_enfos_creep_assassin_stealth: "Gölge Saldırısı",
  DOTA_Tooltip_Ability_enfos_creep_assassin_stealth_Description: "Gizlilikten çıkışta +{{bonus_damage}} saldırı hasarı sağlar.",
  DOTA_Tooltip_Ability_enfos_creep_summoner_raise: "Ölüleri Dirilt",
  DOTA_Tooltip_Ability_enfos_creep_summoner_raise_Description: "{{duration}} saniye süren {{summon_count}} iskelet savaşçı diriltir.",
  DOTA_Tooltip_Ability_enfos_creep_spellguard_ward: "Büyü Kalkanı",
  DOTA_Tooltip_Ability_enfos_creep_spellguard_ward_Description: "Pasif olarak +%{{magic_resist}} büyü direnci sağlar.",
  DOTA_Tooltip_Ability_enfos_creep_reflector_spikes: "Yansıtıcı Dikenler",
  DOTA_Tooltip_Ability_enfos_creep_reflector_spikes_Description: "Alınan hasarın %{{reflect_pct}} kadarını pasif olarak yansıtır.",
  DOTA_Tooltip_Ability_enfos_creep_exploder_burst: "Uçucu Patlama",
  DOTA_Tooltip_Ability_enfos_creep_exploder_burst_Description: "Ölünce {{radius}} yarıçapta {{damage}} büyü hasarı patlaması oluşturur.",
  DOTA_Tooltip_Ability_enfos_creep_bloodbeast_feast: "Kan Ziyafeti",
  DOTA_Tooltip_Ability_enfos_creep_bloodbeast_feast_Description: "Verilen saldırı hasarının %{{lifesteal_pct}} kadarını can olarak yeniler.",
  DOTA_Tooltip_Ability_enfos_creep_cursecaster_amplify: "Hassasiyet Laneti",
  DOTA_Tooltip_Ability_enfos_creep_cursecaster_amplify_Description: "Hedefin {{duration}} saniye boyunca %{{damage_amplification}} daha fazla hasar almasını sağlar.",
  DOTA_Tooltip_Ability_enfos_boss_stonebreaker_slam: "Zemin Kırıcı",
  DOTA_Tooltip_Ability_enfos_boss_stonebreaker_slam_Description: "Yere vurarak {{radius}} menzilde {{damage}} fiziksel hasar verir ve {{stun_duration}} saniye sersemletir.",
  DOTA_Tooltip_Ability_enfos_boss_bloodfang_enrage: "Kan Diş Öfkesi",
  DOTA_Tooltip_Ability_enfos_boss_bloodfang_enrage_Description: "Canı %{{enrage_hp_pct}} altına indiğinde +{{bonus_attack_speed}} saldırı hızı ve %{{bonus_lifesteal}} can çalma kazanır.",

  // System / wave UI tokens
  enfos_cap_overflow_warning: "BİRİM KAPASİTESİ AŞILDI! Yaratıklar engellendi ve Can kaybedildi!",
  enfos_wave_cleared: "Dalga Temizlendi! Sıradaki saldırıya hazırlanın."
};

// Generate wave titles and descriptions (1..60)
for (let i = 1; i <= 60; i++) {
  const isBoss = (i % 5 === 0);
  const title = isBoss ? `Boss Karşılaşması: Dalga ${i}` : `Saldırı: Dalga ${i}`;
  abilityTokens[`enfos_wave_title_${i}`] = title;
  abilityTokens[`enfos_wave_desc_${i}`] = title;
}

// ─────────────────────────────────────────────────────────
// Update ONLY Turkish source JSON
// ─────────────────────────────────────────────────────────
const filePath = path.join(root, `localization/${SOURCE_LANG}.json`);
const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

for (const [k, v] of Object.entries(abilityTokens)) {
  data.Tokens[k] = v;
}

fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n');
console.log(`Updated localization/${SOURCE_LANG}.json with ${Object.keys(data.Tokens).length} tokens (source of truth).`);
console.log(`Other languages will auto-mirror when localization.mjs runs.`);
