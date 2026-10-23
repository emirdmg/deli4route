import 'dart:math' as math;
import '../models/delivery_stop.dart';

/// Greedy nearest-neighbour ordering using great-circle distance, not road time.
class RouteOptimizer {
  static double distanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    double radians(double value) => value * math.pi / 180;
    final dLat = radians(lat2 - lat1);
    final dLng = radians(lng2 - lng1);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(radians(lat1)) *
            math.cos(radians(lat2)) *
            math.pow(math.sin(dLng / 2), 2);
    return 6371000 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
  }

  static List<DeliveryStop> nearestFirst(
    List<DeliveryStop> stops, {
    required double latitude,
    required double longitude,
  }) {
    if (stops.any((stop) => !stop.hasCoordinates)) {
      throw ArgumentError(
        'Sıralama için tüm durakların koordinatları gerekli.',
      );
    }
    final remaining = List<DeliveryStop>.of(stops);
    final ordered = <DeliveryStop>[];
    while (remaining.isNotEmpty) {
      var nearestIndex = 0;
      var nearestDistance = double.infinity;
      for (var i = 0; i < remaining.length; i++) {
        final stop = remaining[i];
        final distance = distanceMeters(
          latitude,
          longitude,
          stop.latitude!,
          stop.longitude!,
        );
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestIndex = i;
        }
      }
      final next = remaining.removeAt(nearestIndex);
      ordered.add(next);
      latitude = next.latitude!;
      longitude = next.longitude!;
    }
    return ordered;
  }
}
