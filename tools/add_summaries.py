import os

summaries = {
    'english': {
        'bulwark_shield_slam': 'Slams shield to deal physical damage and slow nearby enemies.',
        'bulwark_challenge': 'Taunts nearby hostiles to attack Bulwark while granting bonus armor.',
        'bulwark_iron_guard': 'Passively boosts armor and blocks incoming physical attack damage.',
        'bulwark_fortress': 'Awakens titan resilience, greatly boosting maximum health and armor.',
        'bulwark_unbreakable': 'Innate passive that continuously regenerates health per second.',
    },
    'turkish': {
        'bulwark_shield_slam': 'Kalkanını yere vurarak fiziksel hasar verir ve yakındaki düşmanları yavaşlatır.',
        'bulwark_challenge': 'Yakındaki düşmanları kendine saldıracak şekilde kışkırtır ve ilave zırh kazanır.',
        'bulwark_iron_guard': 'Pasif olarak zırhı artırır ve gelen fiziksel saldırı hasarlarını engeller.',
        'bulwark_fortress': 'Titan direncini uyandırarak azami canı ve zırhı büyük ölçüde artırır.',
        'bulwark_unbreakable': 'Doğuştan gelen pasif ile her saniye sürekli can yenilenmesi sağlar.',
    },
    'russian': {
        'bulwark_shield_slam': 'Ударяет щитом по земле, нанося физический урон и замедляя врагов.',
        'bulwark_challenge': 'Провоцирует врагов атаковать Bulwark и дает бонусную броню.',
        'bulwark_iron_guard': 'Пассивно увеличивает броню и блокирует урон от входящих атак.',
        'bulwark_fortress': 'Пробуждает стойкость титана, значительно увеличивая здоровье и броню.',
        'bulwark_unbreakable': 'Врожденная способность, непрерывно восстанавливающая здоровье в секунду.',
    },
    'schinese': {
        'bulwark_shield_slam': '猛击盾牌造成物理伤害并减速附近敌人。',
        'bulwark_challenge': '嘲讽附近敌人攻击Bulwark，同时获得额外护甲。',
        'bulwark_iron_guard': '被动增加护甲并格挡受到的物理攻击伤害。',
        'bulwark_fortress': '唤醒泰坦韧性，大幅提升最大生命值和护甲。',
        'bulwark_unbreakable': '先天被动，每秒持续恢复生命值。',
    }
}

paths = [
    ('english', 'game/resource/addon_english.txt'),
    ('english', 'game/panorama/localization/addon_english.txt'),
    ('turkish', 'game/resource/addon_turkish.txt'),
    ('turkish', 'game/panorama/localization/addon_turkish.txt'),
    ('russian', 'game/resource/addon_russian.txt'),
    ('russian', 'game/panorama/localization/addon_russian.txt'),
    ('schinese', 'game/resource/addon_schinese.txt'),
    ('schinese', 'game/panorama/localization/addon_schinese.txt'),
]

root = r'c:\Enfos Team Survival SametC Edition'
for lang, rel_path in paths:
    full_path = os.path.join(root, rel_path)
    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()

    for ab, summ in summaries[lang].items():
        desc_key = f'"DOTA_Tooltip_Ability_{ab}_Description"'
        summary_key = f'"DOTA_Tooltip_Ability_{ab}_SummaryDescription"'
        if desc_key in content and summary_key not in content:
            idx = content.find(desc_key)
            end_line_idx = content.find('\n', idx)
            insert_str = f'\n\t\t"DOTA_Tooltip_ability_{ab}_SummaryDescription" "{summ}"\n\t\t"DOTA_Tooltip_Ability_{ab}_SummaryDescription" "{summ}"'
            content = content[:end_line_idx] + insert_str + content[end_line_idx:]

    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Successfully updated: {rel_path}')
