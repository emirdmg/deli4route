import 'dart:io';

import 'package:deli4route/core/excel/excel_parser.dart';
import 'package:file_picker/file_picker.dart';
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
      print("Kullanıcı dosya seçmedi.");
      return;
    }

    final file = result.files.single;
    final path = file.path;
    final name = file.name.toLowerCase();

    if (path == null) {
      print("Dosya yolu alınamadı.");
      return;
    }

    if (!name.endsWith('.xlsx') && !name.endsWith('.xls')) {
      print("Geçersiz dosya formatı.");
      return;
    }

    print("Excel seçildi: $name");
    print("Yol: $path");

    final stops = await ExcelParser.parseDeliveryStops(path);

    print('🚚 Toplam teslimat: ${stops.length}');
    for (final stop in stops) {
      print(stop);
    }

    // ⛔️ BURADA DURUYORUZ
    // Bir sonraki adım: Excel parse
  } catch (e) {
    print("Excel seçerken hata oluştu: $e");
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

    print('✅ Template indirildi: $filePath');

    // 4️⃣ KANIT: dosya var mı?
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;
    print('Exists: $exists | Size: $size bytes');

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
    print('❌ Template indirme hatası: $e');
  }
}
