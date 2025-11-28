import 'package:file_picker/file_picker.dart';

Future<void> pickFile() async {
  try {
    // Dosya seçici aç
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,  // tek dosya
      type: FileType.any,    // her türlü dosyayı seç
    );

    // Kullanıcı dosya seçmezse
    if (result == null) {
      print("Kullanıcı dosya seçmedi.");
      return;
    }

    // Dosya bilgileri
    final name = result.files.single.name;
    final path = result.files.single.path;

    print("Seçilen dosya: $name");
    print("Dosya yolu: $path");
  } catch (e) {
    print("Dosya seçerken hata oluştu: $e");
  }
}