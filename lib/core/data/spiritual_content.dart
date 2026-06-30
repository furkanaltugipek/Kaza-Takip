/// %100 yerel, ücretsiz, ağ gerektirmeyen günlük manevi içerik veritabanı.
///
/// 4 kategori: Ayet, Hadis, Mevlana, Risale-i Nur.
/// Günün indeksi = `DateTime.now()` üzerinden hesaplanır → her takvim günü
/// her kategoriden ayrı bir parça otomatik açılır.
library;

/// Tek bir manevi içerik parçası.
class SpiritualPiece {
  /// Ana metin (Türkçe meal/açıklama).
  final String text;

  /// Kaynak / referans (örn. "Bakara, 286" veya "Sahih Buhari, 1").
  final String source;

  const SpiritualPiece({required this.text, required this.source});
}

/// İçerik kategorileri.
enum SpiritualCategory {
  ayet('Ayet', 'Kur\'an-ı Kerim'),
  hadis('Hadis', 'Hadis-i Şerifler'),
  mevlana('Mevlana', 'Mesnevi & Divan-ı Kebir'),
  gazali('İmam Gazali', 'İhya & Kimya-yı Saadet'),
  risale('Risale-i Nur', 'Bediüzzaman Said Nursi');

  final String title;
  final String subtitle;
  const SpiritualCategory(this.title, this.subtitle);
}

/// Tüm içerik. Her kategori bağımsız — biri kısalırsa diğerleri etkilenmez.
class SpiritualContent {
  SpiritualContent._();

  static const List<SpiritualPiece> ayetler = [
    SpiritualPiece(
      text:
          'Allah, hiç kimseye gücünün üstünde bir şey yüklemez. Herkesin kazandığı iyilik kendi yararına, kötülük de kendi zararınadır.',
      source: 'Bakara, 2/286',
    ),
    SpiritualPiece(
      text:
          'Şüphesiz namaz, hayasızlıktan ve kötülükten alıkoyar. Allah\'ı anmak, elbette en büyük (ibadet)tir.',
      source: 'Ankebut, 29/45',
    ),
    SpiritualPiece(
      text:
          'Ey iman edenler! Sabır ve namazla Allah\'tan yardım isteyin. Şüphe yok ki, Allah sabredenlerle beraberdir.',
      source: 'Bakara, 2/153',
    ),
    SpiritualPiece(
      text:
          'O\'nun rahmetinden ümit kesmeyin. Şüphesiz Allah, bütün günahları bağışlar. Çünkü O, çok bağışlayandır, çok merhamet edendir.',
      source: 'Zümer, 39/53',
    ),
    SpiritualPiece(
      text:
          'Beni anın, ben de sizi anayım. Bana şükredin, sakın nankörlük etmeyin.',
      source: 'Bakara, 2/152',
    ),
    SpiritualPiece(
      text:
          'Kim Allah\'a karşı gelmekten sakınırsa, Allah ona bir çıkış yolu açar. Onu beklemediği yerden rızıklandırır.',
      source: 'Talak, 65/2-3',
    ),
    SpiritualPiece(
      text:
          'Şüphesiz güçlükle beraber bir kolaylık vardır. Gerçekten, güçlükle beraber bir kolaylık vardır.',
      source: 'İnşirah, 94/5-6',
    ),
    SpiritualPiece(
      text:
          'Andolsun, biz insanı en güzel biçimde yarattık.',
      source: 'Tin, 95/4',
    ),
    SpiritualPiece(
      text:
          'Onlar, inananlar ve kalpleri Allah\'ı anmakla huzura kavuşanlardır. Biliniz ki, kalpler ancak Allah\'ı anmakla huzur bulur.',
      source: 'Rad, 13/28',
    ),
    SpiritualPiece(
      text:
          'Kim bir iyilik yaparsa, ona on katı vardır. Kim de bir kötülük yaparsa, o da sadece bir misli ile cezalandırılır.',
      source: 'En\'am, 6/160',
    ),
    SpiritualPiece(
      text:
          'Rabbiniz şöyle dedi: Bana dua edin, duanıza karşılık vereyim.',
      source: 'Mü\'min, 40/60',
    ),
    SpiritualPiece(
      text:
          'Allah\'a tevekkül et. Vekil olarak Allah yeter.',
      source: 'Ahzab, 33/3',
    ),
    SpiritualPiece(
      text:
          'Sevdiğiniz şeylerden Allah yolunda harcamadıkça iyiliğe asla erişemezsiniz.',
      source: 'Al-i İmran, 3/92',
    ),
    SpiritualPiece(
      text:
          'Allah, kullarına çok lütufkârdır. Dilediğini rızıklandırır. O, güçlüdür, mutlak galiptir.',
      source: 'Şura, 42/19',
    ),
    SpiritualPiece(
      text:
          'Şüphesiz Allah, adaleti, iyilik yapmayı, yakınlara yardım etmeyi emreder; hayasızlığı, fenalığı ve azgınlığı yasaklar.',
      source: 'Nahl, 16/90',
    ),
  ];

  static const List<SpiritualPiece> hadisler = [
    SpiritualPiece(
      text:
          'Ameller niyetlere göredir. Herkes için ancak niyet ettiği şey vardır.',
      source: 'Buhari, Bedü\'l-vahy 1',
    ),
    SpiritualPiece(
      text:
          'Sizden biriniz, kendisi için istediğini kardeşi için de istemedikçe (gerçek anlamda) iman etmiş olmaz.',
      source: 'Buhari, İman 7',
    ),
    SpiritualPiece(
      text:
          'Müslüman, dilinden ve elinden diğer Müslümanların güvende olduğu kimsedir.',
      source: 'Buhari, İman 4',
    ),
    SpiritualPiece(
      text:
          'Kolaylaştırın, zorlaştırmayın; müjdeleyin, nefret ettirmeyin.',
      source: 'Buhari, İlim 11',
    ),
    SpiritualPiece(
      text:
          'Allah\'ım! Faydasız ilimden, korkmayan kalpten, doymayan nefisten ve kabul olunmayan duadan sana sığınırım.',
      source: 'Müslim, Zikir 73',
    ),
    SpiritualPiece(
      text:
          'Güzel ahlak, iyiliktir. Günah ise içinde sıkıntı duyduğun ve insanların muttali olmasından hoşlanmadığın şeydir.',
      source: 'Müslim, Birr 14',
    ),
    SpiritualPiece(
      text:
          'İnsanlara merhamet etmeyene Allah da merhamet etmez.',
      source: 'Buhari, Edeb 18',
    ),
    SpiritualPiece(
      text:
          'Büyük günahların en büyüğü: Allah\'a şirk koşmak, ana-babaya isyan, haksız yere adam öldürmek ve yalan şahitlikte bulunmaktır.',
      source: 'Buhari, Edeb 6',
    ),
    SpiritualPiece(
      text:
          'Beş şey gelmeden önce beş şeyin kıymetini bil: İhtiyarlıktan önce gençliğin, hastalıktan önce sağlığın, fakirlikten önce zenginliğin, meşguliyetten önce boş vaktinin, ölümden önce hayatın.',
      source: 'Hakim, Müstedrek',
    ),
    SpiritualPiece(
      text:
          'Tebessüm etmen kardeşin için sadakadır.',
      source: 'Tirmizi, Birr 36',
    ),
    SpiritualPiece(
      text:
          'Komşusu açken tok yatan bizden değildir.',
      source: 'Hakim, Müstedrek',
    ),
    SpiritualPiece(
      text:
          'Hayrı söyleyen, hayrı yapan gibidir.',
      source: 'Tirmizi, İlim 14',
    ),
    SpiritualPiece(
      text:
          'En hayırlınız, hanımına en iyi davranandır.',
      source: 'Tirmizi, Menakıb 63',
    ),
    SpiritualPiece(
      text:
          'Allah temizdir, temizliği sever; naziftir, nezafeti sever; kerimdir, kerameti sever; cömerttir, cömertliği sever.',
      source: 'Tirmizi, Edeb 41',
    ),
    SpiritualPiece(
      text:
          'Yumuşaklık nerede bulunursa orayı süsler, nereden çıkarılırsa orayı çirkinleştirir.',
      source: 'Müslim, Birr 78',
    ),
  ];

  static const List<SpiritualPiece> mevlana = [
    SpiritualPiece(
      text:
          'Ne olursan ol gel. İster kâfir, ister Mecusi, ister puta tapan ol; yine gel. Bizim dergâhımız ümitsizlik dergâhı değildir.',
      source: 'Divan-ı Kebir',
    ),
    SpiritualPiece(
      text:
          'Aynı dili konuşanlar değil, aynı duyguları paylaşanlar anlaşabilir.',
      source: 'Mesnevi I',
    ),
    SpiritualPiece(
      text:
          'Sevgide güneş gibi ol, dostluk ve kardeşlikte akarsu gibi ol. Hataları örtmede gece gibi ol. Tevazuda toprak gibi ol. Öfkede ölü gibi ol. Her ne olursan ol, ya olduğun gibi görün, ya göründüğün gibi ol.',
      source: 'Divan-ı Kebir',
    ),
    SpiritualPiece(
      text:
          'Dün dünde kaldı cancağızım, bugün yeni şeyler söylemek lazım.',
      source: 'Divan-ı Kebir',
    ),
    SpiritualPiece(
      text:
          'Susmak, en güzel cevaptır. Çünkü cevap verdikçe, anlaşılır olmayanı anlatmaya çalışmış olursun.',
      source: 'Mesnevi V',
    ),
    SpiritualPiece(
      text:
          'Tohum gibiydim, filizlendim. Çiçek oldum, soldum. Toprağa düştüm, yine tohum oldum. Allah\'a giden yol, yok olmaktan geçer.',
      source: 'Mesnevi III',
    ),
    SpiritualPiece(
      text:
          'Hamdım, piştim, yandım.',
      source: 'Divan-ı Kebir',
    ),
    SpiritualPiece(
      text:
          'Karanlığa küfretmektense bir mum yakmak daha iyidir.',
      source: 'Mesnevi VI',
    ),
    SpiritualPiece(
      text:
          'Pergel gibiyim, bir ayağımla şeriat üzerinde sağlamca dururken, diğer ayağımla yetmiş iki milleti dolaşırım.',
      source: 'Divan-ı Kebir',
    ),
    SpiritualPiece(
      text:
          'Sen gönlü bir kez kırarsan, artık secde edilmiş olsa da makbul değildir o gönül.',
      source: 'Mesnevi II',
    ),
    SpiritualPiece(
      text:
          'Sabır, kurtuluşun anahtarıdır.',
      source: 'Mesnevi I',
    ),
    SpiritualPiece(
      text:
          'Aşk, iki kişiliktir. Yalnız başına yapılan iş zikirdir; aşk, ikiliği gerektirir.',
      source: 'Divan-ı Kebir',
    ),
    SpiritualPiece(
      text:
          'İnsan gözdür, gerisi deridir. Göz de ancak dostu görene denir.',
      source: 'Mesnevi I',
    ),
    SpiritualPiece(
      text:
          'Bir mum diğer bir mumu tutuşturmakla ışığından bir şey kaybetmez.',
      source: 'Mesnevi I',
    ),
    SpiritualPiece(
      text:
          'Aklın varsa, bir başka akılla dost ol da işlerini danışarak yap.',
      source: 'Mesnevi IV',
    ),
  ];

  static const List<SpiritualPiece> risale = [
    SpiritualPiece(
      text:
          'Hayatın lezzetini ve zevkini isterseniz, hayatınızı iman ile hayatlandırınız ve feraizle ziynetlendiriniz ve günahlardan çekinmekle muhafaza ediniz.',
      source: 'Sözler, 23. Söz',
    ),
    SpiritualPiece(
      text:
          'Ey nefis! Az bir ömürde hadsiz bir amel-i uhrevi istersen ve her bir dakika-i ömrünü bir ömür kadar faideli görmek istersen; ihlâsı kazan.',
      source: 'Lem\'alar, 21. Lem\'a',
    ),
    SpiritualPiece(
      text:
          'Cenab-ı Hak, her şeyi bir mizan-ı mahsus ile yarattığı gibi; her şeyin de bir nihayeti, bir gayesi vardır.',
      source: 'Mektubat, 20. Mektup',
    ),
    SpiritualPiece(
      text:
          'Musibetlerin tenevvüü, musibet değil; belki menfaattir, lezzettir.',
      source: 'Lem\'alar, 2. Lem\'a',
    ),
    SpiritualPiece(
      text:
          'İman hem nurdur, hem kuvvettir. Evet, hakiki imanı elde eden adam, kâinata meydan okuyabilir.',
      source: 'Sözler, 23. Söz',
    ),
    SpiritualPiece(
      text:
          'Bir adamın kıymeti himmeti nispetindedir. Kimin himmeti milleti ise, o kimse tek başıyla küçük bir millettir.',
      source: 'Hutbe-i Şamiye',
    ),
    SpiritualPiece(
      text:
          'Dünya hayatını ahiret hayatına ve kemâlât-ı uhreviyesine tercih edenler, ehl-i dalalettir.',
      source: 'Mektubat, 6. Mektup',
    ),
    SpiritualPiece(
      text:
          'Ümidvar olunuz; şu istikbal inkılâbı içinde en yüksek gür sada, İslâm\'ın sadası olacaktır!',
      source: 'Tarihçe-i Hayat',
    ),
    SpiritualPiece(
      text:
          'Şu dünya hayatı bir misafirhanedir. Misafirhanenin sahibi, çok kerimdir.',
      source: 'Sözler, 17. Söz',
    ),
    SpiritualPiece(
      text:
          'Tevekkül, esbabı bütün bütün reddetmek değildir. Belki esbabı dest-i kudretin perdesi bilip riayet ederek, esbaba teşebbüs ise bir nevi dua-i fiilî telakki ederek müsebbebatı yalnız Cenab-ı Hak\'tan istemektir.',
      source: 'Sözler, 23. Söz',
    ),
    SpiritualPiece(
      text:
          'Madem her şey elimizden çıkacak, fani olup kaybolacak; nasıl bâkîleştiririz? deseniz; cevaben derler ki: O fâni şeyleri bâkî bir Zat\'ın yoluna sarf etseniz, bekâ bulur.',
      source: 'Mektubat, 17. Mektup',
    ),
    SpiritualPiece(
      text:
          'En bahtiyar odur ki: Dünya için ahireti unutmaz, ahiretini dünyaya feda etmez, hayat-ı ebediyesini hayat-ı dünyeviye için bozmaz.',
      source: 'Mektubat, 23. Mektup',
    ),
    SpiritualPiece(
      text:
          'İnsan, kainatın en mükemmel meyvesi ve Halık-ı Kâinatın en sevgili mahluku ve mevcudatın en parlak mucizesidir.',
      source: 'Şualar, 11. Şua',
    ),
    SpiritualPiece(
      text:
          'Kalbden maksat, sanevberî bir parça et değildir. Belki bir latife-i Rabbaniyedir ki, mazhar-ı hissiyatı vicdan, ma\'kes-i efkârı dimağdır.',
      source: 'İşaratü\'l-İ\'caz',
    ),
    SpiritualPiece(
      text:
          'Güzel gören güzel düşünür. Güzel düşünen hayatından lezzet alır.',
      source: 'Mektubat, Hakikat Çekirdekleri',
    ),
  ];

  /// İmam Gazali'nin İhya'u Ulûmi'd-Dîn, Kimya-yı Saâdet ve diğer eserlerinden
  /// derlenmiş kısa hikmet/öğüt seçkisi.
  static const List<SpiritualPiece> gazali = [
    SpiritualPiece(
      text:
          'Nefsini bilen Rabbini bilir. Kalp, parlatıldıkça hakikati yansıtan bir aynadır.',
      source: 'İhya\'u Ulûmi\'d-Dîn',
    ),
    SpiritualPiece(
      text:
          'İlim, amel ile birleştiğinde fayda verir; amelsiz ilim, yağmursuz bulut gibidir.',
      source: 'İhya\'u Ulûmi\'d-Dîn, İlim Kitabı',
    ),
    SpiritualPiece(
      text:
          'Sabrın başlangıcı acıdır, sonu ise baldan tatlıdır. Acele eden, en kıymetli meyveden mahrum kalır.',
      source: 'İhya, Sabır ve Şükür Kitabı',
    ),
    SpiritualPiece(
      text:
          'Allah\'a giden yollar, mahlûkatın nefesleri sayısıncadır. Sen kendi yolunda samimi ol.',
      source: 'Mişkâtü\'l-Envâr',
    ),
    SpiritualPiece(
      text:
          'İhlas, amelin ruhudur. Riyâ ile süslenmiş bir amel, ölü bir bedene benzer.',
      source: 'İhya, İhlas ve Niyet Kitabı',
    ),
    SpiritualPiece(
      text:
          'Az ile yetinen çok kazanmıştır; çoğu isteyen hep azı bulmuştur. Kanaat, tükenmez bir hazinedir.',
      source: 'Kimya-yı Saâdet',
    ),
    SpiritualPiece(
      text:
          'Bir günahı küçük görmek, asıl tehlikedir. Çünkü dağ, küçük taşlardan meydana gelir.',
      source: 'İhya, Tövbe Kitabı',
    ),
    SpiritualPiece(
      text:
          'Tövbe kapısı son nefese kadar açıktır. Hiç kimse Rabbinin rahmetinden ümidini kesmemelidir.',
      source: 'İhya, Tövbe Kitabı',
    ),
    SpiritualPiece(
      text:
          'Şükür, nimetin devamının anahtarıdır. Verilenin kıymetini bilmeyen, o nimete lâyık değildir.',
      source: 'İhya, Sabır ve Şükür Kitabı',
    ),
    SpiritualPiece(
      text:
          'Dilini koru; çünkü insan dili yüzünden cehenneme yüz üstü atılır.',
      source: 'İhya, Dilin Âfetleri',
    ),
    SpiritualPiece(
      text:
          'Mü\'minin kalbi Arş\'tan daha geniştir; orada Allah\'ın muhabbeti yer bulur.',
      source: 'Mişkâtü\'l-Envâr',
    ),
    SpiritualPiece(
      text:
          'Dünya bir köprüdür; geç ama üzerine ev yapma. Asıl yurt ahirettir.',
      source: 'Eyyühe\'l-Veled',
    ),
    SpiritualPiece(
      text:
          'En değerli yolculuk, kalbin Allah\'a doğru olan yolculuğudur. Bedenin yorulmadığı yol, ruhun en uzun yoludur.',
      source: 'Kimya-yı Saâdet',
    ),
    SpiritualPiece(
      text:
          'Tevekkül, sebeplere yapışmayı bırakmak değil; sebeplerin arkasındaki Müsebbib\'e güvenmektir.',
      source: 'İhya, Tevekkül Kitabı',
    ),
    SpiritualPiece(
      text:
          'Korku ile ümit arasında yaşa: kuş gibi iki kanatla uçulur, tek kanatla değil.',
      source: 'İhya, Havf ve Recâ',
    ),
  ];

  /// Kategorinin tüm parçaları.
  static List<SpiritualPiece> forCategory(SpiritualCategory c) {
    return switch (c) {
      SpiritualCategory.ayet => ayetler,
      SpiritualCategory.hadis => hadisler,
      SpiritualCategory.mevlana => mevlana,
      SpiritualCategory.gazali => gazali,
      SpiritualCategory.risale => risale,
    };
  }
}
