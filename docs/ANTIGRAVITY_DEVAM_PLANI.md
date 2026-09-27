# Antigravity devam planı — 27 Eylül 2026

## Başlangıç noktası

Bu belge yeni bir oyun tasarımı değildir. Mevcut tasarımı, kodda gerçekten çalışan
özelliklere dönüştürmek için denetimden çıkan uygulama sırasıdır.

- Çalışma dizini: `C:/Enfos Team Survival SametC Edition`.
- Denetim düzeltmeleri: `4778f21` ve `bb7c1ad`; dal: `codex/project-hardening`.
- Önce çalışma ağacını ve güncel commit'i kontrol et. Bu commit'lere geri dönme;
  sonradan eklenen çalışmaları koru.
- Kullanıcının geçerli kararı **yalnızca yerel commit**. AGENTS.md veya eski
  belgelerdeki genel push adımı bu proje için şu anda uygulanmayacak.
- Aynı dosyalarda tek yazan taraf olsun. Başka bir araç/ajan aktif olarak dosya
  değiştiriyorsa çakışan işi koordine et; rutin düzeltmeler için yeniden onay isteme.
- Kahramanların görünen isimleri orijinal Dota isimleri. Diğer custom oyunlar
  mekanik referansıdır; özel kodları, görselleri ve sesleri kopyalanmayacak.
- Mevcut çalışan harita dosyalarını koru. Eski kaynak haritaları veya tüm content
  ağacını körlemesine derlemek mevcut haritayı eski taslakla değiştirebilir.

Önce [denetim raporunu](audit/CODEX_AUDIT_2026-09-27.md) ve
[kararları](DECISIONS_OPEN_ITEMS.md) oku. Ele aldığın sistem için
[oyun tasarımı](GAME_DESIGN_MASTER.md), [mimari](TECHNICAL_ARCHITECTURE.md) ve
[test koşullarının](QA_BALANCE_RELEASE.md) ilgili bölümünü kullan. Masaüstündeki
rapor geçmiş çalışmanın iddiasıdır; tasarımın veya doğrulamanın yerine geçmez.

## İlk iş: oyunun açıldığını ve ilk beş dalganın oynandığını kanıtla

Güncelleme: [canlı açılış düzeltmeleri](audit/LIVE_STARTUP_2026-09-27.md) NVIDIA
erişim engelini başlatma ortamında aştı; yeni kayıtta kahraman seçimi ve dalga 1
başlangıcı görüldü. Bu düzeltmeleri koru; beş dalganın tamamı henüz doğrulanmadı.

Yeni kahraman, eşya veya arayüz ekleyerek başlama. Son MCP başlatma denemesinde
Dota işlemi kapandı; neden henüz belirlenmedi. Önce güncel hata kaydını ve yeniden
üretim adımlarını al. Eski console.log dosyasını yeni denemenin sonucu sayma.

1. `node tools/checks.mjs` ile mevcut başlangıç durumunu kaydet. Başarısız kontrol
   varsa önce nedeni incele; testi kaldırarak veya başarı koşulunu gevşeterek geçirme.
2. MCP ile Dota/Workshop durumunu, addon yolunu ve başlatılan harita adını doğrula.
   Açılış sorununu yeni log/crash kaydıyla daralt; nedenini kanıtlamadan tahminle
   toplu kod/harita değişikliği yapma.
3. Tek oyunculu normal maçta seçim → kahraman doğması → ilk dalga → beşinci dalga
   akışını çalıştır. İlk dalganın normal planı 12 asker + 8 okçudur. Planlanan,
   gerçekten oluşturulan, öldürülen ve sızan birlik sayılarını ayrı ölç.
4. Düşmanın kahramana saldırdığını, kahraman uzaklaşınca rotasına döndüğünü;
   sızıntının Life'ı yalnız bir kez düşürdüğünü doğrula. Erken dalga butonunun
   uygun olmayan durumda veya art arda tıklamayla çift dalga başlatmadığını dene.
5. Beşinci dalgada sıradan birlik kalmaması ve takım başına yalnız boss gelmesi;
   öldürme/sızıntı ayrımında ödüllerin doğru olması koşullarını kontrol et.
6. Portal gidiş/dönüşü, hareket eden minimap işaretleri, yetenek açıklamaları ve
   üst HUD görünürlüğünü oyunda kontrol et. Önceden bildirilen bu sorunları yalnız
   dosyada ilgili kod bulunduğu için kapatma.

Canlı test mümkün değilse `CANLI TEST BEKLİYOR` yaz; bağımsız kod/test işlerine
devam et. Açılışın ve oynanabilirliğin doğrulandığını iddia etme. Tek oyunculu
sonuçlar PvEvP ve çok oyunculu kabulün yerine geçmez.

## Sonraki işler: bir sistemi bitir, sonra genişlet

Bu sıra tasarım hedeflerini azaltmaz; çalışmayan iskeletlerin sayısını artırmayı
önler. Mevcut 40 kahramanı silme; önce beş referans kahramanın davranışını tamamla.

| Sıra | İş paketi | Kabul kanıtı |
|---|---|---|
| 1 | Sven, Juggernaut, Drow Ranger, Lina ve Omniknight'ın bütün yetenekleri | Her yetenekte gerçek etki, sayısal açıklama, hedef filtresi, süre, mana/cooldown, ikon/efekt/ses; pasif, Shard ve Scepter davranışlarıyla uyum. Test + canlı örnek. |
| 2 | Ascended eşyalar: önce temsilî altı, sonra kalanlar | Ana eşyanın gereken işlevi korunuyor; açıklamadaki aktif/pasif çalışıyor. Yükseltme, başarısızlıkta iade, satış, ölüm ve tekrar satın alma çoğaltma üretmiyor. 21 eksik aktif işlevin envanteri referans alınmalı. |
| 3 | Evolution ve Boon/Pact | Yalnız seçim kaydı değil, gerçek savaş/ekonomi etkisi; yığın sınırı, süre, ölüm ve yeniden bağlanmada korunma; ikinci kez uygulamama. Erteleme penceresi kendiliğinden tekrar açılmıyor. |
| 4 | Boss'lar, çağrılan birlikler ve maç sonu | 12 boss için vaat edilen mekanikler, kontrol/reflect sınırları, sınırlı entity ömrü ve boss-only koşulu; 60. dalga sonrası gerçek maç sonucu/kararlaştırılmış geçiş; maç başlangıcında sürümlü ayar kopyası. |
| 5 | Kalıcı ilerleme ve zorluk açılması | Maç sonucu ödülü yalnız bir kez işleniyor; backend kapalıyken maç sürüyor; kalıcı kayıt varsa yeniden açmada geri geliyor. Legacy/Mastery etkileri gerçekten uygulanıyor. Bellek içi kayıt kalıcı diye sunulmuyor. |
| 6 | Kalan kadro, diller ve denge | 40 kahramanın 200 yeteneği tek tek inceleniyor; dört dilde gerçek metin; çok oyunculu test, 30 dakikalık hedef ve birikmeyen birim/thinker sayısı ölçülüyor. |

Evolution, yetenek tasarımı veya maç sonu konusunda karar belgelerinde gerçek bir
çelişki varsa önce mevcut kullanıcı kararlarını ve diğer belgeleri incele. Maddi
ürün kararını sessizce değiştirme; çözülemeyen dar soruyu DECISIONS_OPEN_ITEMS.md'ye
yaz. Sayısal denge tohumları ve olağan uygulama tercihleri için gereksiz onay isteme.

## Her iş paketinde çalışma yöntemi

1. İlgili mevcut kodu bul; aynı işi yapan ikinci bir manager oluşturma.
2. Beklenen davranışı ve hatanın tetiklenmesini yaz. Gerçek KV/Lua üretim verisini
   kullan; testte ayrı bir kahraman veya dalga listesi üretme.
3. Davranışı küçük, geri alınabilir değişiklikle düzelt. Kritik hatada önce
   başarısızlığı yakalayan regresyon senaryosu oluştur; test yalnız fonksiyonun
   varlığını değil hasarı, hedefi, kaynak değişimini veya süreyi denetlesin.
4. İlgili kontrolleri çalıştır ve diff'i incele. Çalışan kontrolleri değiştirmeden
   tekrar tekrar çalıştırmak yerine bir sonraki kabul koşuluna ilerle.
5. Kalıcı davranış değiştiyse belgeleri ve açıklamaları güncelle. Bir mantıksal iş
   için bir yerel commit oluştur; ilgisiz dosyaları dahil etme.

Yararlı mevcut kontroller (proje kökünde):

```text
node tools/checks.mjs
node tools/roster.mjs --check
node tools/wave_economy.mjs --check
node tools/audit_content.mjs
```

İlk komut ana kontrol girişidir; roster/ekonomi kontrollerini zaten içerir.
Diğerlerini ilgili veriyi araştırırken kullan. İçerik denetimi yerel Dota VPK ve
MCP kurulumuna ihtiyaç duyar ve `docs/audit/content-audit.json` dosyasını günceller;
güncel kurulum yoksa bu kontrolün çalışmadığını açıkça kaydet.

MCP addon denetimi yapısal kontroldür. VPK'da ikon/efektin bulunması onun oyunda
doğru oynadığını kanıtlamaz. Mock test, Panorama derlemesi ve canlı test ayrı
kanıtlardır. Geçerli API davranışını gerektiğinde MCP/Valve belgelerinden doğrula.
Arayüz için yalnız ilgili Panorama kaynaklarını derle; kaynak harita doğrulanmadan
genel content/map derlemesi yapma.

## Raporlama: durum ile kanıtı ayır

“Faz bitti”, “200 skill hazır”, “%100 çalışıyor” gibi toplu sonuçlar yazma.
Her işin durumu şu dört değerden biri olsun:

- `EKSİK`: davranış henüz yok veya bilinen hata sürüyor.
- `KOD + OTOMATİK TEST`: ilgili kod ve otomatik davranış kanıtı var.
- `CANLI TEST BEKLİYOR`: oyun içi kabul henüz yapılmadı/engellendi.
- `DOĞRULANDI`: belirtilen kapsamın tüm kabul koşulları kanıtlandı.

`DOĞRULANDI` kapsam belirtmeden kullanılamaz: örneğin solo doğrulama çok oyunculu
veya 60 dalgalık denge doğrulaması değildir. Bir özelliğin çalışmayan kısmını
gizlemek için açıklamasını sessizce küçültme; tasarım farkını ayrıca belirt.

Masaüstündeki mevcut TXT raporunu güncellerken her paket için şu bilgileri yaz ve
projedeki ilgili test/kanıt dosyasına bağlantı ver:

```text
Tarih ve yerel commit:
İş / durum / test edilen kapsam:
Önceki hata ve yeniden üretimi:
Değişen davranış ve dosyalar:
Otomatik test: komut, sonuç, ilgili senaryo:
Canlı test: Dota sürümü, harita, kahraman, oyuncu sayısı, zorluk, dalga:
Beklenen / gözlenen sonuç ve güncel log veya görselin yolu:
Yapılmayan testler ve bilinen eksikler:
Sonraki tek iş:
```

Denetim başlangıç kanıtı: 68 mock davranış testi, 300 dalga/oyuncu planı ve
34 Panorama kaynağı derlemesi. Bunlar tüm oyunun bitmiş veya dengeli olduğu
anlamına gelmez. Sonuçları yalnız yeniden çalıştırıp gözlemlediğinde güncel diye yaz.
