import 'dart:io';
import 'package:deli4route/core/excel/excel_parser.dart';
import 'package:deli4route/features/routes/models/delivery_stop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<List<DeliveryStop>?> pickExcelFile() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );
  if (result == null) return null;
  final file = result.files.single;
  final path = file.path;
  if (path == null) {
    throw const FormatException(
      'Dosya açılamadı. Dosyayı cihazınıza kaydedip tekrar deneyin.',
    );
  }
  return ExcelParser.parseDeliveryStops(path);
}

Future<void> downloadExcelTemplate({Rect? sharePositionOrigin}) async {
  final data = await rootBundle.load('assets/templates/delivery_template.xlsx');
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/delivery_template.xlsx');
  await file.writeAsBytes(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'Deli4Route Excel şablonu',
      sharePositionOrigin:
          sharePositionOrigin ?? const Rect.fromLTWH(0, 0, 1, 1),
    ),
  );
}
