# Kahraman çalışma ve referans dizini

Her skill görevinde ilgili kahramanın **AGENTS.md** ve **ABILITIES.md** dosyalarını, ardından [ortak teknik rehberin](../HERO_ABILITY_REFERENCE.md) ilgili bölümünü oku. Root AGENTS.md bu okuma yükümlülüğünü paylaşılan Lua/KV/precache/localization değişiklikleri için de açıkça uygular.

40 kahraman / 200 skill için envanter ve ayrı kabul kayıtları hazırlandı. UNASSESSED/PENDING başlangıç durumu bilinçlidir: varlıkların bulunması ve mock testler, oyunda doğru çalışma iddiası değildir. Native yuvalar kurulu Valve kaynağından; özel skill counterpart eşlemeleri ayrı doğrulanacaktır.

Ürün hedefi: maç içinde 50 seviye ve beş yeteneğin her birinde 10 toplam rütbe. Mevcut dosya değerleri ile hedef birbirinden ayrıdır. Bu paket oyun mekaniklerini değiştirmez.

| Kahraman | Proje rolü | Çalışma talimatı | Skill referansı ve kabul kayıtları |
| --- | --- | --- | --- |
| Sven | Tank | [AGENTS.md](sven/AGENTS.md) | [ABILITIES.md](sven/ABILITIES.md) |
| Juggernaut | Fighter | [AGENTS.md](juggernaut/AGENTS.md) | [ABILITIES.md](juggernaut/ABILITIES.md) |
| Drow Ranger | Carry | [AGENTS.md](drow_ranger/AGENTS.md) | [ABILITIES.md](drow_ranger/ABILITIES.md) |
| Lina | Mage | [AGENTS.md](lina/AGENTS.md) | [ABILITIES.md](lina/ABILITIES.md) |
| Omniknight | Support | [AGENTS.md](omniknight/AGENTS.md) | [ABILITIES.md](omniknight/ABILITIES.md) |
| Axe | Tank | [AGENTS.md](axe/AGENTS.md) | [ABILITIES.md](axe/ABILITIES.md) |
| Legion Commander | Fighter | [AGENTS.md](legion_commander/AGENTS.md) | [ABILITIES.md](legion_commander/ABILITIES.md) |
| Sniper | Carry | [AGENTS.md](sniper/AGENTS.md) | [ABILITIES.md](sniper/ABILITIES.md) |
| Crystal Maiden | Mage | [AGENTS.md](crystal_maiden/AGENTS.md) | [ABILITIES.md](crystal_maiden/ABILITIES.md) |
| Dazzle | Support | [AGENTS.md](dazzle/AGENTS.md) | [ABILITIES.md](dazzle/ABILITIES.md) |
| Centaur Warrunner | Tank | [AGENTS.md](centaur/AGENTS.md) | [ABILITIES.md](centaur/ABILITIES.md) |
| Wraith King | Fighter | [AGENTS.md](skeleton_king/AGENTS.md) | [ABILITIES.md](skeleton_king/ABILITIES.md) |
| Phantom Assassin | Carry | [AGENTS.md](phantom_assassin/AGENTS.md) | [ABILITIES.md](phantom_assassin/ABILITIES.md) |
| Zeus | Mage | [AGENTS.md](zuus/AGENTS.md) | [ABILITIES.md](zuus/ABILITIES.md) |
| Witch Doctor | Support | [AGENTS.md](witch_doctor/AGENTS.md) | [ABILITIES.md](witch_doctor/ABILITIES.md) |
| Bristleback | Tank | [AGENTS.md](bristleback/AGENTS.md) | [ABILITIES.md](bristleback/ABILITIES.md) |
| Slark | Fighter | [AGENTS.md](slark/AGENTS.md) | [ABILITIES.md](slark/ABILITIES.md) |
| Luna | Carry | [AGENTS.md](luna/AGENTS.md) | [ABILITIES.md](luna/ABILITIES.md) |
| Shadow Fiend | Mage | [AGENTS.md](nevermore/AGENTS.md) | [ABILITIES.md](nevermore/ABILITIES.md) |
| Shadow Shaman | Support | [AGENTS.md](shadow_shaman/AGENTS.md) | [ABILITIES.md](shadow_shaman/ABILITIES.md) |
| Tidehunter | Tank | [AGENTS.md](tidehunter/AGENTS.md) | [ABILITIES.md](tidehunter/ABILITIES.md) |
| Dragon Knight | Tank | [AGENTS.md](dragon_knight/AGENTS.md) | [ABILITIES.md](dragon_knight/ABILITIES.md) |
| Pudge | Tank | [AGENTS.md](pudge/AGENTS.md) | [ABILITIES.md](pudge/ABILITIES.md) |
| Underlord | Tank | [AGENTS.md](abyssal_underlord/AGENTS.md) | [ABILITIES.md](abyssal_underlord/ABILITIES.md) |
| Ursa | Fighter | [AGENTS.md](ursa/AGENTS.md) | [ABILITIES.md](ursa/ABILITIES.md) |
| Monkey King | Fighter | [AGENTS.md](monkey_king/AGENTS.md) | [ABILITIES.md](monkey_king/ABILITIES.md) |
| Troll Warlord | Fighter | [AGENTS.md](troll_warlord/AGENTS.md) | [ABILITIES.md](troll_warlord/ABILITIES.md) |
| Chaos Knight | Fighter | [AGENTS.md](chaos_knight/AGENTS.md) | [ABILITIES.md](chaos_knight/ABILITIES.md) |
| Anti-Mage | Carry | [AGENTS.md](antimage/AGENTS.md) | [ABILITIES.md](antimage/ABILITIES.md) |
| Faceless Void | Carry | [AGENTS.md](faceless_void/AGENTS.md) | [ABILITIES.md](faceless_void/ABILITIES.md) |
| Medusa | Carry | [AGENTS.md](medusa/AGENTS.md) | [ABILITIES.md](medusa/ABILITIES.md) |
| Terrorblade | Carry | [AGENTS.md](terrorblade/AGENTS.md) | [ABILITIES.md](terrorblade/ABILITIES.md) |
| Storm Spirit | Mage | [AGENTS.md](storm_spirit/AGENTS.md) | [ABILITIES.md](storm_spirit/ABILITIES.md) |
| Leshrac | Mage | [AGENTS.md](leshrac/AGENTS.md) | [ABILITIES.md](leshrac/ABILITIES.md) |
| Invoker | Mage | [AGENTS.md](invoker/AGENTS.md) | [ABILITIES.md](invoker/ABILITIES.md) |
| Puck | Mage | [AGENTS.md](puck/AGENTS.md) | [ABILITIES.md](puck/ABILITIES.md) |
| Lion | Support | [AGENTS.md](lion/AGENTS.md) | [ABILITIES.md](lion/ABILITIES.md) |
| Jakiro | Support | [AGENTS.md](jakiro/AGENTS.md) | [ABILITIES.md](jakiro/ABILITIES.md) |
| Vengeful Spirit | Support | [AGENTS.md](vengefulspirit/AGENTS.md) | [ABILITIES.md](vengefulspirit/ABILITIES.md) |
| Lich | Support | [AGENTS.md](lich/AGENTS.md) | [ABILITIES.md](lich/ABILITIES.md) |

## Bakım

`node tools/hero_reference_docs.mjs --check`: kapsam, güncel inventory ve kabul alanlarını doğrular; runtime doğrulamaz.
`--init`: yalnız eksik dosyaları oluşturur. `--refresh`: yalnız generated inventory bloklarını yeniler; insan kararları ve test kayıtlarını korur.

[Geniş araştırma ve soruların yanıtları](../audit/HERO_ABILITY_RESEARCH_2026-09-29.md), [mevcut geliştirme standardı](../HERO_ABILITY_DEVELOPMENT_GUIDELINES.md), [kaynak snapshot](../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json).
