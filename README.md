# Deli4Route

Excel dosyasındaki teslimat duraklarını başlangıç noktasından itibaren en yakın
komşu yöntemiyle sıralayan, Android ve iOS için Flutter uygulaması.

**Hesap, Firebase projesi, Google Maps SDK anahtarı veya .env gerekmez.**
Rota ve teslimat durumları bu cihazda tutulur.

## Kullanım

1. Cihaz konumuna izin verin veya **Başlangıç seç** ile haritadan bir nokta seçin.
2. **Excel’den rota oluştur** ile bir `.xlsx` dosyası yükleyin.
3. Konumları kontrol edin. Çözümlenemeyen veya yanlış bulunan bir durağı
   haritadan seçerek ya da enlem/boylam yazarak düzeltin.
4. Kontrol kutusunu işaretleyip sıralamayı oluşturun.
5. **Navigasyon** ile sıradaki durağı Google Maps uygulamasında veya tarayıcıda açın.
6. Teslimattan sonra **Tamamlandı** seçin. Kalan duraklar son tamamlanan noktadan
   tekrar sıralanır. Güncel GPS konumundan başlamak için **Konumumdan yeniden sırala**
   kullanın.
7. Uygulamayı kapatıp açtığınızda kayıtlı rotaya devam edin. Bir seferde tek rota saklanır;
   yeni rota, onayınızdan sonra eski rotanın yerini alır.

Denemek için uygulamadaki **Örnek 5 durakla dene** düğmesini kullanabilirsiniz.
Bu örnek gerçek teslimat adresleri içermez; İstanbul'da açıkça belirtilen bir test
başlangıcı ve test koordinatları kullanır.

## Excel biçimi

Şablon: [delivery_template.xlsx](assets/templates/delivery_template.xlsx)

Örnek: [sample_deliveries.xlsx](assets/templates/sample_deliveries.xlsx)

| Sütun | Açıklama |
| --- | --- |
| `address` veya `adres` | Teslimat adresi; il/ilçe eklemek sonuçları iyileştirir. |
| `customer_name` | İsteğe bağlı müşteri adı. |
| `phone` | İsteğe bağlı telefon; baştaki sıfırı korumak için Excel'de metin olarak tutun. |
| `note` | İsteğe bağlı teslimat notu. |
| `latitude`, `longitude` | İsteğe bağlı koordinatlar; ikisi birlikte girilmeli. |

- Adres yerine enlem ve boylam da sağlanabilir.
- Koordinatlar varsa adres çözümleme isteği gönderilmez.
- Türkçe `enlem`, `boylam`, `telefon`, `not` başlıkları da desteklenir.
- Boş satırlar atlanır; hatalı koordinatlar ve eksik adresler satır numarasıyla bildirilir.
- En fazla 200 durak alınır. CSV ve eski `.xls` biçimleri desteklenmez;
  önce `.xlsx` olarak kaydedin.
- Excel numarası içe aktarılan durakların özgün sırasıdır. Ziyaret sırası ayrıca
  1, 2, 3… olarak gösterilir.

## Sıralama ne yapar?

Başlangıçtan en yakın durak seçilir. Sonra bu duraktan kalan en yakın durak seçilir
ve tüm duraklar işlenene kadar devam edilir. Örnek Excel'in test başlangıcında sıra:

**2 → 3 → 1 → 5 → 4**

Mesafe Haversine formülüyle, **kuş uçuşu** olarak hesaplanır. Trafik, tek yön,
köprü, araç kapasitesi veya teslimat saati hesaba katılmaz. Bu sezgisel yöntem
toplamda en kısa sürüş rotasını garanti etmez. Haritadaki noktalı bağlantı,
yol geometrisi değil, ziyaret sırasıdır. Gerçek sürüş yolu harici navigasyonda hesaplanır.

## İnternet ve ücretsiz servisler

- Sıralama ve kayıt cihazda çalışır.
- Harita `flutter_map` ve OpenStreetMap harita döşemelerini kullanır.
  Kaynak gösterimi ve uygulama kimliği bulunur; flutter_map'in yerleşik,
  HTTP önbellek başlıklarına uyan döşeme önbelleği kullanılır.
- Adres çözümleme, `geocoding` üzerinden işletim sisteminin servisini kullanır.
  İnternet ve platform servisi gerekir; ücretsiz servisler kota/erişim sınırlarına
  tabidir. İşlemler sırayla yürütülür, sorgular arasında beklenir ve sonuçlar yerelde
  önbelleklenir. Servis kullanılamazsa koordinat veya haritadan seçim kullanılabilir.
- Navigasyon bağlantıları Google Maps URLs kullanır ve API anahtarı gerektirmez.
- Toplu/offline harita indirme yoktur. Harita sunucusu sınırsız veya garantili
  bir servis değildir. [OSM döşeme kullanım koşullarını](https://operations.osmfoundation.org/policies/tiles/)
  ve [geocoding paketinin sınırlarını](https://pub.dev/packages/geocoding) inceleyin.
- Kendi izinli döşeme sunucunuz için derleme sırasında
  `--dart-define=MAP_TILE_URL=https://sunucunuz/{z}/{x}/{y}.png` kullanabilirsiniz.
  Farklı sağlayıcı kullanırken gereken kaynak gösterimini de güncelleyin.

## Yerel veriler

Rota, alıcı bilgileri, tamamlanma durumu ve adres koordinat önbelleği
`shared_preferences` içinde saklanır; uygulamanın kendi bulut sunucusu yoktur.
Adres çözümlemede girilen adres işletim sisteminin servisine, navigasyon açıldığında
hedef koordinatı harita sağlayıcısına iletilir. Harita sunucusu görüntülenen
alanın döşeme isteklerini alır. **Rotayı sil** işlemi kayıtlı rotayı ve adres
önbelleğini temizler. Uygulamayı kaldırmak da yerel kayıtları siler.

Eski özel Firebase yapılandırması varsa geliştirme cihazında `.local/` içinde
yedeklenmiş olabilir. Bu klasör Git'e dahil edilmez ve uygulamada kullanılmaz.
Projeyi yeni klonlayan kişinin bu dosyalara ihtiyacı yoktur.

## Çalıştırma

Gerekli: Flutter/Dart, Android için SDK/JDK; iOS için macOS ve Xcode.
Minimum iOS sürümü 15.0'dır. Android/iOS desteklenir; web/masaüstü bu sürümün
hedefi değildir. Native bağımlılıklar iOS'ta Swift Package Manager ile yüklenir.

```sh
flutter pub get
flutter run
```

Firebase CLI, Google Cloud hesabı, CocoaPods veya API anahtarı kurulumu gerekmez.

## Kontroller

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

Testler gerçek örnek Excel'i okuma, 2→3→1→5→4 sırası, değişen başlangıç,
aynı konumdaki teslimatlar, hatalı veriler, kayıt/yeniden yükleme,
konum izni hatası ve konum kontrolü yapılmadan rotanın onaylanamamasını kapsar.

Örnek dosyaları yeniden üretmek için:

```sh
dart run tool/generate_examples.dart
```

## Yapı

- `lib/core/excel`: Excel okuma ve doğrulama
- `lib/core/geocoding`: Anahtarsız platform geocoding ve önbellek
- `lib/features/routes/services`: Sıralama, konum, kayıt, navigasyon
- `lib/features/routes/pages`: Haritadan konum seçimi
- `lib/features/home/pages/create_route_page.dart`: Excel yükleme ve konum kontrolü
- `lib/features/navigation/pages/route_page.dart`: Aktif rota ve teslimat akışı

## Kapsam

Bu bir öğrenme ve portföy projesidir. Hesap açma, şirket paneli, bulut senkronizasyonu,
teslimat kanıtı, otomatik WhatsApp/OCR aktarımı ve yol süresine dayalı optimizasyon
bu sürüme dahil değildir. Üretim ölçeğinde kullanım için servis kotaları, yerel veri
güvenliği ve operasyonel gereksinimler ayrıca değerlendirilmelidir.
