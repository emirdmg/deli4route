import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  static final String _apiKey = dotenv.env["GOOGLE_API_KEY"] ?? '';

  static Future<Map<String, double>> getLatLngFromAddress(
      String address) async {

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeComponent(address)}'
      '&key=$_apiKey',
    );

    final response = await http.get(uri);
    final data = json.decode(response.body);

    if (data['status'] != 'OK') {
      throw Exception('Adres çözümlenemedi');
    }

    final location =
        data['results'][0]['geometry']['location'];

    return {
      'lat': location['lat'],
      'lng': location['lng'],
    };
  }
}