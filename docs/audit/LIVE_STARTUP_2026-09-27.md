# Canlı açılış düzeltmeleri — 27 Eylül 2026

Bu kayıt, önceki denetimin canlı başlatma engelinden sonra yapılan çalışmadır.

## NVIDIA erişim hatası

Kullanıcının ekran görüntüsünde `NVAPI_ACCESS_DENIED` görüldü. MCP başlatması
(PID 5000) kapandı. Aynı addon/harita normal kullanıcı ortamında, kısıtlı ajan
sandbox'ı dışında başlatılınca (PID 14232) NVIDIA hatasını geçti ve haritayı yükledi.
Bu karşılaştırma başlatma ortamındaki erişim kısıtını işaret ediyor; sürücünün
bozuk olduğunu kanıtlamıyor. NVIDIA profili, sürücü, ACL veya sistem ayarı değiştirilmedi.

Tekrarlanabilir yerel başlatıcı: `tools/launch_playtest.ps1`. Normal kullanıcı
PowerShell'inden çalıştırılmalı; bir ajan sandbox'ından çağrılıyorsa gerekli
araç izniyle sandbox dışında çalıştırılmalı. Yönetici olarak çalıştırma talep etmez.
Zaten çalışan Dota varsa ikinci örnek başlatmaz. Kaynak harita derlemez.

Hata kodunun resmi anlamı erişimin reddedilmesidir:
[NVIDIA NVAPI durumları](https://docs.nvidia.com/nvapi/group__nvapistatus.html).

## Gerçek oyun kaydında bulunan ve giderilen hatalar

- `custom_loading_screen.css`, `game_setup.css`, `hero_selection.css` dosyalarındaki
  tarayıcı CSS `linear-gradient` / `radial-gradient` değerleri Panorama tarafından
  reddediliyordu. Native `background-color: gradient(...)` biçimine dönüştürüldü.
- Animasyon adı kullanımındaki tırnaklar `SpinAnimation` ve `LoadingProgressPulse`
  için eksik animasyon hatası veriyordu. Referanslar düzeltildi; Evolution'ın aynı
  türdeki `badge-pulse` referansı da düzeltildi. Keyframe tanımları korunuyor.
- Yalnız `wave_info` kayıtlıydı. Gerçek sunucu/istemci kodunun kullandığı diğer
  dokuz nettable eklendi. Kahraman seçimi için canlı kayıtta tekrarlanan
  `Unknown custom nettable 'hero_selection_state'` hatası doğrulanmıştı.
- `enfos_wave_CLEARED` ve `enfos_wave_cleared` aynı motor anahtarına dönüşüyordu.
  Kısa dalga durumları ayrı `enfos_wave_state_*` adlarına taşındı. Açıklama anahtarı
  korundu; dört dilin iki çalışma kopyası yeniden üretildi.
- Ana kontrol komutu artık sunucu yazmaları ve istemci okumaları/abonelikleri için
  nettable kayıtlarını tarıyor. Çeviri anahtarlarının büyük/küçük harf çakışmasıyla
  farklı değerler üretmesini de hata olarak yakalıyor.

## Doğrulama ve sınırı

Yeni süreç PID 15260; harita `enfos`; normal kullanıcı ortamı; `-condebug` açık.
Güncel `game/dota/console.log` kaydında şu geçişler görüldü:

- 04:36:32: oyun modu, dalga, Spellbringer, ekonomi ve seçim servisleri başladı.
- 04:36:39: zorluk `casual` olarak sunucuda değişti.
- 04:37:11: oyuncu 0, takım 3, Luna seçimi sunucuda kilitlendi; kahraman doğdu.
- 04:37:21: birinci dalga için 15 saniyelik hazırlık başladı.
- 04:37:36: birinci normal dalga, dört parti halinde üretim aşamasına geçti.

Bu yeni açılışın incelenen kaydında bildirilen stil/animasyon hataları, tanımsız
nettable hataları ve Lua stack trace görülmedi. `node tools/checks.mjs` geçti;
34 Panorama kaynağı derlendi, başarısız derleme yok.

Bu kanıt, 20 düşmanın gerçekten oluşturulduğunu, hedefe saldırdığını, dalganın
temizlendiğini veya ilk beş dalganın kabul testinin tamamlandığını **kanıtlamaz**.
Bazı okçular için stuck-recovery kayıtları var; rotanın canlı davranışı incelenmeli.
Yerel VConsole komutları ilerleyen aşamada güvenilir yanıt vermediği için
otomatik oyun içi sorgular başarılı sayılmadı. Geçerli gözlem kaynağı taze disk logudur.

Kullanıcı bu denemenin eski bozuk düz haritada gerçekleştiğini bildirdi. Bu nedenle
bu kaydı harita/rota/savaş kabulü olarak kullanmayın.

## Haritanın geri yüklenmesi ve eski kaynağın emekliye ayrılması

- İki aktif VPK 03:48:34 tarihli yaklaşık 4.7 MB düz prototipti. Kayıtlı harita
  manifestinin özetiyle eşleşmiyordu. Hangi araç/kişi tarafından derlendiği kanıtlanmadı.
- Yanlış paketler `references/enfo_map/quarantined-builds/2026-09-27-placeholder/`
  altında yerel yedeklendi. Mevcut `build_map_theme.mjs` ile daha önce seçilmiş
  Survival düzeni ve sonbahar materyalleri geri yüklendi; yeni referans kodu alınmadı.
- `enfos.vpk` ve `enfos_sametc.vpk` artık 15,275,924 bayt ve aynı SHA-256 özeti:
  `b1fa84fd3d14becfd0fc29e6fec16e0ca6115837090bc72bf6bca2f06ba4fa51`.
- Kullanıcının eski haritayı kaldırma talebi üzerine iki VMAP, `.disabled` uzantısıyla
  `archive/placeholder_maps/` altına taşındı. Aktif `content/maps` içinde değiller.
  Eski üretici ayrıca açık prototip bayrağı olmadan çalışmayı reddediyor.
- `check_map.mjs`, manifestteki 11 dosyanın özetini kontrol ediyor. Başlatıcı ve
  ana kontroller bunu çağırıyor. Aktif klasöre eski VMAP dönerse kontrol başarısız.
- Canlı pencerede yapılar ve yollarıyla önceki Survival haritası görüldü.
  VPK dosyaları Git dışında yerel kalıyor; bu geri yükleme özgün yayın haritasının
  düzenlenebilir kaynağı olduğu anlamına gelmez.

## Yeni seçim ekranı ve onay akışı

- Tam kapalı arka plan, beş rol satırında 40 büyük Dota portresi; sağda seçili
  kahraman, rol/özellik, beş yetenek ve onay düğmesi. Native ekran artık alttan görünmüyor.
- Tüm kahramanlar orijinal Dota adlarını kullanıyor; eksik adların `npc_dota_*`
  olarak görünmesi giderildi. Yeni ekran metinleri EN/TR/RU/zh-CN olarak yazıldı.
- Seçim yalnız sunucu pick tablosu geldikten sonra kilitleniyor. İki saniyelik
  yanıt zaman aşımı ve gönderim istisnası düğmeyi tekrar açıyor. Oyuncu kimliği
  ekran yüklenirken henüz hazır değilse sonraki durum/gönderimde yeniden okunuyor.
- Kullanıcının “onay bekleniyor” bildiriminden sonra istek/ret tanı kayıtları
  eklendi. Önceki takılmanın kesin nedeni mevcut kayıtlarla kanıtlanmadı.
- Son canlı görüntüde yeni ekranın düzeni doğrulandı. Kullanıcı Luna'yı kendisi
  seçip onayladığını açıkça doğruladı; sonraki görüntüde Luna ile doğru harita ve
  birinci dalga HUD'u görüldü. Bu otomatik rastgele seçim olarak sayılmadı.

Kontroller: 68 Lua davranış testi (sahte motor), 7 seçim ekranı davranış testi,
2 KV testi; sözdizimi, veri/çeviri eşleşmeleri ve 11 harita dosyasının bütünlüğü.
34 Panorama kaynağı derlendi; son JS değişikliği ayrıca yeniden derlendi.

Sonraki iş: gerçek düşman sayısı/saldırı/rota ve dalga temizleme akışını ölçerek
ilk beş dalga kabulünü tamamlamak. Önceki denetimdeki diğer eksikler devam ediyor.
