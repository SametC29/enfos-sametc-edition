// Enfos Team Survival — SametC Edition: Custom Loading Screen JS

var EnfosLoading = (function () {
	"use strict";

	var tips = [
		{
			category: "EKONOMİ & GELİŞİM",
			text: "Boss dalgalarından kazanılan Kereste ile eşyalarınızı Yükselmiş (Ascended) seviyeye çıkarabilir veya Aghanim'in Lütfu ile envanter yuvası kazanabilirsiniz."
		},
		{
			category: "SPELLBRINGER TAKTİĞİ",
			text: "Spellbringer bağımsız bir mana havuzuna sahiptir. Dalga sıkışması anında Şok Dalgası veya Kalkan Büyüsü ile takım canınızı kurtarın."
		},
		{
			category: "TAKIM CANI (TEAM LIFE)",
			text: "Takım Canınız 100 ile başlar. Koridordaki birim sınırı aşıldığında biriken her fazlalık düşman doğrudan kalıcı Can kaybına dönüşür."
		},
		{
			category: "GELİŞİM MİLESTONE SEÇİMLERİ",
			text: "Seviye 4, 7, 10, 13, 16 ve 19'da oyun tarzınıza uygun uzmanlaşma dallarını seçin. Seçimi erteleyebilir veya sıraya alabilirsiniz."
		},
		{
			category: "ELİT VE BOSS TEHLİKELERİ",
			text: "Her 5. dalga sadece Boss içerir. Her 6. dalga ise tehlikeli Elit yaratıklar doğurur; kitle kontrol ve zırh kırma yeteneklerinizi hazır tutun."
		}
	];

	var currentTipIndex = 0;

	function RotateTip() {
		currentTipIndex = (currentTipIndex + 1) % tips.length;
		var tip = tips[currentTipIndex];

		var catLabel = $("#TipCategory");
		var textLabel = $("#StrategyTipText");

		if (catLabel) catLabel.text = tip.category;
		if (textLabel) textLabel.text = tip.text;

		$.Schedule(4.5, RotateTip);
	}

	function Init() {
		// Start rotating strategy tips
		$.Schedule(4.0, RotateTip);
	}

	Init();

	return {};
})();
