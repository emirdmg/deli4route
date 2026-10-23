import 'package:url_launcher/url_launcher.dart';
import '../models/delivery_stop.dart';

class NavigationService {
  Future<void> open(DeliveryStop stop) async {
    if (!stop.hasCoordinates) {
      throw const FormatException('Durak konumu eksik.');
    }
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${stop.latitude},${stop.longitude}',
      'travelmode': 'driving',
      'dir_action': 'navigate',
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const FormatException(
        'Navigasyon açılamadı. Telefonunuzdaki harita veya tarayıcı ayarlarını kontrol edin.',
      );
    }
  }
}
