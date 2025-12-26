import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveAndOpenPdf({
  required List<int> bytes,
  required String fileName,
}) async {
  final dir = await getTemporaryDirectory();
  final filePath = '${dir.path}/$fileName.pdf';
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);
  await OpenFilex.open(filePath);
}
