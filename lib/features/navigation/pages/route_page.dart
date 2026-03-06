import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps paketi

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  // Harita kontrolcüsü (ileride kamerayı hareket ettirmek için gerekecek)
  late GoogleMapController mapController;

  // Başlangıç konumu (İstanbul)
  final LatLng _initialCenter = const LatLng(41.015137, 28.979530);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kurye tam ekran harita görsün diye body'den başlıyoruz
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialCenter,
          zoom: 13.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        // Kuryenin nerede olduğunu görmesi için şu iki satır kritik:
        myLocationEnabled: true, 
        myLocationButtonEnabled: true,
        
        // Harita tipi (Normal, Uydu, Hibrit)
        mapType: MapType.normal,
      ),
    );
  }
}