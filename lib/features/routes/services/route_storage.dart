import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/delivery_stop.dart';

class SavedRoute {
  final List<DeliveryStop> stops;
  final double latitude;
  final double longitude;
  final bool isDemo;

  const SavedRoute({
    required this.stops,
    required this.latitude,
    required this.longitude,
    this.isDemo = false,
  });

  Map<String, dynamic> toJson() => {
    'version': 1,
    'isDemo': isDemo,
    'latitude': latitude,
    'longitude': longitude,
    'stops': stops.map((stop) => stop.toJson()).toList(),
  };

  factory SavedRoute.fromJson(Map<String, dynamic> json) {
    final route = SavedRoute(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDemo: json['isDemo'] as bool? ?? false,
      stops: (json['stops'] as List)
          .map(
            (stop) =>
                DeliveryStop.fromJson(Map<String, dynamic>.from(stop as Map)),
          )
          .toList(),
    );
    if (json['version'] != 1 ||
        route.stops.isEmpty ||
        route.stops.length > 200 ||
        !route.latitude.isFinite ||
        route.latitude.abs() > 90 ||
        !route.longitude.isFinite ||
        route.longitude.abs() > 180 ||
        route.stops.any((stop) => !stop.hasCoordinates) ||
        route.stops.map((stop) => stop.id).toSet().length !=
            route.stops.length) {
      throw const FormatException('Kayıtlı rota verileri geçersiz.');
    }
    return route;
  }
}

class RouteStorage {
  static const key = 'delivery_route_v1';

  Future<SavedRoute?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value == null) return null;
    return SavedRoute.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> save(SavedRoute route) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(key, jsonEncode(route.toJson()))) {
      throw StateError('Rota cihazınıza kaydedilemedi.');
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.remove(key)) throw StateError('Rota silinemedi.');
    await prefs.remove('address_coordinates_v1');
  }
}
