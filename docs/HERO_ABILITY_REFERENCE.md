# Kahraman ve yetenek teknik başvuru rehberi

29 Eylül 2026. Bu dosya `HERO_ABILITY_DEVELOPMENT_GUIDELINES.md` standardının
uygulama rehberidir; ürün kurallarını veya kahramanların doğrulama durumunu
yeniden tanımlamaz. Her görevde [kahraman dizininden](heroes/README.md) ilgili
`AGENTS.md` ve `ABILITIES.md` okunur. Oyun dosyasındaki değer ile dosyadaki
envanter çelişirse önce kaynak ve envanter uzlaştırılır.

## 1. Kaynak sırası ve kanıtın anlamı

1. Kurulu Dota'nın ilgili build'indeki hero/ability KV, localization, native
   particle, model ve sound-event tanımı: gerçek kimlikler ve kaynaklar.
2. Valve Workshop belgeleri ve kurulu addon örnekleri: desteklenen motor deseni.
3. ModDota'nın konu rehberleri/API kaydı: açıklama ve uygulanabilir teknik desen.
4. Sürümü sabitlenmiş GameTracking: yerel kaynağı karşılaştırma veya erişim yokken
   geçici bulgu; kurulu build ile eşleştiği ayrıca kanıtlanır.
5. Yetenek eğitim depoları: kavramsal örnek; eski davranış, eksik animasyon,
   Aghanim veya hata içerebilir. Lisans ve commit kaydı olmadan kod alınmaz.
6. Başka PvE custom oyun: tasarım ve gerektiğinde lisanslı uygulama kaynağı.
   Kullanıcı 2026-09-29 tarihinde genel kod aktarım yasağını kaldırdı. Kaynak sürümü,
   lisans, dağıtım uyumu, atıf ve bağımlılıklar doğrulanınca kod/KV uyarlanabilir.
   Özel asset hakları ayrı doğrulanır; belirsiz kaynak reference-only kalır.

`FILE_VERIFIED`: kaynak arşivde bulundu/okundu. `STATIC_REVIEW`: kod incelemesi.
`MOCK_PASS`: taklit motor testi. `ENGINE_PASS`: gerçek Dota testi, build ve kanıt
ekli. Bunlar birbirinin yerine geçmez. Sonuçlar her kabul alanında
`PASS / FAIL / PENDING / N/A` olarak tutulur; N/A gerekçesiz kullanılamaz.

[Kaynak snapshot'ı](audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json) 40 native hero'nun
doğrudan alanlarını ve literal asset varlığını kaydeder. Native skill'in tam
mekaniğini, CP semantiğini, sound event'i veya sahnede görünmesini doğrulamaz.
Yeni Dota patch'inde kaynak hash/build tekrar karşılaştırılır.

## 2. Custom map'te hero ve skill düzenleme sınırları

`npc_heroes_custom.txt`: kahraman override'ı, statlar ve ability yuvaları.
`npc_abilities_custom.txt`: yeni özel yeteneğin kimliği, BaseClass, ScriptFile,
cast/target/rank kuralları, sayısal değerler. `npc_abilities_override.txt`:
desteklendiği doğrulanan native tuning. Lua class: gerçek özel davranış.
`addon_game_mode.lua`: mevcut precache sahipliği. Localization: oyuncu açıklaması.
`roster.lua` KV'den üretilir; bağımsız elle tutulan ikinci doğru değildir.

Model, ikon ve yetenek uygulaması üç ayrı şeydir. `AbilityTextureName` native
ikon kullanır; projectile, stun, ses, animation veya native mekanik eklemez.
`BaseClass=ability_lua` özel implementasyon demektir. Native ability BaseClass
kullanımının iç C++ davranışını sınırsız değiştirilebilir hale getirdiği
varsayılmaz. [KV ve native override rehberi](https://moddota.com/abilities/ability-keyvalues)

Hero'nun native slotları ile Enfos slotları aynı sırada olmak zorunda değildir.
Örneğin kurulu Sven'de native ultimate Ability6'dadır; bizim R Ability4'tedir.
Native counterpart eşlemesi slot numarasından veya ikon adından çıkarılmaz.
Kalıcı Enfos kimliği korunur; isim değişimi ancak migration gerekçesiyle yapılır.

## 3. Her skill için önce davranış sözleşmesi

Koddan önce `ABILITIES.md` kaydını doldur:

- Kullanıcının gördüğü amaç, native özgün mekanik ve hangi parçası PvE'de sorunlu.
- KEEP / TUNE / PVE-CONVERT / REPLACE sınıfı ve kaynaklı gerekçe.
- Cast -> travel/channel -> impact -> ongoing effect -> cleanup sırası.
- Normal creep, elite ve boss sonucu; damage/heal türü, target flags, immunity,
  dispel, status resistance ve projectile dodge politikası.
- Sayısal kaynaklar, başlangıç/son rütbe; snapshot mı anlık değer mi kullanıldığı.
- Animation, ikon, cast/travel/impact/persistent VFX ve SFX; her birinin sahibi.
- Shard/Scepter, Evolution, Ascended, proc ve summon etkileşimi.

Pasif, heal, buff veya savunma mekaniklerini sırf PvE diye hasar büyüsüne çevirme.
Mana burn/stat steal gibi PvP yönlü bileşenler için yalnız o bileşeni değerlendir.
Boss'u tamamen kontrolsüz bırakmak veya bütün kontrollerden bağışık yapmak
otomatik varsayım değildir. Belirsiz tasarım maddesini open items'a yaz.

## 4. Eksik görseli teşhis etme

Önce kullanılan asset türünü doğrula: cast, projectile, impact, aura veya ambient.
Parent sistem ve child sistem aynı şekilde kullanılamaz. Dosyanın VPK'de olması,
yanlış amaçla kullanıldığında çalışacağını göstermez.

Her particle için dossier'de şu kayıt gerekir:

| Alan | Kaydedilecek kanıt |
| --- | --- |
| Kimlik | Logical `.vpcf` yolu; arşivdeki `.vpcf_c` karşılığı; build/hash |
| İşlev | Cast/projectile/impact/ambient ve parent/child bilgisi |
| Konum | Entity/world; attachment türü; model attachment adı |
| Control points | Her kullanılan CP'nin anlamı, bağlandığı entity/vector |
| Boyut | Görsel alan ile gerçek gameplay radius/range uyumu |
| Sahiplik | One-shot, modifier, projectile veya süreli tracker |
| Temizleme | Expiry, recast, interrupt, death ve target loss |
| Test | Gerçek Dota görüntüsü ve VConsole kaydı |

CP0/CP1/CP3 gibi indeksleri başka particle'dan ezbere alma. Asset Browser/Particle
Editor ve gerekiyorsa decoded kaynak üzerinden anlamlarını kontrol et. Hero'nun
Model Editor'ında attachment gerçekten var mı bak. Yanlış CP, yanlış world/entity
konumu veya child seçimi görünmeyen/yanlış yerde görünen efekt üretebilir.
[Particle attachment ve CP rehberi](https://moddota.com/scripting/particle-attachment)

Gameplay hedefi, görsel hedefi ve ses hedefi aynı olayın parçası olmalı. Caster'da
yaratılan impact particle'ının hedef noktada görüneceğini varsayma. Bir spell'e
yalnız impact eklemek uçuş evresini oluşturmaz.

## 5. Projectile ve channel kontrolü

Projectile gerekiyorsa native karşılığın tracking/linear yapısı doğrulanır.
EffectName, spawn konumu/attachment, hedef, hız, mesafe, başlangıç/son radius,
collision, callback ve kaybolan hedef davranışı ayrı kontrol edilir.

Cast anında hasar verip ardından uçan görsel eklemek, seyahat eden bir saldırıyla
aynı davranış değildir. Etki zamanı sözleşmede belirtilir; impact callback'i
birden çok target veya entity için mükerrer hasar üretmemeli.

Channel için start, think, başarılı finish, kesilme ve caster death yolları
tanımlanır. Callback'in adı veya KV channel flag'i tek başına heal/damage tick
uygulaması değildir. Loop sound, animation gesture ve thinker tüm çıkış
yollarında sonlanmalıdır. Görsel/hasar tick aralığı ve mana tüketimi ayrı ölçülür.

## 6. Ses zinciri

Sound event adı ile ses dosyası yolu aynı değildir. Dossier'de event adı,
tanımlandığı sound bank, kaynak build, emission entity/position ve lifecycle
kaydedilir. Bank'ın bulunması event'in o bank içinde bulunduğunu kanıtlamaz.
SoundSet de bütün spell eventlerinin precache edildiğinin garantisi değildir.

Cast, travel, impact ve loop birbirinden ayrı olaylar olabilir. Her tekrar
kullanımda ses birikmesi, yanlış entity'den çalma, hedef öldüğünde takılı loop ve
interrupt sonrası devam etme test edilir. Native spell veya modifier sesi zaten
üretiyorsa bir de custom EmitSound ekleyerek çifte ses yaratma.

Efekt var ama ses yoksa: event spelling/case -> event tanımı -> bank precache ->
emission target -> audio ayarı -> cold start -> console. Ses duyuldu iddiası için
gerçek dinleme gerekir; screenshot ve dosya varlığı yeterli değildir.
[Ses event'i ve precache örnekleri](https://moddota.com/abilities/datadriven/datadriven-ability-events-modifiers)

## 7. Precache ve temizleme

Mevcut `Precache(context)` ve hero/unit precache'ini incele; ikinci paralel
precache manager ekleme. Kullanılan hero dışındaki particle/sound/model için
doğrulanmış ek kaynak listesi gerekir. Yalnız seçilen hero'nun varlıklarına
güvenmek cross-hero effect'lerde sorun çıkarabilir. Tüm Dota'yı precache etme.
KV/Lua ve logical/compiled yolları motorun beklediği kullanımda ayırt et.
[Precache rehberi](https://moddota.com/scripting/precache-fixing-and-avoiding-issues)

Particle ownership açık olmalıdır:

- Self-terminating one-shot: sistemin gerçekten sonlandığı doğrulanır; index
  bırakılır. Her one-shot için körlemesine erken destroy eklenmez.
- Persistent Lua effect: expiry/interrupt/death/recast yollarında destroy ve
  index release sorumluluğu vardır.
- Modifier-owned effect: modifier ownership/`AddParticle` veya `GetEffectName`
  kullanımı doğrulanır; aynı index için iki farklı cleanup sahibi oluşturulmaz.

`ReleaseParticleIndex` handle/index'i bırakır; persistent effect'in süreli bir
one-shot'a dönüşeceğinin garantisi değildir. `DestroyParticle` ile lifecycle
sonlandırma ayrı operasyondur. API erişilebilirliği ve imzası güncel build'e göre
doğrulanır. [Particle ve modifier API](https://docs.moddota.com/lua_server/)

Cold-start testi zorunludur: yeni Dota oturumu, test hero'su öncesinde başka hero
veya particle gösterilmeden. İkinci denemede çalışan effect, önceki yükleme
nedeniyle eksik precache'i gizleyebilir. Lua reload; KV, asset veya kalıcı modifier
state'ini eksiksiz yeniden yüklemiş sayılmaz. Değişikliğe uygun full restart yap.

## 8. Modifier, passive, aura ve kalkan

LinkLuaModifier/class/ScriptFile eşleşmesi; server/client sınırı; buff/debuff,
purge/death, stack/refresh/multiple-caster ve Break davranışı doğrulanır.
GetIntrinsicModifierName olması pasifin etkisini doğrulamaz; ilgili DeclareFunctions
ve property/event callback'lerinin gerçekten kullanılması gerekir.

Rank artarken cached değer güncelleniyor mu? Mevcut süre/stack/barrier korunuyor
mu? OnRefresh içinde OnCreated çağırmak bazı mekaniklerde mevcut kaynakları
sıfırlayabilir; otomatik çözüm sayılmaz. Aura source ve alıcı modifier birlikte
test edilir. Ölü caster, silinen ability ve geçersiz target handle korunur.

Kalkan hasarı engelleme, buff tooltip ve health-bar gösterimi farklı kabul
alanlarıdır. Yalnız fiziksel attack block veren property, tüm damage barrier
olarak anlatılmaz. Güncel barrier property'leri, istemci raporu ve transmitter
gerekleri doğrulanır; mock engine sağlık çubuğunu çizmez.
[Custom barriers](https://moddota.com/abilities/lua-modifiers/5),
[server/client transmitter](https://moddota.com/abilities/server-to-client)

## 9. 50 seviye / 10 rütbe hedefi

Hedef 10 toplam rütbedir; öğrenme üstüne 10 ek upgrade anlamına gelmez.
50 maç içi seviye vardır; hesap/ustalık ilerlemesi yoktur. Talentsiz seviye 2–50 bütçesi 49 puandır.
native innate'i ayrı tutulur. Ücretsiz pasif 1 ise 49 harcanabilir puan gerekir;
başlangıç, son seviye ve XP eşikleri açık sözleşmeyle kurulmalıdır.

Bu rehber migrasyonu uygulamaz. Mevcut rank değerleri dossier'de CURRENT,
10-rank eğrisi TARGET olarak ayrı tutulur. Bütün KV değerleri kör interpolasyonla
uzatılmaz; scalar sabit veya açık 10 değerli dizi kaydedilir. Son rütbede native
internal limit, HUD, modifier refresh ve cooldown/mana test edilir. Spell rank'i
artınca otomatik Scepter/Shard mekaniği açılmış gibi davranılmaz.

Evolution, Shard/Scepter, Ascended ve kalıcı progression aynı bonusu yanlışlıkla
birden çok kez uygulamamalı. Respawn/reconnect free rank veya skill puanı yeniden
üretmemeli. Normal Dota item davranışı upstream'den gelir; tüm shop'u fork etme.

## 10. Performans ve gerçek kabul

Sınırsız summons/thinkers/recursive procs yok. Planlı hostile waves uncapped
kalır. Test repeated cast, Refresher, çoklu caster ve yoğun dalga içerir. Sürekli
global tarama veya tüm creep başına gereksiz sık timer eklenmez.

Her skill için ayrı kanıt: gameplay, targeting, rank/scaling, VFX, SFX, animation,
modifier, precache, cleanup, boss, Shard/Scepter, tree/items, dört dil tooltip,
performance, respawn/reconnect ve Dota/VConsole. Pasif için cast projectile N/A
olabilir; icon/buff/attack feedback yine incelenir. Gereksiz VFX/SFX spam üretme.

EN/TR/RU/zh-CN tooltip aynı gameplay gerçeğini anlatır; visible hard-coded text
eklenmez. Native localization karşılığı ile bizim özel davranış karıştırılmaz.
[Duration tooltip örneği](https://moddota.com/abilities/abilityduration-tooltips)

## 11. Araçlar ve kaynak yenileme

Mevcut inceleme/test araçları:

```text
node tools/audit_heroes_deep.mjs
node tools/hero_reference_docs.mjs --check
node tools/checks.mjs
node tools/verify_models.mjs
```

`test_real_abilities.mjs` gerçek KV değerleriyle MOCK testtir, gerçek Dota değildir.
`simulate_hero_kits.mjs` hand-authored estimator motor combat simulation'ı değildir.
`verify_particles.mjs` sınırlı liste ve bu makineye özgü reader kullanır; bütün
hero asset'leri doğrulanmış sayılmaz.

Native snapshot'ı yenilemek için mevcut host reader ile açıkça çalıştır:

```text
node tools/hero_reference_sources.mjs --write --dota-root <Dota root> --vpk-module <existing VPK reader>
node tools/hero_reference_docs.mjs --refresh
node tools/hero_reference_docs.mjs --check
```

Collector production koduna girmez. Dinamik particle path ve sound bank
birleştirmelerini kapsamıyor; bunlar manuel takip edilir. Snapshot build değişimi
varlığı doğrular, eski ENGINE_PASS kanıtının yeni build için geçerliliğini otomatik
vermez. `--refresh` yalnız inventory bloğunu günceller; hand-written kabul
kayıtlarını silmez. Değişen behavior/asset için önceki runtime pass tekrar açılır.

## 12. Resmi başvuru bağlantıları ve erişim durumu

Valve sayfaları bu araştırmada doğrudan 403/erişim hatası verdi; içerikleri
okunmuş gibi sunulmadı. Sonraki agent ulaşabiliyorsa güncel içerikle karşılaştırır:

- [Lua Abilities and Modifiers](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Lua_Abilities_and_Modifiers)
- [Scripting API](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API)
- [Sounds](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Sounds)
- [Debugging Lua scripts](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Debugging_Lua_scripts)
- [Particle System Overview](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Particles/Particle_System_Overview)

ModDota metinleri okundu; bazıları eski data-driven örnek içerir. Lua için
data-driven event/action syntax'ı doğrudan uygulanmaz. API kaydı da runtime
kanıtı değildir. Başka haritaların kaynakları bu rehbere aktarılmadı.
