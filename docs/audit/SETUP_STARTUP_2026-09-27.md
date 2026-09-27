# Takım / kahraman seçimi başlangıç düzeltmesi

Durum: yerel test adayı; canlıya yüklenmedi. Kullanıcı hem Workshop sürümünde hem
yerel testte takım değiştirememe ve boş kahraman seçimi bildirdi.

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
  doğrulandı; kullanıcı testi düzeltilmiş başlangıcın motor içi kabulünü sağlayacak.
- Yayınlanan V1.0.0 değişmedi. Yeni aday için kullanıcı onayı beklenir.

## Kullanıcının yerel testi

1. Workshop Tools'ta `enfos_sametc` addon'unu aç; yeni yerel maçı `enfos` haritasıyla
   başlat: `dota_launch_custom_game enfos_sametc enfos`.
2. Takım ekranında Radiant -> Dire -> Radiant geç; ismin seçtiğin takımda görünmeli.
3. Otomatik geçişte veya başlat düğmesinden sonra 5 rolde toplam 40 kahraman görünmeli;
   bir kahraman seçip onayla. Gerekirse ikinci yeni maçta diğer geçiş yolunu dene.
4. Doğru haritada doğduğunu, ilk dalganın başladığını ve reçete alınabildiğini kontrol et.
5. Başarılı olduğunu bildirdikten sonra aynı Workshop kaydına güncelleme yapılabilir.
