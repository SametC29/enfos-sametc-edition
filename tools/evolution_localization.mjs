import fs from 'node:fs';
const groups={
 area:['Area','Etki alanı','Область','范围'], range:['Range','Menzil','Дальность','距离'], duration:['Duration (s)','Süre (sn)','Длительность (с)','持续时间（秒）'],
 damage:['Damage','Hasar','Урон','伤害'], armor:['Armor','Zırh','Броня','护甲'], armor_reduction:['Armor reduction','Zırh azaltma','Снижение брони','护甲降低'],
 health_regen:['Health regeneration','Can yenilenmesi','Восстановление здоровья','生命恢复'], heal:['Healing','İyileştirme','Лечение','治疗'], lifesteal:['Lifesteal (%)','Can çalma (%)','Вампиризм (%)','吸血（%）'],
 spell_lifesteal:['Spell lifesteal (%)','Büyü can çalması (%)','Вампиризм заклинаний (%)','技能吸血（%）'],
 mana:['Mana','Mana','Мана','魔法值'],mana_regen:['Mana regeneration','Mana yenilenmesi','Восстановление маны','魔法恢复'],
 efficiency:['Damage absorbed per mana','Mana başına emilen hasar','Урон, поглощаемый за ману','每点魔法吸收伤害'],
 attack_speed:['Attack speed','Saldırı hızı','Скорость атаки','攻击速度'],move_speed:['Movement speed','Hareket hızı','Скорость передвижения','移动速度'],
 count:['Targets / projectiles','Hedef / mermi sayısı','Цели / снаряды','目标／弹道数量'],stacks:['Maximum stacks','Azami yük','Максимум зарядов','最大叠加数'],
 crit_chance:['Critical chance (%)','Kritik şansı (%)','Шанс критического удара (%)','暴击概率（%）'],crit_mult:['Critical damage (%)','Kritik hasarı (%)','Критический урон (%)','暴击伤害（%）'],
 chance:['Trigger chance (%)','Tetiklenme şansı (%)','Шанс срабатывания (%)','触发概率（%）'], evasion:['Evasion chance (%)','Kaçınma şansı (%)','Шанс уклонения (%)','闪避概率（%）'],
 resist:['Magic resistance (%)','Büyü direnci (%)','Сопротивление магии (%)','魔法抗性（%）'],block:['Damage block','Hasar engelleme','Блок урона','伤害格挡'],
 strength:['Strength','Kuvvet','Сила','力量'],agility:['Agility','Çeviklik','Ловкость','敏捷'],slow:['Movement slow (%)','Hareket yavaşlatma (%)','Замедление движения (%)','移动减速（%）'],
 attack_slow:['Attack speed reduction','Saldırı hızı azaltma','Снижение скорости атаки','攻击速度降低'],reduction:['Attack damage reduction (%)','Saldırı hasarı azaltma (%)','Снижение урона атак (%)','攻击伤害降低（%）'],
 cooldown_reduction:['Cooldown removed per cast (s)','Kullanım başına azalan bekleme (sn)','Сокращение перезарядки за применение (с)','每次施法缩短冷却（秒）'],
 damage_amp:['Physical vulnerability (%)','Fiziksel hasar hassasiyeti (%)','Уязвимость к физическому урону (%)','物理伤害易伤（%）'],
 attack_factor:['Attack damage coefficient (%)','Saldırı hasarı katsayısı (%)','Коэффициент урона атаки (%)','攻击伤害系数（%）'],
 mana_per_second:['Drain per second','Saniyelik emiş','Поглощение в секунду','每秒汲取'],heal_pct:['Maximum health regeneration (%)','Azami can yenilenmesi (%)','Восстановление максимального здоровья (%)','最大生命恢复（%）'],
 damage_pct:['Health damage (%)','Cana bağlı hasar (%)','Урон от здоровья (%)','生命值伤害（%）']};
const explicit={armor_reduction:'armor_reduction',bonus_armor:'armor',bonus_health_regen:'health_regen',bonus_hp_regen:'health_regen',hp_regen:'health_regen',heal_amount:'heal',hp_per_kill:'heal',heal_per_second:'heal',lifesteal:'lifesteal',lifesteal_pct:'lifesteal',spell_lifesteal:'spell_lifesteal',bonus_mana:'mana',mana_regen:'mana_regen',damage_per_mana:'efficiency',bonus_as:'attack_speed',bonus_attack_speed:'attack_speed',attack_speed:'attack_speed',bonus_ms:'move_speed',max_souls:'stacks',max_stacks:'stacks',fiery_soul_max_stacks:'stacks',crit_chance:'crit_chance',crit_mult:'crit_mult',proc_chance:'chance',trigger_chance:'chance',dodge_pct:'evasion',evasion:'evasion',evasion_pct:'evasion',magic_resist:'resist',damage_block:'block',bonus_strength:'strength',bonus_agi:'agility',slow_pct:'slow',slow_as:'attack_slow',attack_slow:'attack_slow',reduction:'reduction',cooldown_reduction:'cooldown_reduction',damage_amp:'damage_amp',attack_factor:'attack_factor',soldier_damage:'attack_factor',illusion_damage:'attack_factor',bonus_damage_pct:'attack_factor',cleave_pct:'damage',cleave_distance:'range',mana_per_second:'mana_per_second',heal_pct:'heal_pct',damage_pct:'damage_pct',stun_min:'duration'};
const config=JSON.parse(fs.readFileSync('config/hero_evolutions.json','utf8'));
const keys=[...new Set(Object.values(config.profiles).flatMap(s=>s.split(' ').map(x=>x.match(/\.(\w+):/)[1])))];
const formats=[['{stat}: +{amount}.','{stat}: +{amount}%.','This ability’s cooldown is reduced by {amount}%.'],['{stat}: +{amount}.','{stat}: %{amount} artış.','Bu yeteneğin bekleme süresi %{amount} azalır.'],['{stat}: +{amount}.','{stat}: +{amount}%.','Перезарядка этой способности сокращается на {amount}%.'],['{stat}：+{amount}。','{stat}：+{amount}%。','此技能的冷却时间缩短{amount}%。']];
for(const [i,lang]of ['english','turkish','russian','schinese'].entries()){
 const f='localization/'+lang+'.json',d=JSON.parse(fs.readFileSync(f,'utf8'));
 for(const key of keys){if(key==='cooldown')continue;
  let category=explicit[key] || (/radius|width/.test(key)?'area':/range/.test(key)?'range':/duration/.test(key)?'duration':/count|bounces/.test(key)?'count':/damage|dps/.test(key)?'damage':null);
  if(!category)throw Error('Missing label '+key);
  d.Tokens['enfos_evo_stat_'+key]=groups[category][i];
 }
 for(const [n,kind]of ['add','percent','cooldown'].entries())d.Tokens['enfos_evo_'+kind]=formats[i][n];
 const out=JSON.stringify(d,null,2)+'\n';
 if(process.argv.includes('--check')){if(fs.readFileSync(f,'utf8')!==out)throw Error('Stale evolution localization: '+lang);}else fs.writeFileSync(f,out);
}
