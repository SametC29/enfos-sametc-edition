import fs from 'node:fs';
import path from 'node:path';
import { root, languages } from './localization.mjs';

const abilityTokens = {
  english: {
    DOTA_Tooltip_Ability_enfos_creep_runner_passive: "Sprint",
    DOTA_Tooltip_Ability_enfos_creep_runner_passive_Description: "Increases movement speed by {{bonus_ms}} and ignores unit collision.",
    DOTA_Tooltip_Ability_enfos_creep_frostguard_aura: "Frost Aura",
    DOTA_Tooltip_Ability_enfos_creep_frostguard_aura_Description: "Slows nearby enemy movement speed by {{slow_pct|percent}} within {{radius}} radius.",
    DOTA_Tooltip_Ability_enfos_creep_venomous_poison: "Venomous Strike",
    DOTA_Tooltip_Ability_enfos_creep_venomous_poison_Description: "Attacks apply a poison dealing {{poison_damage}} magical damage per second for {{duration}} seconds.",
    DOTA_Tooltip_Ability_enfos_creep_healer_heal: "Healing Wave",
    DOTA_Tooltip_Ability_enfos_creep_healer_heal_Description: "Heals nearby allied creeps for {{heal_amount}} health within {{radius}} radius.",
    DOTA_Tooltip_Ability_enfos_creep_shieldbearer_carapace: "Spiked Carapace",
    DOTA_Tooltip_Ability_enfos_creep_shieldbearer_carapace_Description: "Grants +{{bonus_armor}} armor and blocks {{damage_block}} physical attack damage.",
    DOTA_Tooltip_Ability_enfos_creep_mindstealer_burn: "Mana Burn",
    DOTA_Tooltip_Ability_enfos_creep_mindstealer_burn_Description: "Attacks burn {{mana_burn}} mana and deal {{burn_damage}} damage.",
    DOTA_Tooltip_Ability_enfos_creep_conqueror_slam: "War Stomp",
    DOTA_Tooltip_Ability_enfos_creep_conqueror_slam_Description: "Slams the ground dealing {{damage}} physical damage and stunning for {{stun_duration}} seconds within {{radius}} radius.",
    DOTA_Tooltip_Ability_enfos_creep_assassin_stealth: "Shadow Strike",
    DOTA_Tooltip_Ability_enfos_creep_assassin_stealth_Description: "Grants +{{bonus_damage}} bonus attack damage from stealth.",
    DOTA_Tooltip_Ability_enfos_creep_summoner_raise: "Raise Dead",
    DOTA_Tooltip_Ability_enfos_creep_summoner_raise_Description: "Raises {{summon_count}} temporary skeletons lasting {{duration}} seconds.",
    DOTA_Tooltip_Ability_enfos_creep_spellguard_ward: "Spell Shield",
    DOTA_Tooltip_Ability_enfos_creep_spellguard_ward_Description: "Passively grants +{{magic_resist}}% magic resistance.",
    DOTA_Tooltip_Ability_enfos_creep_reflector_spikes: "Spiked Hide",
    DOTA_Tooltip_Ability_enfos_creep_reflector_spikes_Description: "Passively reflects {{reflect_pct}}% of received damage.",
    DOTA_Tooltip_Ability_enfos_creep_exploder_burst: "Volatile Burst",
    DOTA_Tooltip_Ability_enfos_creep_exploder_burst_Description: "Explodes upon death dealing {{damage}} magical damage within {{radius}} radius.",
    DOTA_Tooltip_Ability_enfos_creep_bloodbeast_feast: "Blood Feast",
    DOTA_Tooltip_Ability_enfos_creep_bloodbeast_feast_Description: "Passively heals for {{lifesteal_pct}}% of attack damage dealt.",
    DOTA_Tooltip_Ability_enfos_creep_cursecaster_amplify: "Vulnerability Curse",
    DOTA_Tooltip_Ability_enfos_creep_cursecaster_amplify_Description: "Curses target to take {{damage_amplification}}% amplified damage for {{duration}} seconds.",
    DOTA_Tooltip_Ability_enfos_boss_stonebreaker_slam: "Ground Slam",
    DOTA_Tooltip_Ability_enfos_boss_stonebreaker_slam_Description: "Slams the ground dealing {{damage}} physical damage and stunning for {{stun_duration}} seconds within {{radius}} radius.",
    DOTA_Tooltip_Ability_enfos_boss_bloodfang_enrage: "Bloodfang Enrage",
    DOTA_Tooltip_Ability_enfos_boss_bloodfang_enrage_Description: "When health falls below {{enrage_hp_pct}}%, gains +{{bonus_attack_speed}} attack speed and {{bonus_lifesteal}}% lifesteal."
  },
  turkish: {
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
    DOTA_Tooltip_Ability_enfos_boss_bloodfang_enrage_Description: "Canı %{{enrage_hp_pct}} altına indiğinde +{{bonus_attack_speed}} saldırı hızı ve %{{bonus_lifesteal}} can çalma kazanır."
  },
  russian: {
    DOTA_Tooltip_Ability_enfos_creep_runner_passive: "Спринт",
    DOTA_Tooltip_Ability_enfos_creep_runner_passive_Description: "Увеличивает скорость передвижения на {{bonus_ms}} и игнорирует столкновения.",
    DOTA_Tooltip_Ability_enfos_creep_frostguard_aura: "Аура мороза",
    DOTA_Tooltip_Ability_enfos_creep_frostguard_aura_Description: "Замедляет скорость передвижения врагов в радиусе {{radius}} на {{slow_pct|percent}}.",
    DOTA_Tooltip_Ability_enfos_creep_venomous_poison: "Ядовитый удар",
    DOTA_Tooltip_Ability_enfos_creep_venomous_poison_Description: "Атаки накладывают яд, наносящий {{poison_damage}} магического урона в секунду в течение {{duration}} сек.",
    DOTA_Tooltip_Ability_enfos_creep_healer_heal: "Целительная волна",
    DOTA_Tooltip_Ability_enfos_creep_healer_heal_Description: "Исцеляет союзных крипов в радиусе {{radius}} на {{heal_amount}} здоровья.",
    DOTA_Tooltip_Ability_enfos_creep_shieldbearer_carapace: "Шипастый панцирь",
    DOTA_Tooltip_Ability_enfos_creep_shieldbearer_carapace_Description: "Дает +{{bonus_armor}} к броне и блокирует {{damage_block}} физического урона от атак.",
    DOTA_Tooltip_Ability_enfos_creep_mindstealer_burn: "Сжигание маны",
    DOTA_Tooltip_Ability_enfos_creep_mindstealer_burn_Description: "Каждая атака сжигает {{mana_burn}} маны и наносит {{burn_damage}} урона.",
    DOTA_Tooltip_Ability_enfos_creep_conqueror_slam: "Военный топот",
    DOTA_Tooltip_Ability_enfos_creep_conqueror_slam_Description: "Ударяет по земле, нанося {{damage}} физического урона и оглушая на {{stun_duration}} сек в радиусе {{radius}}.",
    DOTA_Tooltip_Ability_enfos_creep_assassin_stealth: "Удар из тени",
    DOTA_Tooltip_Ability_enfos_creep_assassin_stealth_Description: "Дает +{{bonus_damage}} к урону от атаки из невидимости.",
    DOTA_Tooltip_Ability_enfos_creep_summoner_raise: "Воскрешение мертвых",
    DOTA_Tooltip_Ability_enfos_creep_summoner_raise_Description: "Призывает {{summon_count}} скелетов на {{duration}} сек.",
    DOTA_Tooltip_Ability_enfos_creep_spellguard_ward: "Магический щит",
    DOTA_Tooltip_Ability_enfos_creep_spellguard_ward_Description: "Пассивно дает +{{magic_resist}}% к сопротивлению магии.",
    DOTA_Tooltip_Ability_enfos_creep_reflector_spikes: "Отражающие шипы",
    DOTA_Tooltip_Ability_enfos_creep_reflector_spikes_Description: "Пассивно отражает {{reflect_pct}}% полученного урона.",
    DOTA_Tooltip_Ability_enfos_creep_exploder_burst: "Нестабильный взрыв",
    DOTA_Tooltip_Ability_enfos_creep_exploder_burst_Description: "Взрывается при смерти, нанося {{damage}} магического урона в радиусе {{radius}}.",
    DOTA_Tooltip_Ability_enfos_creep_bloodbeast_feast: "Кровавый пир",
    DOTA_Tooltip_Ability_enfos_creep_bloodbeast_feast_Description: "Пассивно восстанавливает здоровье в размере {{lifesteal_pct}}% от нанесенного урона.",
    DOTA_Tooltip_Ability_enfos_creep_cursecaster_amplify: "Проклятие уязвимости",
    DOTA_Tooltip_Ability_enfos_creep_cursecaster_amplify_Description: "Цель получает на {{damage_amplification}}% больше урона в течение {{duration}} сек.",
    DOTA_Tooltip_Ability_enfos_boss_stonebreaker_slam: "Дробящий удар",
    DOTA_Tooltip_Ability_enfos_boss_stonebreaker_slam_Description: "Ударяет по земле, нанося {{damage}} физического урона и оглушая на {{stun_duration}} сек в радиусе {{radius}}.",
    DOTA_Tooltip_Ability_enfos_boss_bloodfang_enrage: "Ярость Кровавого Клыка",
    DOTA_Tooltip_Ability_enfos_boss_bloodfang_enrage_Description: "При здоровье ниже {{enrage_hp_pct}}% дает +{{bonus_attack_speed}} к скорости атаки и {{bonus_lifesteal}}% вампиризма."
  },
  schinese: {
    DOTA_Tooltip_Ability_enfos_creep_runner_passive: "疾跑",
    DOTA_Tooltip_Ability_enfos_creep_runner_passive_Description: "提升{{bonus_ms}}移动速度并忽略单位碰撞。",
    DOTA_Tooltip_Ability_enfos_creep_frostguard_aura: "霜冻光环",
    DOTA_Tooltip_Ability_enfos_creep_frostguard_aura_Description: "降低周围{{radius}}范围内敌方移动速度{{slow_pct|percent}}。",
    DOTA_Tooltip_Ability_enfos_creep_venomous_poison: "剧毒攻击",
    DOTA_Tooltip_Ability_enfos_creep_venomous_poison_Description: "普通攻击附加剧毒，在{{duration}}秒内每秒造成{{poison_damage}}点魔法伤害。",
    DOTA_Tooltip_Ability_enfos_creep_healer_heal: "治疗波",
    DOTA_Tooltip_Ability_enfos_creep_healer_heal_Description: "为周围{{radius}}范围内的友军小兵恢复{{heal_amount}}点生命值。",
    DOTA_Tooltip_Ability_enfos_creep_shieldbearer_carapace: "尖刺甲壳",
    DOTA_Tooltip_Ability_enfos_creep_shieldbearer_carapace_Description: "提供+{{bonus_armor}}护甲，并格挡{{damage_block}}点物理攻击伤害。",
    DOTA_Tooltip_Ability_enfos_creep_mindstealer_burn: "法力燃烧",
    DOTA_Tooltip_Ability_enfos_creep_mindstealer_burn_Description: "每次攻击燃烧{{mana_burn}}点法力值并造成{{burn_damage}}点伤害。",
    DOTA_Tooltip_Ability_enfos_creep_conqueror_slam: "战争践踏",
    DOTA_Tooltip_Ability_enfos_creep_conqueror_slam_Description: "猛击地面，对{{radius}}范围内的敌人造成{{damage}}点物理伤害并眩晕{{stun_duration}}秒。",
    DOTA_Tooltip_Ability_enfos_creep_assassin_stealth: "暗影突袭",
    DOTA_Tooltip_Ability_enfos_creep_assassin_stealth_Description: "隐身破隐一击提供+{{bonus_damage}}点额外攻击力。",
    DOTA_Tooltip_Ability_enfos_creep_summoner_raise: "亡灵复生",
    DOTA_Tooltip_Ability_enfos_creep_summoner_raise_Description: "召唤{{summon_count}}个骷髅杂兵，持续{{duration}}秒。",
    DOTA_Tooltip_Ability_enfos_creep_spellguard_ward: "法术护盾",
    DOTA_Tooltip_Ability_enfos_creep_spellguard_ward_Description: "被动提供+{{magic_resist}}%魔法抗性。",
    DOTA_Tooltip_Ability_enfos_creep_reflector_spikes: "尖刺外皮",
    DOTA_Tooltip_Ability_enfos_creep_reflector_spikes_Description: "被动反弹受到的{{reflect_pct}}%伤害。",
    DOTA_Tooltip_Ability_enfos_creep_exploder_burst: "自爆冲击",
    DOTA_Tooltip_Ability_enfos_creep_exploder_burst_Description: "死亡时爆炸，对周围{{radius}}范围内的敌人造成{{damage}}点魔法伤害。",
    DOTA_Tooltip_Ability_enfos_creep_bloodbeast_feast: "嗜血盛宴",
    DOTA_Tooltip_Ability_enfos_creep_bloodbeast_feast_Description: "被动将攻击伤害的{{lifesteal_pct}}%转化为生命值吸收。",
    DOTA_Tooltip_Ability_enfos_creep_cursecaster_amplify: "易伤诅咒",
    DOTA_Tooltip_Ability_enfos_creep_cursecaster_amplify_Description: "诅咒目标，使其在{{duration}}秒内受到的伤害提升{{damage_amplification}}%。",
    DOTA_Tooltip_Ability_enfos_boss_stonebreaker_slam: "裂地重击",
    DOTA_Tooltip_Ability_enfos_boss_stonebreaker_slam_Description: "猛击地面，对{{radius}}范围内的敌人造成{{damage}}点物理伤害并眩晕{{stun_duration}}秒。",
    DOTA_Tooltip_Ability_enfos_boss_bloodfang_enrage: "血牙狂怒",
    DOTA_Tooltip_Ability_enfos_boss_bloodfang_enrage_Description: "生命值低于{{enrage_hp_pct}}%时，获得+{{bonus_attack_speed}}攻击速度和{{bonus_lifesteal}}%吸血。"
  }
};

// Generate wave titles and descriptions (1..60)
const waveData = [];
for (let i = 1; i <= 60; i++) {
  const isBoss = (i % 5 === 0);
  const isElite = (i % 6 === 0) && !isBoss;
  waveData.push({
    wave: i,
    isBoss,
    isElite,
    en: isBoss ? `Boss Encounter: Wave ${i}` : isElite ? `Elite Threat: Wave ${i}` : `Assault: Wave ${i}`,
    tr: isBoss ? `Boss Karşılaşması: Dalga ${i}` : isElite ? `Seçkin Tehdit: Dalga ${i}` : `Saldırı: Dalga ${i}`,
    ru: isBoss ? `Битва с боссом: Волна ${i}` : isElite ? `Элитная угроза: Волна ${i}` : `Нападение: Волна ${i}`,
    zh: isBoss ? `首领战：第 ${i} 波` : isElite ? `精英威胁：第 ${i} 波` : `突袭：第 ${i} 波`
  });
}

// Update all 4 JSON files
for (const lang of languages) {
  const filePath = path.join(root, `localization/${lang}.json`);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

  // Add ability tokens
  for (const [k, v] of Object.entries(abilityTokens[lang])) {
    data.Tokens[k] = v;
  }

  // Add wave tokens
  for (const w of waveData) {
    const titleKey = `enfos_wave_title_${w.wave}`;
    const descKey = `enfos_wave_desc_${w.wave}`;
    const text = (lang === 'turkish') ? w.tr : (lang === 'russian') ? w.ru : (lang === 'schinese') ? w.zh : w.en;
    data.Tokens[titleKey] = text;
    data.Tokens[descKey] = text;
  }

  // Add system / wave UI tokens
  if (lang === 'english') {
    data.Tokens.enfos_cap_overflow_warning = "UNIT CAP OVERFLOW! Hostiles suppressed and Life was lost!";
    data.Tokens.enfos_wave_cleared = "Wave Cleared! Prepare for the next assault.";
  } else if (lang === 'turkish') {
    data.Tokens.enfos_cap_overflow_warning = "BİRİM KAPASİTESİ AŞILDI! Yaratıklar engellendi ve Can kaybedildi!";
    data.Tokens.enfos_wave_cleared = "Dalga Temizlendi! Sıradaki saldırıya hazırlanın.";
  } else if (lang === 'russian') {
    data.Tokens.enfos_cap_overflow_warning = "ПЕРЕПОЛНЕНИЕ ЛИМИТА! Враги подавлены, потеряны очки жизни!";
    data.Tokens.enfos_wave_cleared = "Волна зачищена! Готовьтесь к следующей атаке.";
  } else if (lang === 'schinese') {
    data.Tokens.enfos_cap_overflow_warning = "单位上限溢出！怪物被压制并扣除基地生命！";
    data.Tokens.enfos_wave_cleared = "波次肃清！准备迎接下一波突袭。";
  }

  fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n');
  console.log(`Updated localization/${lang}.json with ${Object.keys(data.Tokens).length} tokens.`);
}
