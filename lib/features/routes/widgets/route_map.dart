import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/delivery_stop.dart';

class RouteMap extends StatelessWidget {
  final LatLng origin;
  final List<DeliveryStop> stops;
  final LatLng? selectedPoint;
  final ValueChanged<LatLng>? onTap;

  const RouteMap({
    super.key,
    required this.origin,
    this.stops = const [],
    this.selectedPoint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pending = stops.where((stop) => !stop.completed).toList();
    final points = [
      origin,
      ...pending.map((stop) => LatLng(stop.latitude!, stop.longitude!)),
    ];
    final distinctPoints = points.toSet().toList();
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: origin,
            initialZoom: 14,
            minZoom: 2,
            maxZoom: 19,
            initialCameraFit: onTap == null && distinctPoints.length > 1
                ? CameraFit.coordinates(
                    coordinates: distinctPoints,
                    padding: const EdgeInsets.all(45),
                    maxZoom: 16,
                  )
                : null,
            onTap: onTap == null ? null : (_, point) => onTap!(point),
          ),
          children: [
            TileLayer(
              urlTemplate: const String.fromEnvironment(
                'MAP_TILE_URL',
                defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              userAgentPackageName: 'com.emirhan.deli4route',
              maxNativeZoom: 19,
            ),
            if (onTap == null && points.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    color: const Color(0xFFEA650E),
                    strokeWidth: 3,
                    pattern: const StrokePattern.dotted(),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: origin,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                for (var i = 0; i < pending.length; i++)
                  Marker(
                    point: LatLng(pending[i].latitude!, pending[i].longitude!),
                    width: 38,
                    height: 38,
                    child: Tooltip(
                      message:
                          '${i + 1}. ziyaret · Excel #${pending[i].originalNumber}',
                      child: CircleAvatar(
                        backgroundColor: i == 0
                            ? Colors.deepOrange
                            : const Color(0xFF273749),
                        foregroundColor: Colors.white,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                if (selectedPoint != null)
                  Marker(
                    point: selectedPoint!,
                    width: 42,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.deepOrange,
                      size: 42,
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                await launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
