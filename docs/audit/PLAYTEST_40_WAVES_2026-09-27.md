# 40 dalgalık kullanıcı testi sonrası — ilk yerel düzeltme paketi

Durum: yerel aday; canlıya gönderilmedi. Bu kayıt önceki "tamamlandı" raporlarının
yerine motor kabulü iddiası koymaz. Antigravity'nin `ec69150` commit'i ve masaüstü
raporu incelendi; katkısı korundu. Kullanıcı bossların kolay ölmemesini ve tüm
ilerleme sistemlerinin korunup bonus/sıklıklarının azalmasını seçti.

## Değişiklikler

- Normal/Elite dalga adedi: `(20 + 2 × (dalga - 1)) × takım oyuncusu`.
  Örnek: 1=20, 2=22, 19=56, 39=96, 59=136 kişi başına. Boss dalgası tek boss.
  Kompozisyon ağırlıkları korunur; tehdit maliyeti artık gerçek adedi azaltmaz.
- Dalga süresi: normal 1–20 için 22, 21–40 için 24, 41–60 için 26 saniye;
  boss 45 saniye. 48 normal/Elite + 12 boss + 12×5 sn uyarı + hazırlık yaklaşık
  30 dakika. Erken temizleme kalan süreyi korur; düğme beklemeyi atlar.
  Süre dolunca normal düşmanlar bir sonraki normal dalgada kalır. Boss öncesi
  mevcut temiz-saha/Life kaybı kuralı korunur. Süresi dolan boss bir kere sızma
  olarak çözülür; öldürme ödülü verilmez. Pause sayacı dondurur.
- Düşmanlar küçük partilerle oluşturulur. Mevcut 30×oyuncu **eşzamanlı** birim sınırı
  korunur; planlanan toplam bu sınır değildir. Limitte oluşturulamayan düşman Life
  kaybına dönüşür. Doğuşlar artık çok daha uzakta olduğundan, yeni süre/cap dengesi
  özellikle iki koridorda motor testine muhtaçtır; matematik testi oynanış kabulü değildir.
- Yanlış kullanılan `way*.1` ara noktaları yerine haritadaki `cs1..cs6` başlangıç
  konumları kullanılır. AI rotalarına başlangıç segmenti eklendi; doğuş ve rota aynı
  kaynaktan okunur. Harita binary dosyalarının hiçbiri değiştirilmedi.
- Dalga sonundaki ilave altın/XP ödemesi kaldırıldı. Mevcut öldürme başına takım
  paylaşımı ve katilin kendi payına %20 ilavesi korunur. Kaçan düşman ödül vermez.
  Yeni ekonominin 1–5 oyuncu/60 dalga aritmetiği `wave-economy.csv` içinde.
- Bosslar %70/%35 can sınırında faz değiştirir; tek vuruşla bu sınırlar atlanmaz.
  Geçişte 2 sn korunma vardır. İlk üç boss davranışı korunur; diğer dokuz boss için
  faza göre 1/2/3 hedefte, 1.8 sn uyarılı alan saldırısı bulunur. Bu ortak temel,
  12 ayrı benzersiz boss tasarımının tamamlandığı anlamına gelmez.
  HUD fazı gösterir. Telegraph adları artık çakışmaz ve pause'a uyar.
- Enfo gücü: takımda hasar/AS 25→15, büyü gücü %20→%10, CDR %15→%5;
  solo toplam hasar/AS 45→25, büyü gücü %35→%15, CDR %25→%10.
  Can/mana kapasitesi ve yenilenmesi korunur. Dört dil açıklaması güncellendi.
- Boon/Pact oyu her boss yerine 10/20/30/40/50/60. Sistemler kapatılmadı.
- Yeni dalga düğmesi sol ortadaki Spellbringer'ın üstündedir; yetki kontrolü sunucuda.
- Native HOME dükkânı için oyuncu başına yeniden kullanılan küçük bir takip alanı
  eklenir. Böylece düz dünya-merkezi alanına güvenmek yerine kahramanın gerçek
  yüksekliği izlenir. Normal eşya ve reçetelerin motor davranışı değiştirilmez.
- Antigravity'nin kurye kaldırma/doğrudan envanter teslimatı korunur.
- Troll, Tidehunter, Monkey King ve Underlord'daki altı geçersiz efekt yolu
  kurulu Valve arşivindeki gerçek kaynaklarla değiştirildi ve precache eklendi.
  Troll form değişimindeki sunucuya özel çağrılar client tarafından çalıştırılmaz.

## İnceleme bulguları / tamamlanmamış işler

- Ascended eşyaların mevcut temeli native eşya + bazı düz değerlerde %20 artıştır.
  **30 ayrı özel PvE mekaniği tamamlanmış değildir.** Yalnızca bunları satın almak
  veya ikon görmek mekaniklerin tamamlandığını kanıtlamaz.
- Hüner seçimleri hâlâ bütün kahramanların paylaştığı 12 seçimdir. Kahramana özgü
  Watcher tarzı ağaç, bu seçimlerin **yerini almalı**, fazladan güç katmanı olmamalı.
- Shard hâlâ rol bazlı; Scepter hâlâ genel ultimate amp/CDR. 40 özgün Shard/Scepter
  tasarımı yapılmış değildir. Bu sistemlerin yeniden tasarımı ayrı kabul paketi gerekir.
- 200 yeteneklik eski test her özel değere 100 veriyor, modifier OnCreated hatalarını
  pcall içinde yutuyordu. Test artık gerçek maksimum seviye KV değerlerini kullanır;
  callback hataları testten kaçmaz. Troll Q/W/ulti ve PA hançer isabeti için sonuç
  iddiaları eklendi. Bu yine motor testi değildir; ses/animasyon/oynanış henüz onaysızdır.
- Native reçete taraması: 125 reçete, 85 ücretli, eksik bileşen referansı 0,
  yerel override 0. Daedalus 1000 altınlık reçete ister; Butterfly reçetesi ücretsiz.
  Bu fark HOME erişimi şüphesini destekler; satın alma hatasının kesin motor nedeni
  bir engine trace ile henüz kanıtlanmadı. `NATIVE_RECIPES.json` kaynak hash'ini saklar.

## Doğrulama

- `node tools/checks.mjs`: 0 başarısız kontrol.
- 360 dalga/oyuncu kombinasyonunda adet korunumu; süre dolarken yaşayan düşmanın
  korunması, pause, erken temizlemede çift ödül olmaması, boss faz sınırları.
- Troll yakın/uzak form, W hasar/körlük, ulti saldırı hızı ve PA mermi isabet hasarı.
- HOME alanının farklı yükseklikleri izlemesi ve tekrar çağrıda çoğalmaması.
- `node tools/verify_models.mjs`: tüm modeller, 216 ikon, 151 literal kaynak mevcut.
- Dota MCP `addon_audit`: 0 uyarı (statik kapsama sınırları vardır).
- Valve derleyicisi: Spellbringer ve wave HUD XML/JS/CSS başarılı; harita derlenmedi.
- `node tools/check_map.mjs`: korunan 10 dosyanın hash'i aynı.

## Yerel kabul sırası

1. Troll Q aç/kapat, W yakındaki düşmana hasar/efekt, ulti altında AS/can çalma;
   PA Q doğrudan hedef + yakın hedeflere hançer.
2. Daedalus'u bileşen+ücretli reçete ile, Butterfly/Heart/Pipe ile karşılaştır;
   yer seviyesi/yükseltilmiş platform ve boş/dolu envanter durumlarını dene.
3. Yeni doğuş noktaları, iki rota, düşman adedi, timer, temizlenmemiş dalganın
   devamı ve birim limiti/Life kaybını kontrol et. Sayı artışını sadece ilk dalgada sınama.
4. Boss 5 ve 20'de %70/%35 fazı, kaçınılabilir alan, süre dolması ve tekrar ödül
   üretmemesini kontrol et. Sayısal hasarı artırmadan mekaniklerin okunurluğunu değerlendir.
5. Bunlar geçmeden yeni hüner/Ascended mekanikleriyle topluca denge ölçümü veya
   canlı yayın yapılmaz. Yerel test kullanıcıya aittir.
