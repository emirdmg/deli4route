import 'dart:io';
import 'package:excel/excel.dart';
import 'package:deli4route/features/routes/models/delivery_stop.dart';

class ExcelParser {
  static Future<List<DeliveryStop>> parseDeliveryStops(
    String filePath,
  ) async {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables[excel.tables.keys.first]!;

    // Header normalize
    final headers = sheet.rows.first
        .map((cell) =>
            cell?.value.toString().trim().toLowerCase())
        .toList();

    int indexOf(String key) =>
        headers.indexWhere((h) => h == key || h == '${key}s');

    final nameIndex = indexOf('customer_name');
    final phoneIndex = indexOf('phone');
    final addressIndex = indexOf('address');
    final noteIndex = indexOf('note');

    if (addressIndex == -1) {
      throw Exception('Address kolonu bulunamadı');
    }

    final List<DeliveryStop> stops = [];

    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      String? getCell(int index) {
        if (index < 0 || index >= row.length) return null;
        return row[index]?.value.toString().trim();
      }

      final address = getCell(addressIndex);

      if (address == null || address.isEmpty) continue;

      stops.add(
        DeliveryStop(
          customerName: getCell(nameIndex) ?? 'Bilinmeyen',
          phone: getCell(phoneIndex),
          address: address,
          note: getCell(noteIndex),
        ),
      );
    }

    return stops;
  }
}