# Enfos kahraman ve skill araştırması — 29 Eylül 2026

## Politika güncellemesi — araştırma sonrası

Kullanıcı 2026-09-29 tarihinde diğer custom oyunlardan kod alma yasağını kaldırdı.
Aşağıdaki araştırma, yapıldığı andaki politikayı ve o oturumda kod aktarılmadığını
kaydeder. Gelecek çalışmalar için güncel [lisanslı kullanım politikası](../REFERENCE_ANALYSIS_POLICY.md)
geçerlidir; genel yasak belirten eski değerlendirmeler artık yürürlükte değildir.
Gerekirse bütün skiller değişebilir; kimlik, sınıflandırma ve gerçek oyun kabulü korunur.

## Sonuç ve kapsam

Sorunu yalnız precache ekleyerek veya başka bir PvE oyunun skilllerini taşıyarak
çözmek mümkün değil. Doğru geliştirme birimi, **davranış + görsel + ses + modifier
+ kaynak yükleme + temizleme + açıklama + boss etkileşimi** olan tek yetenektir.
Önce ortak sorunları kanıtla, sonra Sven'den başlayan 2–4 pilotla yöntemi doğrula,
ardından 40 kahramanı tek tek ele al. Bu paket araştırma, talimat, envanter ve
kanıt kayıtları oluşturur; 200 yeteneği onardığı veya oyunda doğruladığı iddiası yoktur.

Kullanıcının yeni hedefi: kahraman seviyesi en fazla 50; Q/W/E/R ve beşinci Enfos
pasifinin her biri **10 toplam rütbe**. Özel hüner seçimleri ve Aghanim sistemleri
ayrı kalır. Bu hedef, eski level-30 tasarımını değiştirir; üretim koduna henüz
uygulanmadı. 10 ek geliştirme ile 10 toplam rütbe birbirine karıştırılmamalı.

[Paylaşılan sohbet](https://chatgpt.com/share/6abad86a-ebb0-83ed-8510-e13072650be8)
tarayıcıda okundu. Önceki asistanın kaynak/lisans/güncellik iddiaları kanıt yerine
geçirilmedi. Özellikle GameTracking bir Valve yayın kanalı değildir; kütüphane
örnekleri güncel native davranış veya eksiksiz kabul garantisi vermez.

## 1. Soruların tek tek yanıtı

### 1.1 “Orijinal Dota skillleri neden eksik efekt/ses/davranışla çalışıyor?”

Kahramanın modeli veya skill ikonu native olabilirken skillin yürütülen sınıfı
özel Lua olabilir. Bizim ilk beş yuvaya atanmış 200 tanımın tamamı `ability_lua`
ve `abilities/pve_kits` kullanıyor. Bu dosyada cast callback'ini yazmak, Dota'nın
native projectile, cast animation, hit sound, modifier ve facet/upgrade zincirini
otomatik devralmak anlamına gelmez. İkon native implementation kanıtı değildir.

Örnek: Sven Q `bulwark_shield_slam` callback'i ses ve explosion particle oluşturup
hemen alan hasarı/sersemletme uyguluyor. Bu callback'te projectile oluşturma
çağrısı yok; KV'deki `bolt_speed` tek başına uçan bir mermi yaratmaz. Bu **kaynak
kodunda doğrulanmış** bir farktır. Mevcut explosion'ın CP3/attachment seçiminin
oyunda yanlış olduğu ise henüz kanıtlanmadı. Native Storm Bolt ile eşdeğer olduğu
varsayılamaz. [Sven kayıtları](../heroes/sven/ABILITIES.md).

İkinci zincir asset varlığı → yükleme → doğru CP/attachment → doğru konum/zaman
→ istemciye ulaşma → temizleme zinciridir. Asset yolu doğru olsa bile diğer
halkalar bozuk olabilir. Ses için de event adı ile `.vsndevts` dosyası ayrı şeylerdir.

### 1.2 “Sürekli hatalı yapmasını nasıl engelleriz; bu yeterli mi?”

Uzun prompt tek başına yeterli değildir. Agentin yapmadığı kontrolü görünür
kılan, tekrar okunabilir kanıt sistemi gerekir. Bu nedenle root AGENTS çalışma
öncesinde ilgili kahramanın talimatını, skill dosyasını ve ortak teknik rehberi
okutuyor. Her skillin kabul alanları PENDING başlıyor; dosya mevcut diye PASS
verilemiyor. Envanter eskiyince otomatik kontrol başarısız oluyor.

Mock testler eksik callback veya Lua hata sınıfını yakalayabilir; gerçek targeting,
sesin duyulması, particle'ın görünmesi ve boss politikası için Dota/VConsole testi
gerekir. Görsel için screenshot/video, ses için dinleme kaydı/notu, davranış için
beklenen/ölçülen sonuç ve log saklanır. “Hata vermedi” kabul sonucu değildir.

### 1.3 “Custom map yaparken hero nasıl düzenlenir rehberlerini inceledin mi?”

Evet; tek bir hero editing tutorial yerine işin bağımlılıklarını birlikte
inceledim. Hero KV slot/model/SoundSet tanımlar; ability KV davranış bayrakları,
hedefleme, rütbe ve değerleri tanımlar; native veya Lua implementation davranışı
yürütür; modifier ve asset sistemleri yaşam döngüsünü tamamlar. Şu başvurular okundu:

| Alan | Okunan teknik kaynak | Enfos'ta kullanım |
| --- | --- | --- |
| Hero/unit tanımı | [Unit KeyValues](https://moddota.com/units/unit-keyvalues) | Hero görünümü, slot ve unit özellikleri |
| Skill tanımı | [Ability KeyValues](https://moddota.com/abilities/ability-keyvalues) | MaxLevel, behavior, target flags, special değerler |
| Kaynak yükleme | [Precache](https://moddota.com/scripting/precache-fixing-and-avoiding-issues) | Soğuk başlangıç, bağımlı hero kaynakları |
| Görsel bağlama | [Particle Attachment](https://moddota.com/scripting/particle-attachment) | Entity/world attachment ve control point ayrımı |
| Pasif | [Creating Innate Abilities](https://moddota.com/abilities/creating-innate-abilities) | Özel pasif açma; modern Dota innate ile karıştırmama |
| İstemci verisi | [Server to Client](https://moddota.com/abilities/server-to-client) | UI/tooltip/server modifier verisi |
| Kalkan | [Custom Barriers](https://moddota.com/abilities/lua-modifiers/5) | Hasar emme ve istemci kalkan göstergesi ayrı doğrulama |
| Spell block/reflect | [Lua modifiers](https://moddota.com/abilities/lua-modifiers/2) | Block/reflect event davranışı |
| Eski modifier kullanımı | [Built-in modifiers](https://moddota.com/abilities/reutilizing-built-in-modifiers) | Native modifier bağımlılıklarını kontrol etme |
| Süre açıklaması | [AbilityDuration tooltips](https://moddota.com/abilities/abilityduration-tooltips) | Gösterilen süre ile uygulanan süreyi eşleme |
| Lua API | [API kayıtları](https://docs.moddota.com/lua_server/) | İmza başvurusu; gerçek engine testi yerine geçmez |

ModDota yazarlarının teknik rehberleri kendi iş akışları için birincil kaynaktır;
Valve motorunun güncel davranışı için kurulu build ve runtime daha güçlü kanıttır.
Eski data-driven örnekleri Lua event syntax'ı diye taşımıyoruz.
Valve Developer Community'nin ilgili hero/ability/sound/debug/particle sayfaları
bu oturumda 403/erişim hatası verdi. İçeriklerini okumuş gibi sunmuyoruz; bağlantıları
[ortak rehberde](../HERO_ABILITY_REFERENCE.md) sonraki erişim için sakladık.

### 1.4 “PvP skilllerini PvE'ye çevirirken ne yapmalıyız?”

Her skill, gerekçe ve native karşılığı kanıtıyla KEEP / TUNE / PVE-CONVERT /
REPLACE olarak değerlendirilir. Şu an bütün kayıtlar UNASSESSED; otomatik isim veya
slot eşlemesi karar vermedi. Yerel bir Lua skill için KEEP kararı native'a dönüş
gerektirebilir; mevcut tanımı KEEP diye etiketlemek native kullanıldığı anlamına gelmez.

AoE, heal, aura, stun ve savunma gibi davranışlar zaten PvE'de değerlidir. Yalnız
kahramandan stat çalma, hero kill şartı, hedefsiz mana etkisi gibi gerçekten
bağımlı bölümü dönüştür. Boss için sersemletme/taunt/execute politikasını tekil
skillde belgelerken ortak boss sistemini kontrol et; sessizce “bossa hiçbir şey
yapmasın” veya sonsuz kontrol döngüsü kurma. Normal creep, elite ve boss ayrı
hedef testleri olmalıdır. İki takımın olduğu özgün PvEvP Enfos tasarımı korunur.

### 1.5 “Düzgün çalışan PvE oyundan skill kopyalasak?”

Başka oyunun skill'i yardımcı fonksiyon, talent, item, engine sürümü ve asset
bağımlılıklarıyla çalışır; tek Lua dosyası taşımak bunları sağlamaz. Daha önemlisi
bu projenin [referans politikası](../REFERENCE_ANALYSIS_POLICY.md) diğer custom
map kodu/custom asset kopyalamayı yasaklıyor. Bu oturumda kaynaklar yalnız
tasarım ve uygulama yaklaşımı referansı olarak kullanıldı; hiçbir kod/asset taşınmadı.

| Kaynak | Yeniden kontrol sonucu | Bizim kullanımımız |
| --- | --- | --- |
| [Elfansoer Lua Abilities](https://github.com/Elfansoer/dota-2-lua-abilities) | MIT dosyası okundu; birebir güncel/native veya hatasız garanti değil | Mekanik örnek, patch ve bağımlılık karşılaştırması |
| [Pizzalol SpellLibrary](https://github.com/Pizzalol/SpellLibrary) | README Aghanim ve cast animation'ı zorunlu tutmuyor | Tam skill kabulü için yetersiz örneğin nerede eksik kaldığını öğrenme |
| [AbilityLuaSpellLibrary](https://github.com/ModDota/AbilityLuaSpellLibrary) | Lua spell kütüphanesi; README/liste incelemesi | Projectile/modifier düzeni; file-level kanıt sonra |
| [Dota IMBA](https://github.com/EarthSalamander42/dota_imba) | Apache-2.0 ve credit isteyen kullanım açıklaması görüldü | Hero kimliği ve rework yaklaşımı; proje politikası gereği kod import yok |
| [Angel Arena Black Star](https://github.com/ark120202/angel-arena-black-star) | Apache-2.0 etiketi görüldü; [Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=699441891) 7-level skills açıklıyor | Çok rütbeli kit/boss tasarımı; güncel çalışırlık varsayılmaz |
| [Open Angel Arena](https://github.com/OpenAngelArena/oaa) | README/mimari başvurusu görüldü; root listesinde lisans dosyası görünmedi | Önceki sohbetin MIT iddiası bu incelemeyle doğrulanmadı; tasarım referansı |
| [Boss Hunters](https://github.com/Yahnich/Boss-Hunters) | README kopyalamama isteği içeriyor; açık kullanım izni görülmedi | PvE tasarım referansı; önceki precache satır iddiaları ayrıca file-level doğrulanmadı |
| [Windy10v10AI](https://github.com/EthanH1973/windy10v10ai) | README GPLv3, Workshop exception ve build'e göre local Dota reference anlatıyor | Build'e bağlı referans fikri; exception/code import uygulanmadı |
| Watcher / Roshpit / Epic Boss Fight | Önceki sohbette önerilmiş; bu oturumda bütün repo/oyun/skill doğrulaması yapılmadı | Davranış tasarım adayları, kod veya hazır teknik doğruluk kaynağı değil |
| Legion TD / Claude Playbook | Önceki sohbetteki kaynak adayları; bütün iddiaları doğrulanmadı | Hero skill çözümünün gerekli bağımlılığı yapılmadı |

Lisans etiketleri kaynak tarama durumudur; custom art/audio için toplu izin veya
bu projenin politikasını aşma yetkisi değildir. Lisanssız dump veya Workshop
aboneliği kod sahipliğini değiştirmez. “En iyi PvE repo” sıralaması yerine gerçek
skillin kanıtlanmış bir mekanik örneğini seçmek daha uygulanabilirdir.

### 1.6 “Her hero için agent.md ve başvuru kaynağı oluşturabilir miyiz?”

Oluşturuldu: [40 kahraman dizini](../heroes/README.md). Her kahramanda gerçek
`AGENTS.md` talimat dosyası ve `ABILITIES.md` içinde beş ayrı kanıt defteri var.
Root talimat, bu dosyaları shared Lua/KV/precache değişimlerinde de okutuyor;
yalnız docs altında durmalarının production dosyalarına otomatik kapsam verdiği
varsayılmadı. [Ortak teknik rehber](../HERO_ABILITY_REFERENCE.md) bütün kitlerde
kullanılan mekanik/efekt/ses/yükleme/temizleme standardını sağlıyor.

Her skillde native counterpart ve sınıflandırma, beklenen Enfos davranışı, boss
politikası, rank/scaling ve upgrade kararları, particle CP/attachment, ses event/bank,
15 ayrı kabul alanı ve kanıt kaydı bulunuyor. Henüz native counterpart'lar tek tek
doğrulanmadığından PENDING; benzer ikon veya aynı slot numarasından uydurulmadı.

## 2. Yerel kaynakta doğrulananlar ve sınırlar

| Bulgu | Kanıt düzeyi | Sonuç |
| --- | --- | --- |
| 40 hero, ilk beş slotta 200 skill | Production KV/roster | Güncel kapsam |
| 200 tanım shared ability_lua kullanıyor | Production KV | Native görünüm/native davranış ayrımı kritik |
| Toplam custom KV tanımı 216 | Production KV | 200 slot skill'i ile tüm yardımcı tanımlar ayrı |
| Explicit MaxLevel: 121×4, 39×3, 35×1, 1×8; 4 unspecified | KV envanteri | 10-rank migration henüz yapılmamış; unspecified native default diye kesinlenmez |
| Beşinci pasif: Sven 8; Jugg/Drow/Lina/Omni 4; diğerleri 1 | KV | Ortak pasif rank varsayımı mevcut yapıyı anlatmıyor |
| Passive açma yalnız 0 iken rank1 veriyor | innates.lua | Ücretsiz başlangıç ile harcanan point ayrı |
| Kurulu Dota build 6941 / SourceRevision 11041083, 25 Eylül 2026 | steam.inf | Native snapshot hangi kuruluma ait belli |
| 40 native hero dosyası okundu | Kurulu Valve VPK | Slot/model/SoundSet/stat gains çıkarıldı; native skill iç algoritmaları çıkarılmadı |
| Taramanın 146 literal asset yolunun compiled kaydı var | VPK dizini | Sabit dosya varlığı doğrulandı; doğru CP/ses event/precache/runtime değil |
| Sound bank loop yalnız beş hero için explicit; bütün40 unit precache de var | addon_game_mode.lua | “Diğer35 ses kesin eksik” sonucu çıkarılamaz |
| `test_real_abilities.mjs` mock ortamı | Test kaynağı | Dota içinde oynanmış test olarak raporlanmaz |
| Static audit kullanılmayan special adayları veriyor | Regex/heuristic | Otomatik silme veya bug sertifikası değil |

Snapshot: [HERO_REFERENCE_SOURCE_SNAPSHOT.json](HERO_REFERENCE_SOURCE_SNAPSHOT.json).
Collector yalnız sabit `.vpcf/.vmdl/.vsndevts` stringlerini tarar; dinamik yollar
ve ses event içerikleri ayrıca incelenir. SteamTracking
[GameTracking-Dota2](https://github.com/SteamTracking/GameTracking-Dota2) ikincil
mirrordur; kurulu build ile uyuşmadan güncel Valve gerçeği diye kullanılmaz.

## 3. Ortak kök neden adayları: onarım önceliği

1. **Davranış eksiltme:** native asset ismi kullanılıp native davranış zincirinin
   uygulanmaması. Sven Q örneği kaynakta doğrulanıyor; pilotta tasarım kararıyla
   native dönüş veya tanımlı custom davranış seçilmeli.
2. **Generic effect helper:** aynı attachment/ömür düzeni her asset'e uymaz.
   CP, parent/child particle ve projectile timing her kullanımda incelenir.
   `ReleaseParticleIndex` tek başına persistent particle'ı bitirmek değildir;
   kısa kendiliğinden biten efektlerin yalnız release kullanması da otomatik leak değildir.
3. **KV/Lua zero fallback:** value helper eksik anahtarda 0 döndürebilir; Lua'da
   0 truthy olduğundan `or default` bunu düzeltmez. Meşru sıfırı bozmadan eksik
   anahtar ile sıfır ayrılmalı. Bug iddiası ilgili skill/anahtarda testle kanıtlanır.
4. **Precache bağımlılığı:** hero seçili/yüklü iken geçen test soğuk başlangıcı
   kanıtlamaz. Dynamic sound bank, child resource ve cross-hero asset için test gerekir.
5. **Modifier/UI ayrımı:** hasar emen bir modifier görünür barrier, buff icon,
   refresh/dispel/death davranışı sağlamış sayılmaz. Server/client ayrı kontrol edilir.
6. **Rank ve upgrade erişimi:** 10 elemanlı KV tek başına upgrade UI, point,
   RequiredLevel, innate açma, tooltip veya Shard/Scepter entegrasyonunu çözmez.

Bu adaylar gerekçesiz shared rewrite yetkisi vermez. Aynı kök nedenden etkilenen
skill listesi ve küçük kanıtlı onarım çıkarılır; çalışan contributor kodu korunur.

## 4. Level50 / rank10 geçiş planı

Valve'ın [resmi Workshop güncellemesi](https://store.steampowered.com/oldnews/21435)
custom level desteğinde üst sınırın XP table ile tanımlandığını ve
SetCustomHeroMaxLevel'ın zorunlu olmadığını açıklıyor. Güncel kurulumda table
semantiği/ilk-son seviye/point kazanımı gerçek oyunla doğrulanmalı. Sadece eski
fonksiyon adı veya örnek XP dizisi kullanılmaz.

Beş skill ×10 =50 toplam rütbe. Başlangıçta ücretsiz passive1 korunursa satın
alınacak49 rütbe kalır. “Her level'da bir point” körlemesine uygulanırsa fazladan
point doğabilir. Açılış point'i, level2–50 point'i, rank unlock eğrileri, native
required level sınırlamaları, ult timing, maxlevel UI ve reconnect ayrı sözleşmedir.
49 harcanabilir point modeli öneridir; bu pakette uygulanmadı.

Sıra: tasarım/point bütçesini kaydet → XP/upgrade POC → Sven1–10 eğrisi →
talent/Shard/Scepter ve item etkileşim testi → pilot kabul → tüm roster migration.
Hüner seçim seviyeleri 4/7/10/13/16/19 olarak mevcut tasarımda kalır; 50'ye
yükselmek kendiliğinden yeni talent milestone eklemez.

## 5. Pilot ve gerçek kabul oturumu

İlk pilot **Sven**: damage/stun, aggro/taunt, attack passive, defensive buff ve
beşinci pasif. Sonraki öneri **Lina**, **Juggernaut**, **Dazzle**: caster timing,
melee attack/immune etkileşimi ve heal/buff/debuff kapsamı. Her kitin güncel custom
davranışından sonra kapsam doğrulanır; summon karmaşıklığı gerekiyorsa dördüncü
pilot yerine roster'dan ilgili summon kiti seçilir. Bu aday seçimi kit onarımı değildir.

Her skill için rank1/middle/10; normal creep/grup/elite/boss; invalid target,
immune/resistance/dispel; caster/target death; iki caster; refresh/recast;
Shard/Scepter/talent; soğuk başlangıç; death/reconnect; yoğun dalga ve cleanup
ölçümleri uygulanır. Native kontrol skill'iyle karşılaştırma aynı build'de yapılır.
Beklenen damage/radius/duration ile ölçüm, log, görsel ve ses kanıtı birlikte tutulur.

Mevcut Dota Workshop MCP'de VPK/API/status okuma yetenekleri kullanılabildi;
yeni plugin kurulmadı. Dota bu oturumda çalışmıyor, VConsole erişilebilir değil.
Dolayısıyla hiçbir skill ENGINE_PASS veya DONE sayılmadı. Araç dokümanı ve VM
testi gerçek Dota cast testi yerine geçmez; kapalı map indirme/indexleme bu
araştırmanın parçası olmadı.

## 6. Üretilen altyapı ve bakım

- Root AGENTS ve geliştirme standardı hero başvuru okumasını zorunlu kılar.
- 40 hero talimatı ve 200 ayrı skill kabul defteri, production envanterine bağlıdır.
- Native source snapshot build, kaynak hash ve asset varlık kanıtını saklar.
- `tools/hero_reference_sources.mjs` opsiyonel yerel snapshot toplayıcısıdır;
  mevcut VPK reader'ın yolu parametreyle verilir, host bağımlılığı oyun koduna girmez.
- `tools/hero_reference_docs.mjs --check` güncellik/kapsam/kabul alanlarını kontrol
  eder. `--refresh` generated inventory'yi yeniler, elle yazılan kararları korur.

Gelecek skill görevinde önce ilgili dossier açılır, native karşılık ve sınıflandırma
kanıtlanır, değişiklik yapılır, oyun testi tamamlanır, kabul defteri güncellenir.
Kanıt toplanmadığında PENDING kalır; bu durum açıkça raporlanır.

## 7. Bu paketin doğrulaması

- `node tools/checks.mjs`: 0 başarısız kontrol; yeni hero reference kontrolü dahil.
- `node tools/hero_reference_docs.mjs --check`: 40 talimat / 200 skill defteri geçti.
- `--refresh`: 40 elle yazılan kanıt bölümünün hash'i değişmeden korundu.
- 452 yerel doküman bağlantısı mevcut dosyaya çözülüyor.
- `node tools/verify_models.mjs`: modeller, 216 ability ikonu ve kendi kapsamındaki
  151 literal runtime resource yolu geçti. Snapshot'ın146 yolu daha dar üç dosya
  taramasıdır; sayılar aynı kapsamı ifade etmiyor.
- Git whitespace kontrolü geçti. Production hero/ability/XP/asset kodu değiştirilmedi.
- Dota gameplay/VFX/SFX/VConsole kabulü **PENDING**. Yukarıdaki kontroller bunun
  yerine geçmez. Diğer custom-game kodu veya asset'i içeri alınmadı.
