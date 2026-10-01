# Yerelleştirme dosyaları yüklenmiyor — 30 Eylül 2026

## Belirti

Maç başlığında `#ENFOS_SAMETC_WAVE`, Spellbringer panelinde
`#ENFOS_NEXT_WAVE` / `#ENFOS_SPELLBRINGER_TITLE`, skor/HUD etiketlerinde token
isimleri görünüyordu. Özel yetenek adları ve açıklamaları da tooltip'te
çözümlenmiyordu.

## Kök neden

12 aktif Source 2 yerelleştirme çıktısının (`resource` ile Panorama'nın dört dil
dosyası ve Panorama kaynak/çalışma kopyaları) başında UTF-8 BOM yoktu. Projedeki
kontrol zaten Source 2 `resource/addon_*.txt` dosyaları için BOM şartı koyuyordu;
aynı doğrulama Panorama yerelleştirme dosyalarına uygulanmıyordu. Valve'ın
VConsole hata örneklerinde `ILocalize::AddFile()` çağrısının hem
`resource/addon_english.txt` hem `panorama/localization/addon_english.txt` için
başarısız olduğu görülüyor; bu dosyalar yüklenmeyince `#token` çözülemez.

Ek olarak `enfos_creep_silencer_mute` ad/açıklama çevirileri elle yalnızca
`game/resource` içine eklenmiş; dört locale'in JSON kaynaklarında bulunmadığından
Panorama kopyasında yoktu ve localization generator `--check` başarısız oluyordu.

## Düzeltme

- Dört dil için Silencer metinleri (`localization/*.json`) kaynaklara eklendi.
- `node tools/localization.mjs` ile `game/resource`,
  `game/panorama/localization` ve `content/panorama/localization` yeniden üretildi;
  tüm çıktılar UTF-8 BOM içeriyor ve aynı üretilmiş metni taşıyor.
- `tools/checks.mjs` artık BOM'u 12 çıktının tamamında denetliyor.

## Doğrulama ve sınırlar

- `node tools/localization.mjs --check`: geçti.
- HUD yayın testi ve ek HUD/Sven tooltip anahtar kontrolü: dört dilde geçti.
- Yerel Steam addon'undaki 8 çalışan localization dosyası çalışma ağacıyla aynı.
- `node tools/checks.mjs`: localization ile ilgili kontroller geçti; kalan iki
  hata dalga ekonomi audit çıktısı ve audit regression testindeki ayrı beklenti.
- Oyun yeniden başlatılmadı ve kullanıcı testini kendisi yapacak; yayın yapılmadı.
