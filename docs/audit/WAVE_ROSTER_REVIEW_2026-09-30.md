# Tarihsel dalga ve boss çeşitlilik incelemesi — 30.09.2026 (Elite bölümü geçersiz)

Bu belge Elite kaldırılmadan önceki tasarım anlık görüntüsüdür. 01.10.2026'da
Elite dalgaları ve birimleri sahibin talimatıyla kaldırıldı. Güncel durum için
`ELITE_REMOVAL_2026-10-01.md` dosyasına bakın. Aşağıdaki Elite satırları tarihsel
kayıttır; oyunda tanımlı veya planlanan içerik değildir.

Her dalga içeriği ve her 5. dalgadaki boss karşılaşması ayrı ayrı gözden geçirildi. Normal/Elite dalgalarının kompozisyonları benzersiz tutuldu; aynı creep rollerini art arda öğretmekten kaçınıldı. İlk 30 dalgada istenen özel düşman sırası korundu; 31–60 dalgalarının tamamına ayrıca benzersiz tema adı ve dört dilde açıklama verildi. Boss spawn planı sadece `boss_name` kullanır.

| Dalga | Tür | Creep teması |
|---:|---|---|
| 1 | normal | soldier + archer |
| 2 | normal | soldier + venomous |
| 3 | normal | soldier + conqueror |
| 4 | normal | frostguard + soldier |
| 5 | boss | stonebreaker |
| 6 | elite | vanguard + skyraker |
| 7 | normal | venomous + archer |
| 8 | normal | runner + shieldbearer + archer |
| 9 | normal | shieldbearer + archer |
| 10 | boss | brood_matron |
| 11 | normal | assassin + soldier |
| 12 | elite | assassin + assassin |
| 13 | normal | mindstealer + archer |
| 14 | normal | mindstealer + soldier |
| 15 | boss | bloodfang_alpha |
| 16 | normal | bloodbeast + soldier |
| 17 | normal | conqueror + frostguard |
| 18 | elite | necromancer + summoner |
| 19 | normal | assassin + archer |
| 20 | boss | frost_warden |
| 21 | normal | shieldbearer + soldier |
| 22 | normal | silencer + spellguard |
| 23 | normal | healer + shieldbearer |
| 24 | elite | reflector + mindstealer |
| 25 | boss | mind_devourer |
| 26 | normal | venomous + conqueror |
| 27 | normal | skyraker + archer |
| 28 | normal | splitter + soldier |
| 29 | normal | venomous + shieldbearer |
| 30 | boss | iron_colossus |

31–60 aralığının her dalgasına ayrı karşılaşma adı ve HUD açıklaması da verildi:

| Dalga | Tür | Temalı karşılaşma | Creep teması |
|---:|---|---|---|
| 31 | normal | Frostshadow Ambush | assassin + frostguard |
| 32 | normal | Mana-Raising Dead | summoner + mindstealer |
| 33 | normal | Splintered Bulwark | shieldbearer + splitter |
| 34 | normal | Volatile Breach | exploder + soldier |
| 35 | boss | Gravecaller — summon interruption | gravecaller |
| 36 | elite | Storm Barrage | stormcaster + archer |
| 37 | normal | Rally and Ruin | exploder + healer |
| 38 | normal | Stunning Blast | conqueror + exploder |
| 39 | normal | Mirror Ward | reflector + healer |
| 40 | boss | Storm Tyrant — spread from marked strikes | storm_tyrant |
| 41 | normal | Blood Pact | bloodbeast + spellguard |
| 42 | elite | Venomous Infiltration | assassin_master + assassin + venomous |
| 43 | normal | Hushed Frostfront | silencer + frostguard |
| 44 | normal | Shielded Revival | summoner + shieldbearer |
| 45 | boss | Shadow Huntress — far-target marks | shadow_huntress |
| 46 | normal | Stalk and Stagger | assassin + conqueror |
| 47 | normal | Hexbound Vanguard | cursecaster + soldier |
| 48 | elite | Shatterstorm | bomber + exploder + splitter |
| 49 | normal | Withering Covenant | cursecaster + mindstealer + shieldbearer |
| 50 | boss | Plague Behemoth — marked plague zones | plague_behemoth |
| 51 | normal | Pursued and Restored | assassin + healer |
| 52 | normal | Runic Rampart | shieldbearer + spellguard |
| 53 | normal | Endless Reinforcements | healer + summoner |
| 54 | elite | Controller's Grasp | controller + conqueror + mindstealer |
| 55 | boss | Rift Lord — inward pull | rift_lord |
| 56 | normal | Frozen Bloodhunt | frostguard + bloodbeast |
| 57 | normal | Venomous Mirrors | reflector + venomous |
| 58 | normal | Fourfold Assault | spellguard + assassin + mindstealer + healer |
| 59 | normal | Last Bastion | shieldbearer + summoner + spellguard |
| 60 | boss | Ascendant Gatekeeper — expanding rings | ascendant_gatekeeper |

## Boss karşılaşmaları

| Dalga | Boss | İmza karşılaşması |
|---:|---|---|
| 5 | Stonebreaker | Yeri belli edilen geniş darbe; düşük can aşamasında öfke |
| 10 | Brood Matron | Zehirli zemin ve can yarısında örümcek yavruları |
| 15 | Bloodfang Alpha | En uzaktaki kahramana atılma, kanama ve can çalma |
| 20 | Frost Warden | Hedefli buz darbesi ve uzun yavaşlatma |
| 25 | Mind Devourer | Düşük manalı kahramanı işaretleyen mana emme alanı |
| 30 | Iron Colossus | Büyük yarıçaplı, sersemleten ve geri savuran yer sarsıntısı |
| 35 | Gravecaller | Aralıklı iskelet çağrısı ve ek alan darbesi |
| 40 | Storm Tyrant | Birden çok kahramana ayrı yıldırım işaretleri |
| 45 | Shadow Huntress | Uzak hedeflere ayrı ok yağmuru ve kanama |
| 50 | Plague Behemoth | İşaretli alanda hasar ve zamanla kanama |
| 55 | Rift Lord | Merkez alanına çekme ve kısa sersemletme |
| 60 | Ascendant Gatekeeper | Üç farklı yarıçapta sırayla patlayan halka düzeni |

## Değişiklikler ve kaynak değerlendirmesi

- Runner yalnızca istenen 8. dalgada yer alıyor; önceki Runner-temalı dalgalar başka rollerle değiştirildi.
- 11–12. dalgalarda görünmez suikastçı rolü; 17. dalgada stun, 22. dalgada silence, 27. dalgada rota takip eden uçan mana çekici rolü açılıyor.
- Dota 2 Horde Mode tartışmalarında oyuncular, bazı yavaşlatma dalgalarının fiziksel/iyileşme odaklı takımları sonraki dalga gelmeden temizleyemeyecek kadar zorladığını; bazı stun/boss dizilerinin ise kaçınılamaz zincir kontrole dönüştüğünü yazıyor. Aynı tartışmada bossların takım rotasyonu ve farklı hasar rollerini buluşturan karşılaşmalar olduğu söyleniyor. Bu yüzden kontrol temaları dalgalara dağıtıldı ve boss saldırılarına önceden görülebilen telegraph eklendi; kontrol süreleri kısa tutuldu.
- Attack On Hero / Attack On Hero 2 örnekleri, 36 benzersiz canavar turu ve 35 boss turu gibi uzun PvE dizileriyle düşman kimliğini ana tekrar önleyici araç olarak kullanıyor. Boss Survival Adventure harita açıklaması da farklı biyomları kendi creep ve boss çeşitleriyle eşliyor. Bu yaklaşım burada 60 dalgaya özgü kompozisyon ve her beş dalgada ayrı boss kimliği olarak uygulandı.
- Roshan Defense topluluk tanıtımı bölgeye özgü bosslar ve 11 farklı lane bossundan söz ediyor; her Enfos bossuna da hedefleme/kaçınma açısından ayrı bir imza saldırısı verildi. Araştırma yalnızca tasarım örnekleri ve oyuncu geri bildirimi içindir; başka haritalardan kod veya asset alınmadı.

Kaynaklar: [Dota 2 Horde Mode oyuncu tartışması](https://steamcommunity.com/workshop/filedetails/discussion/472597026/154643720194807632/?ctp=1&l=french), [Attack On Hero / Attack On Hero 2 tur açıklamaları](https://steamcommunity.com/sharedfiles/filedetails/?id=2681590490), [Boss Survival Adventure](https://steamcommunity.com/sharedfiles/filedetails?id=1571786267), [Roshan Defense topluluk tanıtımı](https://www.reddit.com/r/DotA2/comments/edenau).

## Doğrulama durumu

Boss telegraphları mevcut uyarı sistemini ve kaynakları kullanır; yeni model/particle eklenmedi. Uçan Skyraker yol takibi, Runner akışı, görünmezlik, sessizlik durumu, 12 boss saldırısının gerçek Dota davranışı ve yoğun dalgalarda performans henüz oyun içinde doğrulanmadı. Bu nedenle rapor tasarım ve kod düzeyinde tamam; Dota/VConsole denemesi bekliyor.
