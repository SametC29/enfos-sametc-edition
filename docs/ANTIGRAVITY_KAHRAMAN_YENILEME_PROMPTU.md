# Antigravity görevi: genel denge ve kahraman yeteneklerinin yeniden tasarımı

Bu projede geliştirmeye devam et:
`C:/Enfos Team Survival SametC Edition`

## Kullanıcının son düzeltmesi — görevin asıl amacı

Oyunun yalnız solo için değil, **genel olarak daha erişilebilir ve kahramanların
daha güçlü olduğu** bir yapıya gelmesini istiyorum. Solo, çok oyunculu co-op ve
PvEvP'de kahramanların kendi dalgalarıyla savaşması bu hedefe dahil. Bunu yalnız
solo bonusuyla, Casual moduyla veya düşmanların canını azaltarak çözme.

Enfo'yu eğlenceli yapan şeylerden biri kahramanların biraz “kırık” hissettirmesi:
kalabalıkları temizlemek, güçlü kombinasyonlar kurmak, eşya ve seviye aldıkça
belirgin biçimde güçlenmek. Normal Dota'nın az sayıda hedefe karşı tasarlanmış
yeteneklerini olduğu gibi kullanmak bu harita için yeterli değil.

**Neredeyse bütün kahraman kitlerini incele ve bu amaca göre dönüştür.** Özellikle
Carry, Fighter ve Mage yeteneklerinin büyük çoğunluğu Watcher of Samsara ve diğer
dalga/minyon temizleme oyunlarındaki gibi etkili PvE mekanikleri taşımalı. Tank ve
Support kısmen istisna: kimliklerini korusunlar; yine de tek başına dalga
temizleyebilecek makul bir yolları olsun. Her kahramanı aynı alan hasarı paketine
dönüştürme. Kahramanların görünen isimleri orijinal Dota 2 isimleri olarak kalsın.

Bu metin, eski devam planındaki “önce canlı oyunu kendin test et” sırasını ve
solo ağırlıklı denge yorumunu bu görev için günceller. **Canlı testi ben yapacağım.**
Sen kodu, otomatik kontrolleri ve test edilebilir paketleri hazırla. Oyunu kendin
açma, mevcut maçı yönetme, assertion pencerelerini otomatik bastırma.

## 1. Mevcut çalışmayı devral

- Önce `git status`, güncel dal ve son commit'leri kontrol et. Bilinen son çalışma
  dalı `codex/project-hardening`; bu isim dosyaların güncel olduğunu kanıtlamaz.
- `112b671`: kahramanın `(0,0,0)` noktasında doğmasına karşı native takım spawn
  noktaları ve respawn düzeltmesi. Otomatik testli; canlı kabul henüz yok.
- `84955f4`: bütün gerçek kahramanlara ortak güç bonusu, solo için ek bonus.
  Bu **geçici ilk pakettir**, istenen kapsamlı kit yenilemesinin tamamı değildir.
- `heroes/power_config.lua`, `heroes/hero_power.lua`, `heroes/modifier_hero_power.lua`
  ve `waves/balance_config.lua` mevcut güçlendirme noktalarıdır. Kitler güçlenirken
  bu bonuslarla toplam gücü birlikte değerlendir; üst üste kontrolsüz çarpan ekleme.
  Gerektiğinde ortak/solo paylarını yeniden düzenle, fakat yeni kit hazır olmadan
  kahramanın mevcut desteğini körlemesine kaldırma.
- Mevcut 40 kahramanı, iç kimlikleri, kullanıcı/diğer geliştirici değişikliklerini
  koru. Aynı işi yapan ikinci manager veya paralel bir yetenek sistemi kurma.
- **Yalnız yerel commit. Push, yayınlama veya Workshop yüklemesi yapma.**

Başlangıçta `AGENTS.md`, `docs/PROJECT_STATUS.md`,
`docs/audit/HERO_POWER_2026-09-27.md`, `docs/DECISIONS_OPEN_ITEMS.md` ve
`docs/REFERENCE_ANALYSIS_POLICY.md` oku. İlgili tasarım, mimari, yol haritası ve QA
bölümlerini kullan. `node tools/checks.mjs` sonucunu kaydet. Son kayıt 98 otomatik
davranış testi; yeni çalıştırmadan bunu güncel sonuç diye sunma.

## 2. Referansları gerçekten incele

Watcher of Samsara ve uygun diğer dalga temizleme oyunlarının erişilebilir
referanslarını yerel dosyalar, mevcut MCP araçları ve güvenilir kaynaklarla bul.
Gerçekten gözlemlediğin davranışlarla kendi tasarım önerilerini ayrı yaz.
Erişemediğin referansı incelemiş gibi yapma. Eksik kaynak, bağımsız PvE yetenek
iyileştirmelerini durdurmasın; referansa özgü kanıtlanamayan iddiaları açık bırak.

İlham alınabilecek mekanikler: delici/çoklu mermiler, zincirleme vuruşlar, sınırlı
sekme, yayılabilen işaretler, kontrollü öldürme zincirleri, istif tüketen patlamalar,
saldırı-büyü etkileşimi, niteliklerle ölçeklenen alan etkileri ve geçici güçlenmeler.
Bu örnekleri Watcher'da doğrulanmış özellikler diye yazma; uygunluklarını incele.

Referansın kodunu, KV tablolarını, özel efektini/sesini/ikonunu veya metnini
üretime kopyalama. Davranışı tarif et, bizim oyuna uyarlayıp bağımsız uygula.
Valve/Dota kaynaklarını veya projeye ait kaynakları kullan. Referans incelemesini
`docs/reference-analysis/watcher-of-samsara.md` içinde güncelle; mekanizma,
tasarım amacı, uyarlama ve kaynak/kanıt ayrımını belirt.

## 3. Bütün kadro için yetenek envanteri çıkar

Gerçek üretim KV/Lua verisinden 40 kahramanı ve mevcut bütün yeteneklerini çıkar.
Yalnız isim veya ikon değişmiş, boş bırakılmış, yanlış BaseClass'a bağlanmış,
açıklamasıyla davranışı uyuşmayan ve dar Dota işlevi yüzünden PvE'ye uymayan
yetenekleri belirle. Birkaç kahramanı değiştirip bütün kadro tamamlandı deme.

`docs/HERO_PVE_REWORK_MATRIX.md` dosyasında her yetenek için şunları kaydet:
kahraman/rol ve sabit ID; mevcut gerçek davranış; korunacak/uyarlanacak/değişecek
kararı ve gerekçesi; yeni mekanik; diğer yeteneklerle etkileşim; sayısal değerler
ve ölçekleme; boss davranışı; ikon/efekt/ses; uygulama ve test durumu.

Tank/Support istisnası tembellik gerekçesi olmasın: iyi çalışan koruma, iyileştirme,
kontrol veya tehdit toplama yeteneğini koru, dalga temizleme yolunu ayrıca tamamla.
Her güçlü yeteneği sürekli basılması gereken bir tuşa çevirme; uygun yerlerde
pasif, otomatik tetikleme veya autocast kullan, oyuncunun kontrolünü koru.

## 4. Genel zorluğu kahraman kitleri üzerinden düşür

- Güç artışı takım oyununda da hissedilsin. Tek başına giren oyuncu için gereken
  ek ölçeklemeyi ayrıca ele al; ana güç fantezisini solo koşuluna bağlama.
- İlk dalgalarda oyuncu yeteneklerini kullanabilsin; sürekli mana bitmesi,
  uzun bekleme süreleri ve düşük temizleme kapasitesi yüzünden çaresiz kalmasın.
- Hasar, menzil/radius, hedef sayısı, süre, cooldown, mana, nitelik/saldırı hasarı
  ölçeklemesi ve eşya etkileşimlerini birlikte ayarla. Sadece her sayıyı çarpmakla
  veya büyük düz stat bonusuyla görevi tamamlanmış sayma.
- Carry/Fighter/Mage kitlerinde belirgin bir temizleme yöntemi ve kit içi sinerji
  kur. Tank dayanıklılık/alan kontrolü; Support takım faydası kimliğini korusun.
- Güçlü alan temizleme normal düşmanlarda etkili olabilir; boss'u sürekli stun,
  sonsuz reset, sınırsız yüzde-can hasarı veya yansıma döngüsüyle işlevsiz bırakma.
- Aynı genel kurallar PvEvP'nin iki tarafına simetrik uygulansın. Öldürme zinciri,
  summons veya ek hasar bir ölümü iki ödüle ya da ücretsiz Life kaybına çevirmesin.
- Normal zorluğun erişilebilirliği öncelikli. İleri zorlukların birbirinden
  ayrılmasını koru. Sayısal değerleri sürümlü veri/ayar olarak tut.

## 5. Her yeteneği tamamlanmış bir paket olarak uygula

Hasar türü, gerçek damage/radius/menzil/hedef sayısı, süre, mana ve cooldown;
seviye artışı, öğrenilme koşulları, hedef filtreleri, pasif/break/illusion davranışı,
ölüm ve yeniden bağlanma temizliği birbiriyle tutarlı olsun.

İkon, projectile, isabet efekti, cast/impact sesleri ve gerekli precache kayıtları
tam olsun. VPK'da dosya bulmak, oyunda doğru göründüğünü kanıtlamaz. Eksik/yanlış
kaynakları açıkça kaydet. Görünmeyen veya eski işlevi anlatan ikonlar kullanma.

EN/TR/RU/zh-CN açıklamaları gerçek uygulamayla eşleşsin; oyuncu hasarı, radius'u,
süreyi, ölçeklemeyi ve önemli sınırları okuyabilsin. Sayılar mümkün olduğunca gerçek
veriden üretilsin. Shard/Scepter, mevcut Evolution, Boon, eşya ve ortak Enfo Gücü
bonuslarıyla etkileşimleri incele. Tamamlanmamış etkiyi çalışıyor diye anlatma.

## 6. Uygulama sırası ve kontroller

Envanter ve tasarım matrisinden sonra önce Drow Ranger, Luna, Juggernaut ve Lina
ile saldırı/alan temizleme temellerini; Sven ve Omniknight ile rol istisnalarını
uygula. Bunları temsili paket olarak bitir, ardından kalan kadroya küçük gruplar
halinde ilerle. Bu altı kahraman nihai kapsam değil, ilk uygulama grubudur.

Her paket için ilgili davranış testleri yaz: gerçek hedef/hasar hesabı, sınırdaki
radius, tekrar tetiklenme, cooldown/mana, stack sınırı, boss istisnası, ölüm ve
yeniden bağlanma. Ortak mekanikleri farklı kahraman verileriyle de sınayarak
kopyala-yapıştır hatalarını yakala. Testleri yalnız fonksiyon varlığına indirgeme.

Gerçek üretim verisiyle tek ve çok oyunculu senaryoları karşılaştır: en az 1/2/5
kişilik co-op ve simetrik PvEvP; erken dalgalar, boss/elite dalgaları ve ilerleyen
dalgalarda temizleme süresi, mana ihtiyacı ve dayanıklılık tahmini. Simülasyonun
varsayımlarını yaz; bunları oyun içi doğrulama diye sunma.

Her mantıksal pakette ilgili testleri, `node tools/checks.mjs` ve diff kontrolünü
tamamla; tasarım/matris/durum belgelerini güncelle; tek yerel commit oluştur.
Mevcut kontrolleri geçmek için test kaldırma veya kabul koşulunu gevşetme.
MCP/yerel Valve API bilgilerini doğrulama için kullan; aracı çağırmak tek başına
doğrulama kanıtı sayılmaz. Performans için hedef/sekme/stack/summon/thinker
sınırları koy; her kare tüm haritayı tarama, sonsuz olay zinciri üretme.

## 7. Çalışan harita ve çekirdek kuralları koru

- Mevcut Survival yerleşimi ve sonbahar/taş yol yönü korunacak.
- `game/maps/enfos.vpk`, `game/maps/enfos_sametc.vpk` ve harita manifestini koru.
  Eski flat VMAP'leri geri getirme, tüm content/maps ağacını derleme; “Legacy
  Compiled Data” uyarısını yanlış kaynakla yeniden derleyerek kapatmaya çalışma.
- `node tools/check_map.mjs` bütünlüğünü koru. Arayüz gerekiyorsa yalnız değişen
  Panorama kaynaklarını derle; web CSS'i yerine desteklenen Panorama sözdizimi kullan.
- Spawn/respawn düzeltmesi, seçim onayı, portallar, minimap ve dalga başlatma
  akışını koru. Canlı spawn düzeltmesi henüz kullanıcı kabulü bekliyor.
- 60 dalga, her 5. dalgada yalnız boss, her 6. dalgada boss ile çakışmıyorsa elite,
  iki normal + bir boss koridoru, başlangıç 100 Life, cap overflow kuralı korunacak.
- Spellbringer ayrı mana ve 8 yeteneğiyle kalacak. Normal Dota shop, başlangıçtan
  itibaren tomelar, 40 kahraman/rol dağılımı ve Ascended hedefi korunacak.
- 29 tamamlanmamış Ascended yükseltmenin satın alma korumasını bu görev kapsamında
  kaldırma. Çalışmayan eşya mekaniklerini kahraman dengesinin temeli kabul etme.

## 8. Bana ve Codex'e teslim

Yalnız plan veya toplu “bitti” raporu verme; çalışan kod ve otomatik testlerle ilerle.
Masaüstündeki mevcut ENFOS/Codex geçiş TXT raporunu bul ve güncelle; rapordaki eski
iddiaları otomatik doğru sayma. Aynı sonuçları proje içinde sürümlü olarak tut.

Raporda şunlar açık olsun:
- Yerel commit'ler ve değişen dosyalar.
- Her kahramanın eski/yeni oynanışı ve genel güç artışının nedeni.
- Kapsanan ve henüz ele alınmayan kahraman/yetenekler.
- Koşulan testler, sonuçları, varsayımlar ve kalan hatalar.
- Doğrulanmamış efekt/ses/API veya referans bilgisi.
- Kullanıcının canlı test edeceği kısa adımlar ve beklenen sonuçlar.

Durumları `EKSİK`, `KOD + OTOMATİK TEST`, `CANLI TEST BEKLİYOR` şeklinde ayır.
Oyunu ben test edene kadar oynanış veya denge için “DOĞRULANDI” deme. Sıradan
uygulama ve sayısal denge kararlarında sürekli onay isteme; gerçekten çözülemeyen
ürün çelişkisini daraltıp kaydet, bağımsız işleri sürdür.
