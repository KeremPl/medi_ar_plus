/// Bu dosya, eğitim içeriklerinin ve adımlarının yapılarını tanımlayan veri modellerini içerir.
/// API'den gelen JSON verilerinin Dart nesnelerine dönüştürülmesi (parsing) ve
/// uygulama içinde bu verilerin tutarlı bir şekilde kullanılabilmesi için tasarlanmıştır.
/// Bu modeller, verinin tip güvenliğini sağlar ve olası çalışma zamanı hatalarını azaltır.
/// Yedeklilik ve hata toleransı açısından, özellikle `fromJson` metotlarındaki null kontrolleri
/// ve tip dönüşümleri, API'den gelebilecek beklenmedik veya eksik verilere karşı bir savunma hattı oluşturur.

/// `EgitimAdimModel`, bir eğitimin tek bir adımını temsil eder.
/// Bu sınıf, bir eğitim içeriğindeki her bir adımın sırasını,
/// isteğe bağlı olarak bir görselini ve açıklamasını içerir.
///
/// Örneğin, bir "İlk Yardım Eğitimi"nde "Kalp Masajı Nasıl Yapılır?" adımı
/// bu model ile temsil edilebilir. Bu adımın bir sıra numarası (örn: 3),
/// bir görseli (örn: kalp masajı pozisyonunu gösteren bir fotoğraf) ve
/// bir açıklaması (örn: "Göğüs kemiğinin ortasına iki elinizi yerleştirin...") olabilir.
class EgitimAdimModel {
  /// `adimSira`, eğitimin içindeki adımın sırasını belirtir.
  /// Bu alan zorunludur (`required`) çünkü her adımın bir sırası olmalıdır
  /// ve bu sıra, adımların doğru bir şekilde kullanıcıya sunulması için kritik öneme sahiptir.
  /// Veri tipi `int` olarak belirlenmiştir, çünkü sıra numaraları tam sayılardır.
  final int adimSira;

  /// `adimFotograf`, adıma ait görselin API'den gelen yolunu tutar.
  /// API yanıtında bu alanın `/images/...` gibi bir formatta gelmesi beklenir.
  /// Bu alan null olabilir (`String?`), çünkü her eğitim adımının bir fotoğrafı olmak zorunda değildir.
  /// Örneğin, bazı adımlar sadece metinsel açıklama içerebilir.
  /// Null olması durumu, UI tarafında bir görselin gösterilip gösterilmeyeceğine karar verilmesine yardımcı olur.
  final String? adimFotograf;

  /// `adimAciklama`, adıma ait metinsel açıklamayı içerir.
  /// Bu alan da null olabilir (`String?`), çünkü bazı adımlar sadece görsel veya
  /// interaktif bir içerik sunabilir ve ek bir açıklamaya ihtiyaç duymayabilir.
  /// Ancak genellikle adımların anlaşılması için bir açıklama metni bulunması beklenir.
  final String? adimAciklama;

  /// `EgitimAdimModel` sınıfının yapıcı (constructor) metodudur.
  /// Yeni bir `EgitimAdimModel` örneği oluşturmak için kullanılır.
  ///
  /// Parametreler:
  ///   `adimSira`: Bu adımın eğitim içindeki sırası (zorunlu).
  ///   `adimFotograf`: Bu adıma ait görselin dosya yolu (isteğe bağlı).
  ///   `adimAciklama`: Bu adıma ait açıklama metni (isteğe bağlı).
  ///
  /// `required` anahtar kelimesi, `adimSira` parametresinin bu nesne oluşturulurken
  /// mutlaka sağlanması gerektiğini belirtir. Bu, veri bütünlüğünü korumak için önemlidir.
  EgitimAdimModel({
    required this.adimSira,
    this.adimFotograf,
    this.adimAciklama,
  });

  /// `fromJson` fabrika (factory) yapıcısı, bir JSON (Map<String, dynamic>) nesnesini
  /// bir `EgitimAdimModel` örneğine dönüştürür.
  /// Bu metot, API'den gelen verilerin Dart nesnelerine güvenli bir şekilde aktarılmasını sağlar.
  /// Fabrika yapıcıları, her zaman sınıfın yeni bir örneğini döndürmek zorunda değildir,
  /// örneğin önbelleğe alınmış bir örneği döndürebilirler (bu örnekte böyle bir durum yok).
  ///
  /// Parametreler:
  ///   `json`: `Map<String, dynamic>` formatında, API'den gelen ve bir eğitim adımını temsil eden JSON verisi.
  ///
  /// Döndürdüğü Değer:
  ///   JSON verisinden oluşturulmuş yeni bir `EgitimAdimModel` örneği.
  ///
  /// Hata Yönetimi ve Güvenlik:
  ///   - `json['anahtar_adi'] as Tip`: Bu ifade, JSON map içerisinden belirtilen anahtara sahip değeri alır
  ///     ve belirtilen tipe (`Tip`) dönüştürmeye çalışır. Eğer dönüşüm başarısız olursa
  ///     (örneğin, `int` beklenen bir alana `String` gelirse) veya anahtar bulunamazsa
  ///     bir `TypeError` veya benzeri bir çalışma zamanı hatası fırlatılabilir.
  ///     Daha robust bir hata yönetimi için, `try-catch` blokları veya daha güvenli
  ///     erişim yöntemleri (örneğin, `json.containsKey('anahtar') ? json['anahtar'] : defaultValue`)
  ///     kullanılabilir. Ancak, bu modelin kullanıldığı yerdeki veri kaynağının (API)
  ///     sözleşmesine güveniliyorsa, bu tür doğrudan dönüşümler kabul edilebilir.
  ///   - `String?`: Alanların null olabilme özelliği (`?` ile belirtilir), JSON'da ilgili anahtarın
  ///     bulunmaması veya değerinin `null` olması durumunda hata oluşmasını engeller.
  ///     Eğer `json['adim_fotograf']` null ise veya `adim_fotograf` anahtarı JSON'da yoksa,
  ///     `adimFotograf` alanı `null` olarak atanır.
  ///
  /// Niyet: API'den gelen verinin yapısı hakkında varsayımlarda bulunarak (örneğin, 'adim_sira'nın her zaman bir int olacağı),
  /// kodu daha kısa ve okunaklı tutmak. Ancak, bu varsayımların API kontratı ile garanti altına alınması gerekir.
  /// Aksi takdirde, daha defansif programlama teknikleri (örneğin, gelen tipin kontrolü, varsayılan değerler atama)
  /// kullanılmalıdır.
  factory EgitimAdimModel.fromJson(Map<String, dynamic> json) {
    // JSON'dan gelen 'adim_sira' değeri okunur ve int tipine dönüştürülür.
    // Bu alanın API yanıtında her zaman bulunacağı ve bir tam sayı olacağı varsayılır.
    final int adimSira = json['adim_sira'] as int;

    // JSON'dan gelen 'adim_fotograf' değeri okunur ve String? tipine dönüştürülür.
    // Bu alan API yanıtında olmayabilir veya null olabilir, bu yüzden String? olarak tanımlanmıştır.
    final String? adimFotograf = json['adim_fotograf'] as String?;

    // JSON'dan gelen 'adim_aciklama' değeri okunur ve String? tipine dönüştürülür.
    // Bu alan da API yanıtında olmayabilir veya null olabilir.
    final String? adimAciklama = json['adim_aciklama'] as String?;

    // Okunan ve dönüştürülen değerlerle yeni bir EgitimAdimModel nesnesi oluşturulur ve döndürülür.
    return EgitimAdimModel(
      adimSira: adimSira,
      adimFotograf: adimFotograf,
      adimAciklama: adimAciklama,
    );
  }
}

/// `EgitimDetayModel`, bir eğitimin tüm detaylarını temsil eder.
/// Bu sınıf, eğitimin benzersiz kimliğini, adını, isteğe bağlı bir kapak vektörünü
/// ve eğitime ait adımların bir listesini (`List<EgitimAdimModel>`) içerir.
///
/// Örneğin, "Temel Yangın Güvenliği Eğitimi" bu model ile temsil edilebilir.
/// Bu eğitimin bir ID'si (örn: 101), adı ("Temel Yangın Güvenliği Eğitimi"),
/// bir kapak görseli (örn: bir yangın söndürücü ikonu) ve
/// yangın türleri, söndürme teknikleri gibi adımları içeren bir listesi olabilir.
class EgitimDetayModel {
  /// `egitimId`, eğitimin sistemdeki benzersiz tanımlayıcısıdır.
  /// Bu alan zorunludur (`required`) ve `int` tipindedir.
  /// Veritabanı veya API tarafında birincil anahtar (primary key) olarak düşünülebilir.
  final int egitimId;

  /// `egitimAdi`, eğitimin kullanıcıya gösterilecek adıdır.
  /// Bu alan zorunludur (`required`) ve `String` tipindedir.
  /// Örneğin, "İleri Düzey Flutter Programlama".
  final String egitimAdi;

  /// `egitimKapakVector`, eğitimin kapak görseli için bir vektör veya resim dosyasının yolunu tutar.
  /// Bu alan null olabilir (`String?`), çünkü her eğitimin bir kapak görseli olmak zorunda değildir
  /// veya varsayılan bir görsel kullanılabilir.
  /// API'den genellikle bir dosya yolu veya bir asset adı olarak gelir.
  final String? egitimKapakVector;

  /// `adimlar`, bu eğitime ait `EgitimAdimModel` nesnelerinin bir listesidir.
  /// Her bir eleman, eğitimin bir adımını temsil eder.
  /// Bu alan zorunludur (`required`), ancak liste boş olabilir (`[]`),
  /// bu da henüz adımı olmayan bir eğitimi temsil edebilir (pratikte pek olası olmasa da).
  /// `List<EgitimAdimModel>` tipi, bu listenin sadece `EgitimAdimModel` örnekleri içerebileceğini garanti eder.
  final List<EgitimAdimModel> adimlar;

  /// `EgitimDetayModel` sınıfının yapıcı (constructor) metodudur.
  /// Yeni bir `EgitimDetayModel` örneği oluşturmak için kullanılır.
  ///
  /// Parametreler:
  ///   `egitimId`: Eğitimin benzersiz kimliği (zorunlu).
  ///   `egitimAdi`: Eğitimin adı (zorunlu).
  ///   `egitimKapakVector`: Eğitimin kapak vektörü/görseli (isteğe bağlı).
  ///   `adimlar`: Eğitime ait adımların listesi (zorunlu).
  EgitimDetayModel({
    required this.egitimId,
    required this.egitimAdi,
    this.egitimKapakVector,
    required this.adimlar,
  });

  /// `fromJson` fabrika (factory) yapıcısı, bir JSON (Map<String, dynamic>) nesnesini
  /// bir `EgitimDetayModel` örneğine dönüştürür.
  /// Bu metot, API'den gelen karmaşık (iç içe listeler içeren) verilerin Dart nesnelerine
  /// güvenli bir şekilde aktarılmasını sağlar.
  ///
  /// Parametreler:
  ///   `json`: `Map<String, dynamic>` formatında, API'den gelen ve bir eğitim detayını temsil eden JSON verisi.
  ///
  /// Döndürdüğü Değer:
  ///   JSON verisinden oluşturulmuş yeni bir `EgitimDetayModel` örneği.
  ///
  /// Detaylı Açıklama ve Hata Toleransı:
  ///   - `adimlarListesi`: JSON içindeki 'adimlar' anahtarına karşılık gelen değer alınır.
  ///     Bu değerin bir liste (`List?`) olması beklenir. `as List?` ile yapılan cast,
  ///     bu alanın null olabileceğini veya bir liste olmayabileceğini belirtir.
  ///     Eğer 'adimlar' anahtarı JSON'da yoksa veya değeri null ise `adimlarListesi` null olur.
  ///   - `adimlarListesi != null ? ... : []`: Bu bir ternari (üçlü) operatördür.
  ///     Eğer `adimlarListesi` null değilse (yani API'den adımlar listesi geldiyse),
  ///     `adimlarListesi.map((i) => EgitimAdimModel.fromJson(i)).toList()` ifadesi çalışır.
  ///     Bu ifade, `adimlarListesi` içindeki her bir JSON nesnesini (`i`) alır,
  ///     `EgitimAdimModel.fromJson(i)` kullanarak bir `EgitimAdimModel` nesnesine dönüştürür
  ///     ve sonuçları yeni bir liste haline getirir.
  ///     Eğer `adimlarListesi` null ise (yani API'den adımlar gelmediyse veya 'adimlar' anahtarı yoksa),
  ///     `adimlar` alanına boş bir liste (`[]`) atanır. Bu, `NullPointerException` gibi hataların önüne geçer
  ///     ve uygulamanın daha stabil çalışmasını sağlar. Bu, bir çeşit yedeklilik ve hata toleransıdır;
  ///     beklenen veri gelmese bile program çökmez, bunun yerine boş bir adım listesi ile devam eder.
  ///
  /// Niyet: API'den gelen 'adimlar' listesinin varlığını ve geçerliliğini kontrol ederek,
  /// olası null veya yanlış tipteki verilere karşı sistemi korumak. Her bir adımın da
  /// kendi `fromJson` metoduyla doğru bir şekilde parse edilmesini sağlamak.
  factory EgitimDetayModel.fromJson(Map<String, dynamic> json) {
    // JSON'dan 'adimlar' anahtarına karşılık gelen listeyi alır.
    // Bu listenin null olabileceği veya beklenen formatta olmayabileceği göz önünde bulundurulur.
    // `as List?` ile yapılan cast, bu esnekliği sağlar.
    var adimlarListesiRaw = json['adimlar']; // Önce ham veriyi alalım
    List<EgitimAdimModel> parsedAdimlar; // Sonuçta doldurulacak liste

    // `adimlarListesiRaw`'ın gerçekten bir `List` olup olmadığını ve null olmadığını kontrol et.
    // Bu, `json['adimlar'] as List?` kullanımından daha güvenli bir yaklaşımdır,
    // çünkü `as` operatörü yanlış tip durumunda exception fırlatırken, bu kontrol
    // durumu yönetmemize olanak tanır.
    if (adimlarListesiRaw is List) {
      // Eğer bir liste ise, her bir elemanını EgitimAdimModel.fromJson kullanarak dönüştür.
      // `whereType<Map<String, dynamic>>()` gibi ek bir filtreleme ile
      // listenin içindeki elemanların da beklenen tipte (Map) olduğundan emin olunabilir,
      // bu da daha fazla güvenlik sağlar.
      parsedAdimlar = adimlarListesiRaw
          .whereType<Map<String, dynamic>>() // Sadece Map olan elemanları al
          .map((i) => EgitimAdimModel.fromJson(i)) // Her bir Map'i EgitimAdimModel'e dönüştür
          .toList(); // Sonucu bir liste yap
    } else {
      // Eğer 'adimlar' anahtarı yoksa, null ise veya bir liste değilse,
      // adimlar için boş bir liste ata. Bu, uygulamanın çökmesini önler
      // ve adımların olmadığı bir durumu zarifçe yönetir.
      parsedAdimlar = [];
    }

    // JSON'dan diğer alanları okur ve ilgili tiplere dönüştürür.
    // 'egitimid' ve 'egitimadi' alanlarının API yanıtında her zaman bulunacağı
    // ve sırasıyla int ve String tipinde olacağı varsayılır.
    // 'egitim_kapak_vector' alanı ise null olabilir.
    final int egitimId = json['egitimid'] as int;
    final String egitimAdi = json['egitimadi'] as String;
    final String? egitimKapakVector = json['egitim_kapak_vector'] as String?;

    // Okunan ve dönüştürülen değerlerle yeni bir EgitimDetayModel nesnesi oluşturulur ve döndürülür.
    return EgitimDetayModel(
      egitimId: egitimId,
      egitimAdi: egitimAdi,
      egitimKapakVector: egitimKapakVector,
      adimlar: parsedAdimlar, // Burada işlenmiş ve güvenli hale getirilmiş `parsedAdimlar` listesi kullanılır.
    );
  }
}