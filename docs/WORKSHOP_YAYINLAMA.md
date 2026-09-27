# Steam Workshop — ilk yayın ve güncellemeler

Durum (2026-09-27): **SteamCMD yüklemesi başarılı; kayıt hâlâ gizli.**
Workshop ID: **3809160125**. Doğru ID adlı VPK da aynı kayda başarıyla yüklendi.
Custom Game etiketi ve herkese açık erişim masaüstü Steam bağlantısını bekliyor.
Oyun kodu temel sürümü: `5cb265b`. Oyun içi geliştirme sürümü bu hazırlıkta değiştirilmedi.

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
  İlk hazırlık gizlidir; geçici dosya adı ve kategori tamamlanmadan herkese açılmaz.
  SteamCMD'nin yazdığı ID sonraki hazırlıklarda korunur.
- İlk yükleme ID oluşturduktan sonra hazırlık yeniden çalıştırılır; VPK adı aynı ID'ye
  döner. Aynı Workshop kaydına tam paket yeniden yüklenir.
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
Steamworks başlangıcı sandbox dışında başarılı. Kategori yazımı EResult=3
(bağlantı yok) döndürdü; ardından BLoggedOn kontrolü masaüstü Steam oturumunun
çevrimdışı olduğunu gösterdi. Kullanıcıdan Steam'i çevrimiçi yapması istendi.

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

## Yayın kaydı

- İstenen başlık: Enfos Team Survival - SametC Edition V1.0.0
- Workshop ID: 3809160125
- Workshop URL: https://steamcommunity.com/sharedfiles/filedetails/?id=3809160125
- Yükleme: SteamCMD iki gönderimde de Success döndürdü; son içerik `3809160125.vpk` ve `publish_data.txt`.
- Görünürlük: Private / gizli
- Custom Game etiketi: henüz doğrulanmadı, bağlantı yok hatası
- Herkese açık erişim / Arcade doğrulaması: yapılmadı
