# Oyuncu geri bildirimi denetimi — 27 Eylül 2026

## Sonuç ve kapsam

Antigravity'nin masaüstündeki `ENFOS_SAMETC_PROJE_DURUMU_VE_CODEX_GECIS_RAPORU.txt`
raporu okundu; rapordaki tamamlanma iddiaları kod ve testlerle ayrı ayrı değerlendirildi.
40 kahraman / 200 yetenek mevcut olması, bu içeriğin tamamının motor içinde çalıştığını
ve 60 dalganın dengeli olduğunu kanıtlamıyor. Proje hâlâ geliştirme sürümü.
Canlı oyun testi kullanıcıya ait; bu çalışmada maç başlatılmadı ve harita derlenmedi.

## Düzeltmeler

| Bildirim | Kodda yapılan işlem | Kabul sınırı |
|---|---|---|
| Takım seçiminde boş kullanıcı adı | Panorama `Game.GetPlayerInfo` / `Players.GetPlayerName` ile yerel Dota adı; sunucu adı ve yerelleştirilmiş oyuncu numarası yedekleri | Çok oyunculu lobi görüntüsü bekliyor |
| Spellbringer simge ve açıklamaları | Sekiz mevcut Valve ikonu; EN/TR/RU/zh-CN etki metinleri; sunucudan mana/bekleme/yarıçap/süre; sol orta panel | Görsel yerleşim canlı kabulü bekliyor |
| Büyünün Core yanında oluşması | Buton hedefleme başlatır; zemin sol tık konum gönderir, sağ tık iptal; sunucu karşı/kendi arena, yürünebilirlik, mana ve bekleme denetler | Gerçek zeminde hedefleme bekliyor |
| Reçetelerin satın alınamaması | Üst üste bütün haritayı kaplayan HOME+SECRET alanları yerine yüksek platformları kapsayan tek universal HOME alanı | Nedensellik motor içinde henüz kanıtlanmadı; reçetelerin KV tanımları değiştirilmedi |
| Ascended eşyaları | 30 boş/pasif tanım yerine güncel Valve eşya sınıfından türeyen sürümler; seçili düz bonuslar ×1.20; yıldızlı yerel temel adlar, mağazada yıldız rozeti, önce→sonra değerleri; güncel temel maliyetten %90 satış | Native türetme ve her aktif için motor kabulü zorunlu. Tasarımdaki 30 özel PvE mekanik bununla tamamlanmış sayılmaz |
| Dalga / takım canı | İki can çubuğu, dalga/durum sayacı, düşman/altın bilgileri; düşük canda metin işareti; sonraki dalga düğmesi korunur | Ekran oranları canlı kabulü bekliyor |
| Doğal yetenekler | Önceden yalnız Sven'de Innate işareti vardı. 40 kahramanın beşinci yeteneği işaretlendi; ilk rank ücretsiz, respawn eğitim seviyesini sıfırlamaz | Kahramana özel sekiz-rank eğrileri ve nihai puan bütçesi tamamlanmadı |
| Hüner ağacı | 12 ortak Evolution seçeneğine gerçek kalıcı modifier; başarısız uygulamada seçim harcanmaz; erteleme korunur; yeni kahraman gövdesine seçimler yeniden uygulanır; ilgisiz eski Dota yetenek/talent slotları temizlenir | Bu hâlâ ortak geçici ağaç; 40 kahramana özel Watcher benzeri ağaç değil |
| Aghanim açıklaması | 40 R için Scepter ve 40 innate için Shard işareti ve dört dilde gerçek etki açıklaması. 23 R yeteneğindeki eksik ULTIMATE türü düzeltildi | Mevcut Scepter ultimate hasarı/beklemesi, Shard rol bazlıdır; 40 özgün mekanik tamamlanmadı. Pasif/buff ultimate'lerde yararlılık ayrıca incelenmeli |
| Boss ERROR | Bütün özel birimler/model/projeler yükleme önbelleğine alındı; Tiny kanonik model yolu ve yanlış Eidolon yolu düzeltildi | VPK'da varlık doğrulandı, render canlı kabulü bekliyor |
| Summon kontrolü | Spellbringer'ın beş takviyesi çağıranın kontrolünde. WK 4–8 iskelet, SS 8 sabit ward, CK 3 ve TB 2 illüzyon gerçek birlik oldu; 30 saniye ömür; tekrar kullanım eski grubu siler; dalga ödülü vermez | Birim hareket/atak ve native ward/illüzyon özellikleri canlı kabulü bekliyor |
| Büyüden sonra saldırı | Zorla saldırı emri eklenmedi. Kurulu Valve yerelleştirmesinde Auto Attack / Always ayarı doğrulandı | Kullanıcı Ayarlar → Oyun → Otomatik Saldırı → Her Zaman seçebilir |

Ek varlık taraması dört yanlış particle yolunu ve yedi eksik yetenek ikonunu ortaya çıkardı;
kurulu Valve varlıklarıyla düzeltildi. Başka custom oyunun kodu, özel görseli veya sesi alınmadı.

## Test kanıtı

- `node tools/checks.mjs`: KV, Lua sözdizimi, yerelleştirme, Panorama eşleri, roster/ekonomi,
  harita bütünlüğü ve davranış regresyonları. 200 yeteneğin çalıştırılması **mock Lua testi**;
  dosya başlığındaki yanıltıcı LIVE ifadesi düzeltildi. `GetIntellect` bool parametresi artık
  mock'ta da zorunlu.
- Yeni testler: noktaya tıklamadan Spellbringer harcamaması, UI tıklaması ve iptal;
  innate rank'ın respawn'da korunması; çağrı tavanı/önceki grubun silinmesi/illüzyonun
  yeniden çağrı yapamaması; Evolution modifier varlığı ve tekrarlı uygulama; tek shop hacmi;
  40 kahraman metadata ve 30 Ascended tanım/değer sözleşmesi.
- `node tools/verify_models.mjs`: üretim KV'sindeki 43 birim modeli, yetenek ikonları ve
  Lua içindeki sabit resource yolları kurulu Valve VPK'sına karşı kontrol edilir.
  Dosyanın var olması render/ses kabulü değildir.
- Dota Workshop MCP: `addon_audit` 38 VScript + 11 Panorama dosyası, 0 uyarı.
  API sorguları: `SetSize`, `CreateIllusions`, `GetPlayerName`; önceki sorgularla
  shop trigger ve mouse/world-position API'leri doğrulandı.
- Valve resourcecompiler: yalnız `spellbringer`, `wave_hud`, `game_setup`, `evolution`,
  `ascended_shop` Panorama layout bağımlılıkları derlendi. Map/content toplu derlemesi yapılmadı.
- `node tools/check_map.mjs`: korunan 11 dosyanın hash'i aynı.

`tools/simulate_hero_kits.mjs` elle verilen DPS/HP varsayımlarını kullanır. Gerçek
200 Lua yeteneğini çalıştırmaz; solo 1–15 veya 60 dalga kabul kanıtı olarak kullanılamaz.

## Kullanıcının yeni maçta doğrulayacağı kısa sıra

1. Takım seçiminde ad; kahraman seçimi ve doğru Survival haritası.
2. Yeterli altınla Blade Mail gibi reçeteli normal bir eşyanın reçetesini satın alıp
   birleşmesi; platform üstünde ve kurye tesliminde ayrı kontrol.
3. Spellbringer takviyesi: buton → farklı zemin noktası → beş dost birim → seçip yürütme;
   ikinci denemede sağ tık iptalinin mana harcamaması.
4. Bir Ascended yükseltmede temel aktif/charge/bekleme korunması ve tooltip değerlerinin
   değişmesi; önce Blade Mail / Solar Crest, sonra diğer sınıflar.
5. Seviye 4 Evolution seçimi, 7'de erteleme; ölüm/yeniden doğuşta tekrar bonus yığılmaması.
6. Boss görüntüsü, Aghanim metinleri, WK/SS/CK/TB gerçek çağrıları.

## Açık ürün ve yayın kapıları

- Watcher referansından kanıtlı, temiz-oda mekanik analizi ve 40 kahramana özel seçimler yok.
- Özgün 30 Ascended PvE mekanik, özgün 40 Shard/Scepter ve tutarlı innate/puan eğrileri eksik.
- Bu yüzden bu değişiklikler yayın kabulü veya bütün oyunun bitmesi değildir.
- Kullanıcı talimatı: yerel commit; GitHub push yapılmadı. Steam Workshop yayını yapılmadı.
- Native sınıf yaklaşımı için teknik dayanak: [ModDota BaseClass](https://moddota.com/abilities/ability-keyvalues#baseclass).
  Güncel 30 eşya için gerçek oyun kabulü bu dokümanın yerini tutmaz.
