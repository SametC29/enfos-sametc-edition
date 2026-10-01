**1. ZORUNLU ARAŞTIRMA, TEŞHİS, REFERANS İNCELEME VE OYUN İÇİ DOĞRULAMA PROTOKOLÜ**

Bu listedeki hiçbir göreve doğrudan kod yazarak başlama. Önce sorunu araştır, mevcut projedeki gerçek nedenini tespit et, güncel Dota 2 davranışıyla karşılaştır, çalışan referansları incele ve ancak bundan sonra düzeltme uygula.

Her görevde aşağıdaki çalışma yöntemi ZORUNLUDUR:

### A — Önce mevcut sistemi tamamen anla

Değişiklik yapmadan önce ilgili sistemin projedeki bütün bağlantılarını bul.

İlgili Lua/VScript, KV, npc_abilities_custom.txt, npc_abilities_override.txt, npc_units_custom.txt, npc_heroes_custom.txt, npc_items_custom.txt, Panorama XML/CSS/JS, localization, Hammer entity/trigger, particle, soundevent, model ve diğer asset dosyalarını araştır.

Bir özelliğin yalnızca görünen dosyasına bakma. Özelliğin:

- nerede oluşturulduğunu,
- nerede çağrıldığını,
- hangi eventlerin tetiklediğini,
- hangi modifier'ları kullandığını,
- hangi KV kayıtlarına bağlı olduğunu,
- hangi particle/sound/model dosyalarını kullandığını,
- server ve client arasında nasıl haberleştiğini,
- başka sistemler tarafından override edilip edilmediğini

tespit et.

Kod değiştirmeden önce sorunun muhtemel **root cause**'unu belirle.

Tahmine dayanarak kod değiştirme.

---

### B — Güncel internet araştırması yap

Sorunla ilgili güncel internet araştırması yap.

Öncelik sırası:

1. Güncel Dota 2 base-game dosyaları ve VPK içeriği
2. Valve Developer Community / Dota 2 Workshop Tools belgeleri
3. Güncel VScript / Lua API
4. ModDota dokümantasyonu
5. SteamDatabase / GameTracking-Dota2
6. Güncel GitHub Dota 2 custom-game projeleri
7. ModDota topluluğunda bildirilen sorunlar
8. GitHub Issues
9. Steam Workshop / Steam Community
10. Reddit / Dota2Modding ve benzeri geliştirici tartışmaları

Eski bir rehber bulduğunda onu otomatik olarak doğru kabul etme.

Dota 2 sürekli güncellendiği için eski API, model yolu, ability davranışı, particle, soundevent, KV alanı veya Panorama yöntemi artık çalışmıyor olabilir.

Bulduğun bilgiyi mümkün olduğunca **mevcut Dota 2 sürümüyle doğrula.**

---

### C — Önce Dota 2'nin mevcut native implementasyonunu incele

Sorun native Dota 2 hero, ability, item, unit, model, particle veya sound sistemiyle ilişkiliyse internetten tahmin yürütmek yerine mevcut Dota 2 dosyalarını incele.

MCP erişimi varsa:

- `vpk_find`
- `vpk_read`
- `base_kv_entry`
- `assets_search`
- `lua_api_search`
- `lua_api_get`
- `lua_api_class_methods`
- `soundevents_list`
- `soundevents_get`
- `kv3_read`

gibi araçlardan yararlan.

Native ability'nin güncel KV değerlerini, Lua/API davranışını, projectile'ını, modifier'larını, particle'larını, soundevent'lerini, animation/gesture kullanımını ve gerekli assetlerini tespit et.

Örneğin eski bir Dota skillini projede yeniden üretirken geçmişteki Wiki örneğini değil, mümkün olduğunda **şu anda oyunda çalışan sürümünü** referans kabul et.

---

### D — Aynı sistem başka custom gamelerde yapılmış mı araştır

İstenen özellik veya hata başka Dota 2 custom gamelerinde çözülmüşse çalışan örnekleri incele.

MCP erişimi varsa özellikle:

- `workshop_search`
- `workshop_download`
- `workshop_inspect`
- `workshop_grep`
- `workshop_read`
- `ref_harvest`
- `ref_search`
- `ref_find`
- `ref_inspect`
- `ref_get`
- `dota_patterns`
- `docs_search`
- `docs_get`

araçlarını kullan.

Enfos, Watcher of Samsara veya başka bir oyuna körü körüne bağlı kalma. İhtiyaç duyulan sistemi en iyi uygulayan güncel ve çalışan custom gameleri bul.

Örneğin araştırma konusuna göre:

- wave sistemleri,
- boss AI,
- enemy hero AI,
- spell targeting,
- point targeting,
- unit spawning,
- invisibility/truesight,
- shops,
- item scaling,
- boss rewards,
- particles,
- sounds,
- hero abilities,
- regeneration zones,
- Panorama UI,
- wave UI,
- boss-selection/boon UI

gibi özellikleri ayrı ayrı araştır.

Başka oyunun kodunu körü körüne kopyalama.

Önce **neden çalıştığını**, hangi engine/API davranışına dayandığını ve bizim projeye nasıl uyarlanacağını anlamaya çalış.

Lisanslı/açık kaynak kod kullanılıyorsa lisans koşullarına uy. Diğer oyunları esas olarak mimari ve davranış referansı olarak kullan.

---

### E — Bilinen Dota 2 Workshop problemlerini kontrol et

Sorunun bizim kodumuzdan kaynaklandığını otomatik olarak varsayma.

Önce bunun:

- Dota 2 güncellemesinden,
- deprecated API'den,
- değişmiş KV alanından,
- kaldırılmış/taşınmış modelden,
- değişmiş particle'dan,
- değişmiş soundevent'ten,
- Workshop Tools bug'ından,
- Panorama compile/cache probleminden,
- VPK asset değişiminden

kaynaklanıp kaynaklanmadığını araştır.

Özellikle model gösterilemiyorsa model yolunun mevcut Dota 2 VPK'sinde gerçekten bulunup bulunmadığını doğrula.

`ERROR` modeli görünen bir unit için yalnızca unit scriptini değiştirmekle yetinme; Model, ModelScale, wearable, material, particle ve gerekli precache zincirini de kontrol et.

---

### F — Her sorunu önce yeniden üret

Düzeltmeden önce bug'ı Workshop Tools içinde yeniden üretmeye çalış.

Beklenen davranış ile mevcut davranışı ayrı ayrı kaydet.

Mümkünse minimal reproduction oluştur.

Örneğin bir ability bozuksa tek bir hero üzerinde:

- ability öğren,
- farklı seviyelerde kullan,
- hedefli kullanım,
- point-target kullanım,
- boş zemine kullanım,
- creep üzerinde,
- hero üzerinde,
- boss üzerinde,
- magic immune üzerinde,
- görünmez hedef üzerinde,
- ölü/hedef kaybolmuşken,
- maksimum menzilde,
- cooldown sırasında

gibi gerekli durumları ayrı ayrı test et.

---

### G — VConsole ve runtime durumunu kullan

Sadece statik kod incelemesiyle “çözüldü” deme.

Workshop Tools çalıştır ve VConsole kayıtlarını incele.

MCP destekliyorsa:

- `dota_doctor`
- `addon_audit`
- `addon_build`
- `addon_launch_custom_game`
- `dota_read_console_log`
- `dota_watch_errors`
- `dota_send_console_command`
- `dota_debug_dump`
- `dota_lua_eval`
- `dota_screenshot`
- `dota_selftest`

araçlarını kullan.

VConsole'da en az:

`ERROR`
`FATAL`
`Failed`
`Unable`
`Warning`
`stack traceback`
`.lua:`
`RESOURCE COMPILE ERROR`

ifadelerini kontrol et.

Runtime'da ilgili entity'nin gerçek:

- unit name,
- hero name,
- ability listesi,
- ability level,
- modifier listesi,
- team,
- position,
- HP/MP,
- visibility,
- targetability,
- item listesi

gibi durumlarını gerektiğinde incele.

---

### H — Hot reload ile full restart farkını dikkate al

Her değişikliği aynı şekilde test etme.

Sadece Lua function body değişikliklerinde hot reload kullanılabilir.

KV (`npc_*_custom.txt`) değişiklikleri, yeni script/class kayıtları, hero/unit/item tanımları veya bazı asset değişikliklerinde **full game restart** gerekebileceğini varsay ve buna göre test et.

“Dosyayı değiştirdim ama oyunda değişmedi” durumunda önce cache/reload/restart problemini ele.

---

### I — Ability denetimi yalnızca hasar testi değildir

Bir hero ability kontrol edilirken yalnızca “damage vuruyor mu?” diye bakma.

Her ability için ayrı ayrı kontrol et:

**Gameplay**
- AbilityBehavior
- target type
- target team
- target flags
- cast range
- cast point
- mana cost
- cooldown
- damage
- damage type
- scaling
- radius
- duration
- projectile
- status resistance
- magic immunity
- dispel interaction
- death interaction
- modifier cleanup

**Targeting**
- Unit Target
- Point Target
- No Target
- Directional/Vector davranışı gerekiyorsa doğru hedefleme
- cursor position
- cursor target
- ground position
- invalid target davranışı

**VFX**
- cast particle
- projectile particle
- impact particle
- modifier particle
- particle attachment
- particle control points
- particle destruction/release
- gerekli precache

**SFX**
- cast sound
- projectile/loop sound
- impact sound
- stop sound
- doğru soundevent
- gerekli precache

**Animation**
- cast animation
- activity/gesture
- animation rate
- backswing
- gerektiğinde gesture cleanup

Her ability için bunların çalıştığı oyun içinde doğrulanmadan ability “tamamlandı” kabul edilmemelidir.

---

### J — Görünmezlik / True Sight sistemlerini özel olarak analiz et

Görünmez bir yaratık göz/sentry/true sight olmasına rağmen görünmüyorsa yalnızca vision radius artırma.

Aşağıdakileri ayrı ayrı kontrol et:

- invisibility hangi ability/modifier tarafından veriliyor,
- `MODIFIER_STATE_INVISIBLE`,
- `MODIFIER_STATE_TRUESIGHT_IMMUNE`,
- unit target flags,
- Fog of War,
- team visibility,
- reveal modifier,
- ward/truesight provider'ın gerçekten oluşturulup oluşturulmadığı,
- modifier duration,
- unit'in out-of-game/unselectable/untargetable state'leri,
- native Dota true sight davranışı.

Sorunun engine state mi yoksa bizim custom modifier mantığımız mı olduğunu kanıtla.

---

### K — Particle, sound ve model isimlerini tahmin etme

Bir asset yolunu hafızadan veya eski bir örnekten yazma.

Mevcut Dota 2 VPK içerisinde gerçekten var olduğunu doğrula.

Model, particle veya sound yolu bulunmuyorsa güncel native karşılığını araştır.

Gerekirse asset preview/sound preview araçlarıyla sonucu incele.

Yanlış asset yolunu başka tahmini asset yoluyla değiştirerek deneme-yanılma yapma.

---

### L — En küçük güvenli düzeltmeyi uygula

Root cause belirlendikten sonra mümkün olan en küçük değişiklikle problemi çöz.

Bir bug düzeltirken ilgisiz sistemleri refactor etme.

Birden fazla sistemi aynı commit içinde değiştirme.

Çalışan mevcut davranışları koru.

Gerekmedikçe yeni dependency veya framework ekleme.

---

### M — Bir düzeltme diğer sistemi bozuyor mu kontrol et

Her değişiklikten sonra regression testi yap.

Özellikle:

- wave progression,
- Life sistemi,
- creep spawn,
- boss spawn,
- gold,
- XP,
- Lumber,
- items,
- shops,
- hero leveling,
- skills,
- UI,
- save/load varsa save sistemi,
- multiplayer senkronizasyonu

üzerinde yan etki olmadığını kontrol et.

Tek oyunculu Tools Mode testiyle yetinme; mekanik multiplayer state'e bağlıysa server/client senkronizasyonunu da incele.

---

### N — Testleri ölçülebilir hale getir

“Çalışıyor gibi görünüyor” sonucu kabul edilmez.

Her görev için PASS/FAIL kriteri oluştur.

Örneğin:

`Spellbringer target point = oyuncunun seçtiği koordinat ± kabul edilebilir tolerans`

`Invisible creep + active True Sight = görünür ve hedeflenebilir`

`Missing model count = 0`

`VConsole ERROR/FATAL = 0`

`Ability cast test cases = tümü PASS`

`Boss 5. wave spawn = PASS`

gibi açık kriterler kullan.

Mümkün olan görevlerde otomatik smoke/self-test oluştur.

---

### O — Başarısız çözümü tekrar tekrar yamalama

İlk çözüm çalışmazsa aynı yaklaşımı küçük değişikliklerle tekrar tekrar deneme.

Yeni logları ve runtime durumunu incele.

Hipotezin yanlış olduğunu kabul edip yeniden root-cause analizi yap.

Gerekirse farklı bir çalışan custom game implementasyonunu araştır.

---

### P — Git güvenliği

Büyük değişikliklerden önce mevcut çalışan durumu Git ile koru.

Her bağımsız sorun mümkün olduğunca ayrı commit olsun.

Commit mesajında hangi sorunun düzeltildiğini açıkça belirt.

Çalışmayan denemeleri ana çalışan sürümün üzerine yığma.

Rollback yapılabilecek durumda çalış.

---

### R — “Tamamlandı” kriteri

Bir görevi yalnızca kod yazıldığı için tamamlandı olarak işaretleme.

Tamamlandı diyebilmek için mümkün olduğunca:

1. Root cause belirlenmiş olmalı.
2. Kullanılan API ve assetler güncel kaynaklardan doğrulanmış olmalı.
3. Build başarılı olmalı.
4. KV/asset validation başarılı olmalı.
5. Workshop Tools içinde oyun açılmalı.
6. İlgili mekanik oyun içinde gerçekten test edilmeli.
7. VConsole'da ilgili yeni hata olmamalı.
8. PASS/FAIL testleri geçmeli.
9. Regression kontrolü yapılmalı.
10. Sonuç Git commit ile korunmalı.

Engine'i veya oyunu çalıştırma imkânın yoksa bunu gizleme.

Böyle bir durumda:

`IMPLEMENTED BUT NOT ENGINE-VERIFIED`

olarak raporla ve hangi testlerin hâlâ yapılması gerektiğini açıkça belirt.

**Test edilmemiş bir özelliği “fixed”, “working” veya “completed” olarak raporlama.**

---

### S — Her görev sonunda kısa teknik rapor oluştur

Görev tamamlandığında şu bilgileri ver:

**Problem:** ne bozuktu  
**Root Cause:** gerçek neden neydi  
**Research:** hangi güncel kaynaklar / API / reference games incelendi  
**Files Changed:** hangi dosyalar değişti  
**Fix:** ne yapıldı  
**Tests:** hangi testler yapıldı  
**Result:** PASS / FAIL / PARTIAL  
**VConsole:** kalan error/warning var mı  
**Regression:** hangi sistemler tekrar kontrol edildi  
**Remaining Risk:** hâlâ doğrulanamayan bir nokta var mı

Ama rapor hazırlamak asıl işin yerine geçmez. Öncelik çalışan ve oyun içinde doğrulanmış implementasyondur.

---

## ANA KURAL

**Önce araştır → mevcut sistemi incele → problemi yeniden üret → log/runtime kanıtı topla → güncel Dota 2 native implementasyonunu kontrol et → çalışan custom game örneklerini MCP ile incele → root cause belirle → minimum düzeltmeyi yap → build et → oyunda test et → VConsole kontrol et → regression testi yap → ancak bundan sonra tamamlandı olarak işaretle.**

Tahmin ederek kod yazma.

Eski veya doğrulanmamış Dota 2 bilgilerini gerçek kabul etme.

Başka bir custom game'de çalışan çözüm varsa nasıl çalıştığını incelemeden sıfırdan rastgele sistem üretme.

Ve hiçbir zaman yalnızca kodun mantıksal olarak doğru görünmesini, Dota 2 engine'inde gerçekten çalıştığının kanıtı olarak kabul etme.