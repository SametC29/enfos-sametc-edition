# Takım / kahraman seçimi başlangıç düzeltmesi

Durum: kullanıcı yerel düzeltmenin çalıştığını bildirdi ve yayını onayladı.
V1.0.1 aynı Workshop kaydına yüklendi; indirme doğrulamasının durumu
`docs/WORKSHOP_YAYINLAMA.md` içinde kayıtlı. İlk bildirim hem Workshop sürümünde hem
yerel testte takım değiştirememe ve boş kahraman seçimiydi.

## Bulgu ve değişiklik

`EnfosSametC:InitGameMode()` içindeki dükkân kurulumu `CDOTA_ShopTrigger:SetSize`
çağırıyordu. Kurulu Dota MCP VScript API kataloğunda `CDOTA_ShopTrigger ->
CBaseTrigger -> CBaseEntity` zincirinde bu metot yok; `SetSize`, ayrı
`CBaseModelEntity` sınıfına ait. Bu çağrı hata verdiğinde Activate, setup manager
kurulumuna ulaşamaz: takım olayları kaydedilmez, kahraman roster nettables yazılmaz.
Önceki testin sahte shop nesnesine SetSize eklemesi bu hatayı gizlemişti.

Desteklenmeyen çağrı kaldırıldı. `SpawnDOTAShopTriggerRadiusApproximate` kendi
alanını oluşturur; merkez (0,0,256), yarıçap 18000. Regresyon testi artık gerçek
shop API'si gibi SetSize içermez; kurulumun bir kez çalışmasını ve HOME tipini denetler.
Marketin iki yükseltilmiş platformdaki reçete erişimi motor içinde tekrar denenmeli.

`enfos.vpk` ve `enfos_sametc.vpk` silme öncesinde aynı hash'e sahipti. İç harita adı
olan `enfos` korundu; gereksiz kopya ve alias overview kaldırıldı. Addon listesi,
DefaultMap, yerel test başlatıcısı ve tema üreticisi yalnızca `enfos` kullanıyor.
Kalan 10 harita/tema dosyasının hash'i değişmedi; harita yeniden derlenmedi.

## Doğrulama ve sınır

- `node tools/checks.mjs`: 0 hata; düzeltilmiş shop API regresyonu dahil.
- `node tools/check_map.mjs`: kalan 10 dosya aynı.
- Canlı VConsole bağlantısı yoktu; mevcut console.log değişikliklerden önceki
  oturuma ait. Son ekranın çalışma zamanı stack trace'i alınamadı. API hatası kodda
  doğrulandı; kullanıcı daha sonra "düzelmiş, canlıya alabilirsin" diyerek yerel
  düzeltmeyi kabul etti. Bu onay bütün kahramanların/oynanışın test edildiği anlamına gelmez.
- V1.0.1 yüklemesi SteamCMD tarafından kabul edildi; yayın paketinde oyun kodu
  commit `6eec7db` ile aynı. Korunan 10 harita dosyası yeniden derlenmedi.

## Kullanıcının yerel testi

1. Workshop Tools'ta `enfos_sametc` addon'unu aç; yeni yerel maçı `enfos` haritasıyla
   başlat: `dota_launch_custom_game enfos_sametc enfos`.
2. Takım ekranında Radiant -> Dire -> Radiant geç; ismin seçtiğin takımda görünmeli.
3. Otomatik geçişte veya başlat düğmesinden sonra 5 rolde toplam 40 kahraman görünmeli;
   bir kahraman seçip onayla. Gerekirse ikinci yeni maçta diğer geçiş yolunu dene.
4. Doğru haritada doğduğunu, ilk dalganın başladığını ve reçete alınabildiğini kontrol et.
5. Başarılı olduğunu bildirdikten sonra aynı Workshop kaydına güncelleme yapılabilir.

## 30 Eylül 2026 — Kurulum ekranı tepkisizliği

Kullanıcının yerel ve Workshop sürümünde takım/zorluk seçememe ve başlatamama
bildirimi üzerine kaynak ve Dota tanısı karşılaştırıldı. `waves/creep_ai.lua`
dosyasındaki `CreepAI:OnThink` fonksiyonuna fazladan bir `end` eklenmişti.
`addon_game_mode.lua`, `Activate` çağrılmadan önce `waves/wave_manager` dosyasını
yüklüyor; o da `creep_ai` dosyasını `require` ediyor. Lua sözdizim hatası oyun
modu başlangıcını kesiyor, kurulum yöneticisinin event dinleyicileri/nettable
durumu hiç kurulmuyor ve Panorama yalnızca yedek slotları ile statik
`Auto-starting...` metnini gösteriyordu. Bu, önceki `SetSize` hatasından ayrı ve
bu kez statik denetimle doğrulanmış kök nedendir.

Fazla `end` kaldırıldı. `Activate` içinde kurulum yöneticisi artık dalga
yöneticisinden hemen sonra başlatılıyor; sonraki sistemlerden biri hata verse bile
kurulum ekranı ilk snapshot'ı ve giriş dinleyicilerini alıyor. Her başlangıç
aşamasına `[ENFOS_BOOT]` kayıtları eklendi; kalan bir başlangıç hatası olursa son
başarılı aşama kayıttan belirlenebilir.

Doğrulama: iki ilgili Lua dosyasının sözdizimi geçti; Steam addon kopyasındaki
`creep_ai.lua` SHA-256'sı çalışma ağacındakiyle eşleşti. `node tools/checks.mjs`
artık bu Lua sözdizim hatasını vermiyor; kalan beş kontrol hatası bu düzeltmeden
bağımsız mevcut çeviri, tooltip, dalga denetimi ve test beklentisi sorunları.
Çalışan Dota sürecinde gizli `Stall Detected` penceresi de görüldü; bu süreç eski
yüklü Lua'yı bellekte tuttuğundan düzeltmenin oyun içi davranışı henüz
doğrulanmadı. Yayın yapılmadı. Yerel kabul için yeni Dota sürecinde takım geçişi,
zorluk seçimi, sayaç ve Start Game denenmeli; bu kullanıcı testini bekliyor.
