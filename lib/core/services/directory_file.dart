import 'dart:io';

import 'package:deli4route/core/excel/excel_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> pickExcelFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null) {
      if (kDebugMode) {
        print("Kullanıcı dosya seçmedi.");
      }
      return;
    }

    final file = result.files.single;
    final path = file.path;
    final name = file.name.toLowerCase();

    if (path == null) {
      if (kDebugMode) {
        print("Dosya yolu alınamadı.");
      }

      return;
    }

    if (!name.endsWith('.xlsx') && !name.endsWith('.xls')) {
      if (kDebugMode) {
        print("Geçersiz dosya formatı.");
      }
      return;
    }

    if (kDebugMode) {
      print("Excel dosyası seçildi: $name");
      print("Dosya yolu: $path");
    }

    final stops = await ExcelParser.parseDeliveryStops(path);

    if (kDebugMode) {
      print('🚚 Toplam teslimat: ${stops.length}');
    }
    for (final stop in stops) {
      if (kDebugMode) {
        print(stop);
      }
    }

    // ⛔️ BURADA DURUYORUZ
    // Bir sonraki adım: Excel parse
  } catch (e) {
    if (kDebugMode) {
      print("Excel seçerken hata oluştu: $e");
    }
  }
}

Future<void> downloadExcelTemplate() async {
  try {
    // 1️⃣ Assets’ten oku
    final byteData = await rootBundle.load(
      'assets/templates/delivery_template.xlsx',
    );

    final bytes = byteData.buffer.asUint8List();

    // 2️⃣ Platforma göre dizin seç
    Directory directory;

    if (Platform.isAndroid) {
      directory =
          (await getDownloadsDirectory()) ??
          await getApplicationDocumentsDirectory();
    } else {
      // iOS / macOS / Simulator
      directory = await getApplicationDocumentsDirectory();
    }

    final filePath = '${directory.path}/delivery_template.xlsx';
    final file = File(filePath);

    // 🔐 klasör yoksa oluştur
    await file.parent.create(recursive: true);

    // 3️⃣ Dosyayı yaz
    await file.writeAsBytes(bytes, flush: true);

    if (kDebugMode) {
      print('✅ Template indirildi: $filePath');
    }

    // 4️⃣ KANIT: dosya var mı?
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;
    if (kDebugMode) {
      print('Exists: $exists | Size: $size bytes');
    }

    // 5️⃣ 🔥 İŞTE SHARE BURADA 🔥
    if (exists) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Excel teslimat template’i',
        ),
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Template indirme hatası: $e');
    }
  }
}
