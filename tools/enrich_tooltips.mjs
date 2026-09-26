import fs from 'node:fs';
import path from 'node:path';
import { root, SOURCE_LANG } from './localization.mjs';

const turkishJsonPath = path.join(root, `localization/${SOURCE_LANG}.json`);
const data = JSON.parse(fs.readFileSync(turkishJsonPath, 'utf8'));

const labels = {
  // Juggernaut
  DOTA_Tooltip_Ability_enfos_juggernaut_blade_fury_radius: "ETKİ ALANI:",
  DOTA_Tooltip_Ability_enfos_juggernaut_blade_fury_duration: "SÜRE:",
  DOTA_Tooltip_Ability_enfos_juggernaut_blade_fury_damage_per_sec: "SANİYELİK HASAR:",
  DOTA_Tooltip_Ability_enfos_juggernaut_healing_ward_radius: "ETKİ ALANI:",
  DOTA_Tooltip_Ability_enfos_juggernaut_healing_ward_heal_pct: "% AZAMİ CAN İYİLEŞTİRME:",
  DOTA_Tooltip_Ability_enfos_juggernaut_healing_ward_duration: "SÜRE:",
  DOTA_Tooltip_Ability_enfos_juggernaut_blade_dance_crit_chance: "% KRİTİK İHTİMALİ:",
  DOTA_Tooltip_Ability_enfos_juggernaut_blade_dance_crit_mult: "% KRİTİK HASAR ÇARPANI:",
  DOTA_Tooltip_Ability_enfos_juggernaut_omni_slash_duration: "SÜRE:",
  DOTA_Tooltip_Ability_enfos_juggernaut_omni_slash_bonus_damage: "VURUŞ BAŞINA İLAVE HASAR:",
  DOTA_Tooltip_Ability_enfos_juggernaut_omni_slash_radius: "SIÇRAMA MENZİLİ:",
  DOTA_Tooltip_Ability_enfos_juggernaut_duelist_bonus_attack_speed: "İLAVE SALDIRI HIZI:",
  DOTA_Tooltip_Ability_enfos_juggernaut_duelist_bonus_ms_pct: "% İLAVE HAREKET HIZI:",

  // Drow Ranger
  DOTA_Tooltip_Ability_enfos_drow_frost_arrows_slow_pct: "% HAREKET YAVAŞLATMA:",
  DOTA_Tooltip_Ability_enfos_drow_frost_arrows_bonus_damage: "İLAVE HASAR:",
  DOTA_Tooltip_Ability_enfos_drow_frost_arrows_duration: "YAVAŞLATMA SÜRESİ:",
  DOTA_Tooltip_Ability_enfos_drow_gust_wave_distance: "DALGA MENZİLİ:",
  DOTA_Tooltip_Ability_enfos_drow_gust_silence_duration: "SUSTURMA SÜRESİ:",
  DOTA_Tooltip_Ability_enfos_drow_gust_knockback_distance: "GERİ SAVURMA:",
  DOTA_Tooltip_Ability_enfos_drow_multishot_arrow_count: "OK SAYISI:",
  DOTA_Tooltip_Ability_enfos_drow_multishot_channel_time: "ODAKLANMA SÜRESİ:",
  DOTA_Tooltip_Ability_enfos_drow_multishot_arrow_damage_pct: "% SALDIRI HASARI:",
  DOTA_Tooltip_Ability_enfos_drow_multishot_arrow_range: "MENZİL:",
  DOTA_Tooltip_Ability_enfos_drow_marksmanship_proc_chance: "% DELME ŞANSI:",
  DOTA_Tooltip_Ability_enfos_drow_marksmanship_bonus_damage: "İLAVE DELİCİ HASAR:",
  DOTA_Tooltip_Ability_enfos_drow_precision_aura_bonus_agility_pct: "% İLAVE ÇEVİKLİK:",
  DOTA_Tooltip_Ability_enfos_drow_precision_aura_bonus_range: "İLAVE SALDIRI MENZİLİ:",

  // Lina
  DOTA_Tooltip_Ability_enfos_lina_dragon_slave_damage: "HASAR:",
  DOTA_Tooltip_Ability_enfos_lina_dragon_slave_dragon_slave_distance: "MENZİL:",
  DOTA_Tooltip_Ability_enfos_lina_light_strike_array_radius: "ETKİ ALANI:",
  DOTA_Tooltip_Ability_enfos_lina_light_strike_array_damage: "HASAR:",
  DOTA_Tooltip_Ability_enfos_lina_light_strike_array_stun_duration: "SERSEMLETME SÜRESİ:",
  DOTA_Tooltip_Ability_enfos_lina_fiery_soul_fiery_soul_attack_speed_bonus: "YÜK BAŞINA SALDIRI HIZI:",
  DOTA_Tooltip_Ability_enfos_lina_fiery_soul_fiery_soul_move_speed_bonus: "% YÜK BAŞINA HAREKET HIZI:",
  DOTA_Tooltip_Ability_enfos_lina_fiery_soul_fiery_soul_max_stacks: "AZAMİ YÜK:",
  DOTA_Tooltip_Ability_enfos_lina_fiery_soul_fiery_soul_stack_duration: "YÜK SÜRESİ:",
  DOTA_Tooltip_Ability_enfos_lina_laguna_blade_damage: "HEDEF HASARI:",
  DOTA_Tooltip_Ability_enfos_lina_laguna_blade_overflow_radius: "TAŞKIN ALANI:",
  DOTA_Tooltip_Ability_enfos_lina_laguna_blade_overflow_damage_pct: "% TAŞKIN HASARI:",
  DOTA_Tooltip_Ability_enfos_lina_combustion_spell_amp: "% BÜYÜ GÜÇLENDİRMESİ:",
  DOTA_Tooltip_Ability_enfos_lina_combustion_burn_dps: "SANİYELİK YANMA HASARI:",

  // Omniknight
  DOTA_Tooltip_Ability_enfos_omni_purification_heal_amount: "İYİLEŞTİRME:",
  DOTA_Tooltip_Ability_enfos_omni_purification_damage: "SAF ALAN HASARI:",
  DOTA_Tooltip_Ability_enfos_omni_purification_radius: "HASAR ALANI:",
  DOTA_Tooltip_Ability_enfos_omni_repel_bonus_hp_regen: "CAN YENİLENMESİ:",
  DOTA_Tooltip_Ability_enfos_omni_repel_bonus_strength: "İLAVE GÜÇ:",
  DOTA_Tooltip_Ability_enfos_omni_repel_bonus_armor: "İLAVE ZIRH:",
  DOTA_Tooltip_Ability_enfos_omni_repel_duration: "SÜRE:",
  DOTA_Tooltip_Ability_enfos_omni_degen_aura_radius: "ETKİ ALANI:",
  DOTA_Tooltip_Ability_enfos_omni_degen_aura_slow_pct: "% HAREKET YAVAŞLATMA:",
  DOTA_Tooltip_Ability_enfos_omni_degen_aura_attack_slow: "SALDIRI HIZI YAVAŞLATMA:",
  DOTA_Tooltip_Ability_enfos_omni_guardian_angel_duration: "SÜRE:",
  DOTA_Tooltip_Ability_enfos_omni_guardian_angel_radius: "ETKİ ALANI:",
  DOTA_Tooltip_Ability_enfos_omni_guardian_angel_bonus_hp_regen: "CAN YENİLENMESİ:",
  DOTA_Tooltip_Ability_enfos_omni_hammer_of_purity_bonus_pure_damage: "İLAVE SAF HASAR:",
  DOTA_Tooltip_Ability_enfos_omni_hammer_of_purity_slow_pct: "% HAREKET YAVAŞLATMA:",
  DOTA_Tooltip_Ability_enfos_omni_hammer_of_purity_slow_duration: "YAVAŞLATMA SÜRESİ:"
};

// Also add lowercase versions if any UI references them
for (const [k, v] of Object.entries(labels)) {
  data.Tokens[k] = v;
  const lowerKey = k.replace('DOTA_Tooltip_Ability_', 'DOTA_Tooltip_ability_');
  data.Tokens[lowerKey] = v;
}

fs.writeFileSync(turkishJsonPath, JSON.stringify(data, null, 2) + '\n', 'utf8');
console.log(`Enriched turkish.json with ${Object.keys(labels).length} special value display labels.`);
