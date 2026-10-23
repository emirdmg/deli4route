import 'dart:io';
import 'package:excel/excel.dart';
import 'package:deli4route/features/routes/models/delivery_stop.dart';

class ExcelParser {
  static Future<List<DeliveryStop>> parseDeliveryStops(String filePath) async {
    if (!filePath.toLowerCase().endsWith('.xlsx')) {
      throw const FormatException(
        'Lütfen .xlsx biçiminde bir Excel dosyası seçin.',
      );
    }
    return parseBytes(await File(filePath).readAsBytes());
  }

  static List<DeliveryStop> parseBytes(List<int> bytes) {
    final workbook = Excel.decodeBytes(bytes);
    final sheets = workbook.tables.values.where(
      (sheet) =>
          sheet.rows.any((row) => row.any((cell) => _text(cell).isNotEmpty)),
    );
    if (sheets.isEmpty) throw const FormatException('Excel dosyası boş.');
    final rows = sheets.first.rows;
    final headerRow = rows.indexWhere(
      (row) => row.any((cell) => _text(cell).isNotEmpty),
    );
    if (headerRow < 0) throw const FormatException('Excel dosyası boş.');
    final headers = rows[headerRow]
        .map((cell) => _normalize(_text(cell)))
        .toList();
    int column(List<String> names) => headers.indexWhere(names.contains);
    final addressIndex = column(['address', 'addresses', 'adres', 'adresler']);
    final nameIndex = column([
      'customer_name',
      'customer_names',
      'name',
      'ad_soyad',
      'musteri_adi',
      'musteri',
    ]);
    final phoneIndex = column(['phone', 'phones', 'telefon', 'telefon_no']);
    final noteIndex = column(['note', 'notes', 'not', 'notlar']);
    final latIndex = column(['latitude', 'lat', 'enlem']);
    final lngIndex = column(['longitude', 'lng', 'lon', 'boylam']);
    if (addressIndex < 0 && (latIndex < 0 || lngIndex < 0)) {
      throw const FormatException(
        'address / adres sütunu veya latitude ve longitude sütunları gerekli.',
      );
    }

    final stops = <DeliveryStop>[];
    for (var i = headerRow + 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.every((cell) => _text(cell).isEmpty)) continue;
      String cell(int index) =>
          index < 0 || index >= row.length ? '' : _text(row[index]);
      final latText = cell(latIndex);
      final lngText = cell(lngIndex);
      double? lat;
      double? lng;
      if (latText.isNotEmpty || lngText.isNotEmpty) {
        lat = double.tryParse(latText.replaceAll(',', '.'));
        lng = double.tryParse(lngText.replaceAll(',', '.'));
        if (lat == null ||
            lng == null ||
            !lat.isFinite ||
            !lng.isFinite ||
            lat.abs() > 90 ||
            lng.abs() > 180) {
          throw FormatException('${i + 1}. satırda enlem/boylam geçersiz.');
        }
      }
      final address = cell(addressIndex);
      if (address.isEmpty && lat == null) {
        throw FormatException('${i + 1}. satırda adres boş.');
      }
      final name = cell(nameIndex);
      stops.add(
        DeliveryStop(
          id: 'row-${i + 1}',
          originalNumber: stops.length + 1,
          customerName: name.isEmpty ? 'Durak ${stops.length + 1}' : name,
          address: address.isEmpty ? '$lat, $lng' : address,
          phone: cell(phoneIndex).isEmpty ? null : cell(phoneIndex),
          note: cell(noteIndex).isEmpty ? null : cell(noteIndex),
          latitude: lat,
          longitude: lng,
        ),
      );
    }
    if (stops.isEmpty) {
      throw const FormatException('Dosyada teslimat adresi bulunamadı.');
    }
    if (stops.length > 200) {
      throw const FormatException(
        'Bir rotaya en fazla 200 durak ekleyebilirsiniz.',
      );
    }
    return stops;
  }

  static String _text(Data? cell) => cell?.value?.toString().trim() ?? '';

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll('\u0307', '')
      .replaceAll('ı', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[\s-]+'), '_');
}
