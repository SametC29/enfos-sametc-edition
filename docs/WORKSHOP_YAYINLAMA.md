# Steam Workshop — ilk yayın ve güncellemeler

Durum (2026-09-30): **V1.0.5 SteamCMD gönderimi başarılı ve Workshop araması yeni başlığı gösteriyor; bağımsız indirme henüz V1.0.4 paketini veriyor. Yeni boss düzeltmesinin oyunculara ulaştığı doğrulanmadı.**
Workshop ID: **3809160125**. Workshop araması başlığı V1.0.4 gösteriyor ve SteamCMD
`Committing update...Success` verdi. Yükleme günlüğü yeni içerik manifesti
`8279123130043297897` diyor. Buna karşın temiz, ayrı bir SteamCMD indirmesi 25.631.479
baytlık eski paketi ve manifest `7445992684088480157`'yi döndürdü; indirilen VPK SHA-256'sı
`7e6c5e7d1a2149c2e32fd690a29074bce0130760713593a557a8d4880b2d0a87` olup V1.0.3 ile
eşleşiyor. Aday V1.0.4 VPK'sı 25.647.892 bayt ve SHA-256'sı
`8fe4b012dac866db72f9ad34b50c8947707ba8be50471472c983fd9991029c54`; temiz indirmeyle
eşleşmiyor. Bu nedenle yeni içeriğin oyunculara ulaştığı doğrulanmadı.

Steam'in herkese açık dosya ayrıntıları API'si de V1.0.4 başlığını, 25.667.980 bayt
dosya boyutunu ve 2026-09-30 17:45:54 İstanbul güncelleme zamanını gösteriyor; bu
yeni yüklemenin Steam tarafından alındığını doğruluyor. Temiz indirmedeki eski manifest
ise yayımlanan içeriğin hâlâ önceki onaylı sürüm olabileceğini gösteriyor. Steam Support,
belirli topluluk merkezlerinde güncellemelerin moderasyon kuyruğunda tutulabildiğini ve
bu sırada abonelerin önceki onaylı sürümü aldığını belirtiyor. Bu öğenin inceleme durumu
Steam hesabındaki öğe sayfasından/Steam bildirim e-postasından teyit edilmeli.

Steam Support, bazı topluluk merkezlerinde yeni/güncellenmiş UGC'nin inceleme kuyruğunda
kalabildiğini ve onaylanana kadar abonelerin önceki sürümü alacağını belirtiyor
([Steam UGC approval](https://help.steampowered.com/en/wizard/HelpWithUGCSubmission/)).
Bu durum bu öğe için henüz doğrulanmadı; içerik indirimi eski kaldığı sürece V1.0.4 teslim
edildi denmemeli. Aday arşivin statik doğrulaması geçti; oyun içi görsel ve davranış kabulü
kullanıcı testini bekliyor.

V1.0.4 adayı hazırlandı ve mevcut öğeye yükleme için gönderildi; 111 paket girdisi, 25.647.892 bayt VPK ve
SHA-256 `8fe4b012dac866db72f9ad34b50c8947707ba8be50471472c983fd9991029c54`.
Bağımsız VPK doğrulaması ve korumalı harita girdilerinin hash kontrolü geçti. Temiz
indirilen Workshop kopyası adayla eşleşmiyor. Dosya `release/workshop-candidate-v1.0.4/`
altında duruyor; Talent HUD düzeltmelerinin oyun içi kabulü kullanıcı testini bekliyor.

Kullanıcı Steam Workshop'ta herkese açık yayını ve sonraki güncellemeleri istedi.
GitHub'a gönderim için önceki yalnızca yerel commit tercihi devam ediyor.
Computer Use kullanılmayacak. Kullanıcının son tercihi SteamCMD ile yükleme;
şifre ve Steam Guard yalnızca kullanıcının yerel SteamCMD penceresine girilecek.

## Hazırlanan SteamCMD yolu

- `node tools/prepare_workshop_release.mjs`: oyun kodlarına dokunmadan derlenmiş
  içerikten `release/workshop/content/` altında VPK ve `publish_data.txt` üretir.
- `tools/workshop_preview.ps1`: projeye özgü, yazı ve basit şekillerden oluşan PNG
  kapak üretir; başka oyunun görselini içermez.
- `release/workshop/workshop.vdf`: başlık, açıklama, önizleme ve yayın ID'sini taşır.
  Mevcut VDF'nin kimliği ve görünürlüğü korunur; başlık/değişiklik notu release.json
  üzerinden yenilenir. Kapak sürümü de aynı dosyadan okunur. VDF kaybolursa yayın ID'si
  ve Public görünürlüğü kullanılır; yanlışlıkla yeni kayıt oluşturulmaz. Farklı ID
  içeren yerel VDF reddedilir. Sürüm değişiminde başlık/değişiklik notunu da güncelle.
- İlk yayında önce gizli kayıt oluşturuldu, ardından VPK dosyası alınan ID'yle
  adlandırılıp aynı kayda yüklendi. Sonraki güncellemeler doğrudan bu ID'yi kullanır.
- `tools/workshop_tags.ps1 -Apply`: bu projenin VDF'sindeki ID'ye resmi Steamworks
  API üzerinden `Custom Game` etiketi verir. Parametresiz çalışma salt okunur bağlantı
  kontrolüdür. Steam masaüstü oturumu gerekir; şifre veya oturum dosyası okunmaz.
- İçerik doğrulanınca `tools/workshop_tags.ps1 -Apply -MakePublic`, aynı kayıt için
  Custom Game etiketini ve Public görünürlüğünü birlikte gönderir. Başarılı sonuçtan
  sonra VDF görünürlüğü `0` yapılarak sonraki SteamCMD güncellemelerinde korunur.
  Steam sözleşme onayı gerekiyorsa kullanıcı tamamlar.
- SteamCMD komutu: `workshop_build_item "C:/Enfos Team Survival SametC Edition/release/workshop/workshop.vdf"`.
  Kayıtlı giriş başarısızsa şifreyi komut satırı argümanına veya dosyaya yazma.

Hazırlık doğrulaması: 106 dosya, 37.055.536 bayt VPK; bağımsız MCP VPK okuyucusuyla
bütün dosyaların SHA-256 ve uzunlukları karşılaştırıldı. 11 harita/tema dosyası
korundu. `node tools/checks.mjs` sıfır hatayla tamamlandı; canlı oyun testi yapılmadı.
Masaüstü Steam çevrimiçi yapıldıktan sonra kategori/görünürlük güncellemesi başarılı
oldu. Kullanıcı, Steam'in istediği Workshop sözleşmesini kendi hesabında onayladı.
Anonim API sonucu: result=1, visibility=0, banned=0, consumer_app_id=570,
tag=Custom Game. Anonim indirme de Success döndürdü.

## Kopyalanacak yayın bilgileri

Başlık:

```text
Enfos Team Survival - SametC Edition V1.0.0
```

Addon: `enfos_sametc`

Görünürlük: **Public / Herkese açık**

Açıklama:

```text
Enfos Team Survival - SametC Edition

Protect your team's Life Core against waves of enemies in a Dota 2 custom survival game.
Choose your hero, build your items and use Spellbringer abilities to support your team.

This first public version is under active development. Gameplay, balance and compatibility
are still being tested. Please report problems with your hero, wave number and the steps
that caused the issue.

TR
Dota 2 içinde dalgalar halinde gelen düşmanlara karşı takımının Yaşam Çekirdeğini koru.
Kahramanını seç, eşyalarını geliştir ve Spellbringer büyüleriyle takımına destek ol.

Bu ilk herkese açık sürüm geliştirilmeye devam ediyor. Oynanış, denge ve uyumluluk
testleri sürüyor. Hata bildirirken kahramanını, dalga numarasını ve sorunun nasıl
oluştuğunu yazman yardımcı olur.
```

İlk sürüm değişiklik notu:

```text
V1.0.0 — Initial public test release of Enfos Team Survival - SametC Edition.
Gameplay and balance testing are ongoing.
```

## Arayüz gerekirse kullanılacak alternatif

1. Steam hesabın açıkken Dota 2'yi Workshop Tools seçeneğiyle başlat.
2. Addon listesinde `enfos_sametc` seçip araçları aç.
3. Araçlardaki **Workshop Manager / Publish** bölümünü aç. Sürüme göre menü adı
   değişebilir. Eşya/kozmetik gönderimi yerine açık addon'un özel oyun yayınını seç.
4. İlk yayın için yeni bir Workshop kaydı oluştur; yukarıdaki başlık ve açıklamayı gir.
   Daha önce bu proje için kayıt oluşturduysan yeni kayıt yerine onu güncelle.
5. Önizleme istenirse oyundan temiz bir ekran görüntüsü seç; hata penceresi, kişisel
   bilgi veya başka oyunun logosu içermesin. Hazır kapak: `release/workshop/preview.png`.
6. Yayın aracının oluşturduğu addon paketini kullan. Bütün proje klasörünü, referans
   indirmelerini veya masaüstü raporlarını içerik olarak seçme.
7. Mevcut derlenmiş haritayı koru. Eski taslak VMAP'ı yeniden derleme. Araç haritayı
   zorunlu olarak yeniden derlemek isterse işlemi durdurup mesajı paylaş.
8. Yüklemeyi tamamla. Steam bir sözleşme ekranı açarsa kendin incele. Açılan Workshop
   sayfasında görünürlüğü **Public / Herkese açık** olarak kontrol et.
9. Workshop sayfasının bağlantısını paylaş. Başarılı yükleme, herkese açık sayfa ve
   Dota içinden indirip lobi açabilme ayrı kontrollerdir; arama görünürlüğü hemen
   oluşmuş sayılmaz.

## Sonraki sürümler

- İlk başarılı yayının Workshop ID'sini ve bağlantısını buraya kaydet.
- Her seferinde **aynı Workshop kaydını güncelle**; yeni oyun kaydı oluşturma.
- Yalnızca doğrulanmış değişiklikleri yayımla; sürüm numarası ve değişiklik notu ekle.
- Yükleme öncesinde `node tools/checks.mjs` ve `node tools/check_map.mjs` çalıştır.
  Bu kontroller motor içi oynanış testinin yerine geçmez; kullanıcı canlı testi yapar.
- Yayınlanan commit'i, sürümü, tarihi ve derlenmiş dosyaların yedeğini sakla. Harita
  VPK'ları Git tarafından yok sayıldığı için yalnızca Git commit'i geri dönüş paketi değildir.
- Başarılı yükleme ve herkese açık sayfa doğrulanmadan sürümü canlıya alınmış olarak işaretleme.
- Bu talimat bir otomatik yayın servisi kurmaz. Arayüz gerekiyorsa kullanıcı son yüklemeyi yapar.

## Teknik bulgu

Kurulu Dota MCP araçları arasında yayınlama/yükleme aracı yok. Yerel SteamCMD aracı
daha önce anonim Workshop indirmesi için kullanılıyordu. `workshop_build_item`
Steam hesabıyla giriş gerektirir. Yayın paketi ve VDF bu çalışma sırasında hazırlandı;
projenin Workshop ID'si ilk başarılı yüklemeyle alınacak. Dota'nın kurulu yayın
aracındaki `Custom Game` etiketi ve yerel Workshop içeriklerinin VPK/publish_data
biçimi incelendi. SteamCMD'nin key-value etiketleri ile kategori etiketleri aynı
şey değildir; kategori için resmi `ISteamUGC::SetItemTags` kullanılır.

Valve'ın SteamCMD belgeleri: https://partner.steamgames.com/doc/features/workshop/implementation#SteamCmdIntegration

Harita kaynağına ilişkin kayıt `docs/REFERENCE_ANALYSIS_POLICY.md` içindedir:
referans Workshop `3591082091` **bizim oyunumuzun yayın ID'si değildir**. Kullanıcının
yerel harita çalışmasına izni, referans harita yazarından alınmış bir yeniden dağıtım
lisansı belgesi değildir. Yayıncı hak sahipliği beyanı isterse bunu otomatik onaylamayın;
mevcut izin/lisans kaydına göre değerlendirin.

## Yayın bekletme — 2026-09-28 (V1.0.3 için geçersiz kılındı)

Kullanıcı bundan sonraki canlı yayınları kendisi söyleyene kadar erteledi.
2026-09-30'da kullanıcı V1.0.3'ün mevcut Workshop kaydına yüklenmesini açıkça istedi;
bu talimat yalnız V1.0.3 yüklemesini kapsar. Gelecek sürümler için yeniden açık talimat gerekir.

## V1.0.5 gönderim kaydı — 2026-09-30

- Kullanıcı, Wave 5 bossunun %70 can eşiğinde (gözlenen 2.800 HP) kalmasını düzelten
  faz geçişinin aynı herkese açık öğeye gönderilmesini yeniden açıkça onayladı.
- Aynı Workshop ID `3809160125` ve Public görünürlük korundu. V1.0.5 paketi 111 girdi,
  25.663.055 bayt VPK; SHA-256 `2a2d62580cadcc97e22724dceac26f7cefe9e3f2937f817210b4ceea6f115f7a`.
  Paket boss Lua'sının kaynak SHA-256'sını manifestte doğruluyor.
- Tam statik kontroller, harita bütünlüğü ve runtime mock regresyonları geçti.
  Gerçek Dota içi boss testi yapılmadı.
- SteamCMD kayıt `3809160125` için `Committing update...Success` döndürdü. Workshop araması
  `Enfos Team Survival - SametC Edition V1.0.5` başlığını gösteriyor.
- SteamCMD üzerinden yapılan bağımsız indirme 25.647.892 baytlık eski V1.0.4 VPK'sını
  (`8fe4b012dac866db72f9ad34b50c8947707ba8be50471472c983fd9991029c54`) döndürdü;
  yeni adayla eşleşmiyor. Yeni dosyanın abonelere ulaştığı doğrulanana kadar V1.0.5
  gönderilmiş kabul edilir, teslim edilmiş kabul edilmez.

## V1.0.3 gönderim kaydı — 2026-09-30

- Kullanıcı SteamCMD ile V1.0.3'ü mevcut yayına yüklemeyi açıkça istedi.
- Aynı Workshop ID `3809160125` korundu; yeni bir öğe oluşturulmadı. SteamCMD
  `Committing update...Success` verdi.
- `node tools/checks.mjs` ve `node tools/check_map.mjs` geçti. Source 2 içerik derlemesi
  37 dosyayı derledi, 0 hata verdi. Harita/tema için kayıtlı 10 dosya aynı kaldı.
- Paket: 111 içerik girdisi, VPK 25.631.292 bayt; `publish_data.txt` ile toplam
  25.631.479 bayt. VPK SHA-256:
  `7e6c5e7d1a2149c2e32fd690a29074bce0130760713593a557a8d4880b2d0a87`.
- Steam'in herkese açık öğe ayrıntısı: V1.0.3 başlığı, `visibility=0`,
  `consumer_app_id=570`, dosya boyutu 25.631.479 bayt.
- Temiz anonim SteamCMD indirmesi VPK'yi 25.631.292 bayt olarak indirdi ve SHA-256
  yerel VPK ile birebir eşleşti. İlk, önceden kullanılmış indirme klasörü eski
  V1.0.2 manifestini/cache'ini döndürüyordu; bağımsız temiz istemci güncel içeriği aldı.
- Önceki dağıtılmış V1.0.2 paketi aynı doğrulanmış hash ile
  `release/rollback/V1.0.2/` altında geri dönüş kopyası olarak saklandı.
- Workshop araması başlığı V1.0.3 olarak gösterdi. URL:
  https://steamcommunity.com/sharedfiles/filedetails/?id=3809160125
- Dota canlı oyun testi yapılmadı; hüner paneli, puan dağıtımı ve beceri davranışı
  kullanıcı kabulünü bekliyor.

## V1.0.2 gönderim kaydı — 2026-09-28

- İçerik commit'i: `f370a3b`; HUD/skor/hüner ağacı ve Sven düzeltmeleri.
- Tam otomatik kontroller: 0 hata; 13 Panorama XML derlemesi başarılı.
- Paket: 110 dosya, 22.273.882 bayt, 10 korunan harita dosyası değişmedi.
- VPK SHA-256: `4657a7ada54b54eb81887efae19a9553336fdefaad11ea07bebd20d512ce208a`.
- SteamCMD `Committing update...Success` döndürdü ve normal kapandı.
  Kullanıcının yayın bekletme mesajı geldiğinde gönderim zaten tamamlanmıştı;
  yalnız bu projeye ait devam eden yükleme işlemi arandı, aktif işlem bulunmadı.
- Kullanıcıya tamamlanmış gönderim açıklandı. Sonraki uzak mutasyon yapılmadı.
- Güncel herkese açık metadata ve V1.0.2 istemci indirmesi doğrulanmadı.
  Web okuyucusu Workshop sayfasını açamadı. Upload kabulü, Arcade görünürlüğü ve
  yeni paketin oyunculara teslimi aynı şey değildir.
- Yeni motor içi oynanış testi yapılmadı; kullanıcı testi bekleniyor. Ayrıntılar:
  [HUD/Sven denetimi](audit/HUD_SVEN_RELEASE_2026-09-28.md).
- Önceki V1.0.1 paketi yerelde `release/rollback/V1.0.1/` altında korundu.

## V1.0.0 yayın kaydı

- İstenen başlık: Enfos Team Survival - SametC Edition V1.0.0
- Workshop ID: 3809160125
- Workshop URL: https://steamcommunity.com/sharedfiles/filedetails/?id=3809160125
- Yükleme: SteamCMD iki gönderimde de Success döndürdü; son içerik `3809160125.vpk` ve `publish_data.txt`.
- Görünürlük: Public / herkese açık; anonim API ile doğrulandı.
- Custom Game etiketi: resmi API ile uygulandı, anonim API ile doğrulandı.
- Workshop sözleşmesi: kullanıcı onayladı.
- Anonim indirme: başarılı; 37.055.723 bayt toplam içerik.
- VPK SHA-256: `726113e6e559770d3ad11e5e8702f058343fb324502c2d5f8476e086881ec259`
- Arcade arama sırası ve başka bilgisayarda canlı maç: henüz test edilmedi.

## V1.0.1 yayın kaydı — 2026-09-27

- Kullanıcı yerel test sonrası düzeltmenin çalıştığını bildirdi ve canlı yayını onayladı.
- İçerik commit'i: `6eec7db`; takım/kahraman kurulumunu kesen shop API çağrısı kaldırıldı.
- Tek harita: `enfos`; aynı içeriğin `enfos_sametc` harita kopyası kaldırıldı.
  Addon klasör adı hâlâ `enfos_sametc`. Kalan 10 harita/tema dosyası değişmedi.
- `node tools/checks.mjs`: 0 hata. Bağımsız paket kontrolü: 104 dosya, 10 korunan harita
  dosyası, PNG kapak; VPK boyutu 21.779.569 bayt. publish_data ile toplam 21.779.756 bayt.
- VPK SHA-256: `c1703e0e12a455a1b6fefdab72af002173bb303054ddffa609f890bb0f245322`.
- SteamCMD yüklemesi 18:58:52'de Success döndürdü. İçerik manifesti:
  `2361195417708818491`. Anonim metadata yeni başlığı, boyutu ve manifesti doğruladı;
  visibility=0, banned=0, tag=Custom Game.
- İndirme kontrolü henüz geçmedi: anonim ve yayıncı hesabıyla SteamCMD, eski manifest
  `1427547748857073514` ve V1.0.0 hash'ini döndürdü. Yalnız bu kaydı içeren SteamCMD
  manifest önbelleği yedeklenip yenilendiğinde de sunucu eski manifesti verdi.
  Nedeni kesinleştirilmedi; yeni sürümün oyunculara ulaştığı henüz iddia edilmemeli.
- Mevcut Public/Custom Game alanlarını resmi masaüstü API ile yeniden kaydetme girişimi
  önce Steam masaüstü çevrimdışı olduğundan durdu. Kullanıcı Steam'i çevrimiçi yaptıktan
  sonra 19:07:39'da başarılı oldu (legal agreement action=False); yeni içerik manifesti
  korundu. Ardından anonim indirme yine V1.0.0 paketini döndürdü. Görünür Workshop
  sayfasında açıklayıcı bir inceleme/bekleme bildirimi bulunamadı. Yeni paket indirilip
  hash'i eşleşmeden teslim doğrulaması tamamlanmış sayılmamalı.
- Geri dönüş paketi: `release/rollback/V1.0.0/`; yalnız Git commit'i binary yedek değildir.
