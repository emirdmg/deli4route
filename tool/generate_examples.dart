import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final directory = Directory('assets/templates')..createSync(recursive: true);
  final headers = [
    'customer_name',
    'phone',
    'address',
    'note',
    'latitude',
    'longitude',
  ].map(TextCellValue.new).toList();

  final template = Excel.createExcel();
  template['Sheet1'].appendRow(headers);
  File(
    '${directory.path}/delivery_template.xlsx',
  ).writeAsBytesSync(template.encode()!);

  final sample = Excel.createExcel();
  final sheet = sample['Sheet1'];
  sheet.appendRow(headers);
  final longitudes = [29.03, 29.01, 29.02, 29.05, 29.04];
  for (var i = 0; i < longitudes.length; i++) {
    sheet.appendRow([
      TextCellValue('Örnek durak ${i + 1}'),
      TextCellValue(''),
      TextCellValue('Test noktası ${i + 1}, İstanbul'),
      TextCellValue('Demo koordinatı; gerçek teslimat adresi değildir.'),
      const DoubleCellValue(41),
      DoubleCellValue(longitudes[i]),
    ]);
  }
  File(
    '${directory.path}/sample_deliveries.xlsx',
  ).writeAsBytesSync(sample.encode()!);
}
