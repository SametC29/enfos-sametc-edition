# Steam Workshop — ilk yayın ve güncellemeler

Durum (2026-09-27): **V1.0.1 yüklemesi kabul edildi; indirme doğrulaması bekliyor.**
Workshop ID: **3809160125**. Custom Game etiketi, Public görünürlüğü, yeni başlık,
manifest ve boyut anonim Steam API'sinden doğrulandı. SteamCMD indirmesi hâlâ önceki
V1.0.0 paketini döndürüyor; yeni dosyaların dağıtımı henüz doğrulanmış sayılmıyor.
Oyun kodu temel sürümü: `6eec7db`. Kullanıcı yerel düzeltmeyi kabul etti ve yayını istedi.
Yayın hazırlığı oyun kodunu değiştirmedi. Aşağıdaki V1.0.0 kayıtları tarihsel kanıttır.

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

## Yayın bekletme — 2026-09-28

Kullanıcı bundan sonraki canlı yayınları kendisi söyleyene kadar erteledi.
Yerel geliştirme ve kontroller devam edebilir; yeni yükleme, yeniden yükleme veya
canlı geri dönüş için yeniden açık talimat gerekir. Genel önceki yayın izni bu
bekletmeyi geçersiz kılmaz.

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
