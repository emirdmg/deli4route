import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uses the device's geocoder. No developer API key is required.
class GeocodingService {
  static const cacheKey = 'address_coordinates_v1';
  static final _geocoder = Geocoding();
  static DateTime? _lastRequest;

  static Future<Map<String, double>> getLatLngFromAddress(
    String address,
  ) async {
    final normalized = address.trim().toLowerCase();
    if (normalized.isEmpty) throw const FormatException('Adres boş.');
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> cache;
    try {
      cache =
          jsonDecode(prefs.getString(cacheKey) ?? '{}') as Map<String, dynamic>;
    } catch (_) {
      cache = {};
    }
    final cached = cache[normalized];
    if (cached is Map && cached['lat'] is num && cached['lng'] is num) {
      return {
        'lat': (cached['lat'] as num).toDouble(),
        'lng': (cached['lng'] as num).toDouble(),
      };
    }
    // Native geocoders are rate-limited. Import resolves sequentially and caches
    // repeated addresses; coordinates supplied in Excel skip geocoding entirely.
    if (_lastRequest != null) {
      final remaining =
          const Duration(milliseconds: 1400) -
          DateTime.now().difference(_lastRequest!);
      if (!remaining.isNegative) await Future<void>.delayed(remaining);
    }
    _lastRequest = DateTime.now();
    try {
      final locations = await _geocoder
          .locationFromAddress(address)
          .timeout(const Duration(seconds: 20));
      if (locations.isEmpty) throw const FormatException('Adres bulunamadı.');
      final location = locations.first;
      final result = {'lat': location.latitude, 'lng': location.longitude};
      cache[normalized] = result;
      await prefs.setString(cacheKey, jsonEncode(cache));
      return result;
    } on PlatformException {
      throw const FormatException(
        'Adres çözümlenemedi. İnterneti kontrol edin veya haritadan konum seçin. '
        'Cihazın adres sorgulama sınırına ulaşılmış olabilir.',
      );
    } on TimeoutException {
      throw const FormatException(
        'Adres sorgusu zaman aşımına uğradı. Haritadan konum seçebilirsiniz.',
      );
    }
  }
}
