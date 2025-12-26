import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

Future<void> saveAndOpenPdf({
  required List<int> bytes,
  required String fileName,
}) async {
  final data = Uint8List.fromList(bytes);

  await Printing.layoutPdf(
    name: '$fileName.pdf', // يظهر كاسم افتراضي في بعض المتصفحات
    onLayout: (PdfPageFormat format) async => data,
  );
}