import 'pdf/pdf_saver.dart';

import 'package:flutter/material.dart';
import 'package:alzajeltravel/model/contact_model.dart';
import 'package:alzajeltravel/model/flight/revalidated_flight_model.dart';
import 'package:alzajeltravel/model/passport/traveler_review/traveler_review_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrintIssuing extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final RevalidatedFlightModel offerDetail;
  final List<TravelerReviewModel> travelers;
  final ContactModel contact;
  final List<Map<String, dynamic>> baggagesData;
  final List<Map<String, dynamic>> faringsData;

  const PrintIssuing({
    super.key,
    required this.bookingData,
    required this.offerDetail,
    required this.travelers,
    required this.contact,
    required this.baggagesData,
    required this.faringsData,
  });

  @override
  State<PrintIssuing> createState() => _PrintIssuingState();
}

class _PrintIssuingState extends State<PrintIssuing> {
  late String splashArSvg;

  // Colors close to sample
  static final PdfColor _navy = PdfColor.fromInt(0xFF17204D);
  static final PdfColor _lightGrey = PdfColor.fromInt(0xFFEFEFEF);

  @override
  void initState() {
    super.initState();
    printIssuing();
  }

  Future imageLoadAsset(String path, {String type = 'png'}) async {
    final logoData = await rootBundle.load(path);
    if (type == 'png' || type == 'jpg') {
      final logoBytes = logoData.buffer.asUint8List();
      final logoImage = pw.MemoryImage(logoBytes);
      return logoImage;
    } else if (type == 'svg') {
      final logoString = await rootBundle.loadString(path);
      return logoString;
    }
  }

  Future<pw.Font> fontLoadAsset(String path) async {
    final fontData = await rootBundle.load(path);
    final font = pw.Font.ttf(fontData);
    return font;
  }

  Future<void> printIssuing() async {
    try {
      splashArSvg = await imageLoadAsset(AppConsts.splashArSvg, type: 'svg');

      // اسم الملف = رقم الحجز
      final bookingNumber = (widget.bookingData['Booking Number'] ?? 'booking')
          .toString()
          .replaceAll('/', '_')
          .replaceAll('\\', '_')
          .replaceAll(' ', '_');

      // ignore: avoid_print
      print('📄 PDF file name: $bookingNumber.pdf');

      // تحميل الخط
      final arabicFont = await fontLoadAsset('assets/fonts/Almaria/Almarai-Regular.ttf');
      final arabicBoldFont = await fontLoadAsset('assets/fonts/Almaria/Almarai-Bold.ttf');

      final doc = pw.Document(
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
      );

      // تجهيز البيانات
      final pnr = (widget.bookingData['PNR'] ?? '').toString();
      final bookingNo = (widget.bookingData['Booking Number'] ?? '').toString();

      final headerEmail = (widget.bookingData['email'] ?? '').toString();
      final headerPhoneOrRef = (widget.bookingData['phone'] ?? '').toString();
      final headerDate = (widget.bookingData['date'] ?? '').toString();

      final status = (widget.bookingData['Status'] ?? widget.bookingData['status'] ?? widget.bookingData['bookingStatus'] ?? 'Confirmed')
          .toString();

      final contactName = '${widget.contact.firstName} ${widget.contact.lastName}'.trim();
      final contactPhone = '+${widget.contact.phoneCountry.dialcode} ${widget.contact.phone}';
      final contactNationality = (widget.contact.nationality.name['en'] ?? '').toString();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(24, 20, 24, 24),

          header: (context) => pw.Directionality(
            textDirection: pw.TextDirection.ltr,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(headerEmail, style: pw.TextStyle(fontSize: 11, font: arabicFont)),
                          pw.SizedBox(height: 4),
                          pw.Text(headerPhoneOrRef, style: pw.TextStyle(fontSize: 11, font: arabicFont)),
                          pw.SizedBox(height: 4),
                          pw.Text(headerDate, style: pw.TextStyle(fontSize: 11, font: arabicFont)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.topCenter,
                        child: pw.Text(
                          'BOOKING VOUCHER',
                          style: pw.TextStyle(fontSize: 12, font: arabicBoldFont, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.topRight,
                        child: pw.SvgImage(svg: splashArSvg, height: 280 / 7),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Container(height: 1, color: PdfColors.black),
                pw.SizedBox(height: 14),
              ],
            ),
          ),

          build: (context) => [
            pw.Text(
              'Flight Ticket',
              style: pw.TextStyle(fontSize: 28, font: arabicBoldFont, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 14),

            _sectionKeyValue(
              title: 'Booking',
              rows: [_kv('PNR', pnr), _kv('Booking Number', bookingNo), _kv('Date', headerDate), _kv('Status', status)],
              font: arabicFont,
              bold: arabicBoldFont,
            ),

            pw.SizedBox(height: 20),

            _sectionKeyValue(
              title: 'Contact',
              rows: [_kv('Name', contactName), _kv('Phone', contactPhone), _kv('Nationality', contactNationality)],
              font: arabicFont,
              bold: arabicBoldFont,
            ),

            pw.SizedBox(height: 20),

            _sectionTable(
              title: 'Travelers',
              header: const ['Full name', 'Ticket', 'Date of birth', 'Passport Number'],
              columnWidths: const {
                0: pw.FlexColumnWidth(2.2),
                1: pw.FlexColumnWidth(1.6),
                2: pw.FlexColumnWidth(1.4),
                3: pw.FlexColumnWidth(1.6),
              },
              rows: widget.travelers
                  .map((t) {
                    final passportNumber = (t.passport.documentNumber ?? '').toString();
                    final fullName = (t.passport.fullName).toString();
                    final ticket = (t.ticketNumber ?? 'N/A').toString();
                    final dob = (t.passport.dateOfBirth != null)
                        ? AppFuns.replaceArabicNumbers(DateFormat('dd-MM-yyyy').format(t.passport.dateOfBirth!))
                        : '';
                    return <String>[fullName, ticket, dob, passportNumber];
                  })
                  .toList(growable: false),
              font: arabicFont,
              bold: arabicBoldFont,
            ),

            pw.SizedBox(height: 20),

            _sectionTable(
              title: 'Baggage Info',
              header: const ['Type', 'Weight'],
              columnWidths: const {0: pw.FlexColumnWidth(2.5), 1: pw.FlexColumnWidth(1.0)},
              columnAlignments: const {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
              rows: widget.baggagesData
                  .map((row) {
                    final type = (row['type'] ?? '').toString();
                    final weight = (row['Weight'] ?? row['weight'] ?? '').toString();
                    return [type, weight];
                  })
                  .toList(growable: false),
              font: arabicFont,
              bold: arabicBoldFont,
            ),

            pw.SizedBox(height: 20),

            _sectionTable(
              title: 'Pricing Info',
              header: const ['Type', 'Total fare'],
              columnWidths: const {0: pw.FlexColumnWidth(2.5), 1: pw.FlexColumnWidth(1.0)},
              columnAlignments: const {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
              rows: widget.faringsData
                  .map((row) {
                    final type = (row['type'] ?? '').toString();
                    final totalFare = (row['Total fare'] ?? row['total'] ?? '').toString();
                    return [type, totalFare];
                  })
                  .toList(growable: false),
              font: arabicFont,
              bold: arabicBoldFont,
            ),
          ],

          footer: (context) => pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Align(
              alignment: pw.AlignmentDirectional.bottomStart,
              child: pw.Text(
                'الصفحة ${context.pageNumber} من ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 12, font: arabicFont, color: PdfColors.grey),
              ),
            ),
          ),
        ),
      );

      final bytes = await doc.save();

      // ✅ حفظ/فتح حسب المنصة (Android/iOS: حفظ وفتح، Web: طباعة/حفظ من المتصفح)
      await saveAndOpenPdf(bytes: bytes, fileName: bookingNumber);

      // ignore: avoid_print
      print('✅ PDF generated.');
    } catch (e, s) {
      // ignore: avoid_print
      print('❌ Error in printIssuing: $e');
      // ignore: avoid_print
      print(s);
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // -------------------- PDF UI Helpers --------------------

  MapEntry<String, String> _kv(String k, String v) => MapEntry(k, v);

  pw.Widget _sectionHeader(String title, {required pw.Font bold}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _navy,
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(color: PdfColors.white, fontSize: 12, font: bold, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _cell(
    String text, {
    required PdfColor bg,
    required pw.Font font,
    pw.Font? bold,
    bool isHeaderCell = false,
    pw.Alignment align = pw.Alignment.centerLeft,
    pw.EdgeInsets padding = const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
  }) {
    return pw.Container(
      alignment: align,
      color: bg,
      padding: padding,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          font: isHeaderCell && bold != null ? bold : font,
          fontWeight: isHeaderCell ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _sectionKeyValue({
    required String title,
    required List<MapEntry<String, String>> rows,
    required pw.Font font,
    required pw.Font bold,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(title, bold: bold),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          columnWidths: const {0: pw.FixedColumnWidth(160), 1: pw.FlexColumnWidth()},
          children: rows
              .map((r) {
                return pw.TableRow(
                  children: [
                    _cell(r.key, bg: _lightGrey, font: font, bold: bold, isHeaderCell: true),
                    _cell(r.value, bg: PdfColors.white, font: font, bold: bold),
                  ],
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }

  pw.Widget _sectionTable({
    required String title,
    required List<String> header,
    required List<List<String>> rows,
    required pw.Font font,
    required pw.Font bold,
    Map<int, pw.TableColumnWidth>? columnWidths,
    Map<int, pw.Alignment>? columnAlignments,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(title, bold: bold),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          columnWidths: columnWidths,
          children: [
            pw.TableRow(
              children: List.generate(header.length, (i) {
                final align = columnAlignments?[i] ?? pw.Alignment.centerLeft;
                return _cell(
                  header[i],
                  bg: _lightGrey,
                  font: font,
                  bold: bold,
                  isHeaderCell: true,
                  align: align,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                );
              }),
            ),
            ...rows.map((r) {
              return pw.TableRow(
                children: List.generate(r.length, (i) {
                  final align = columnAlignments?[i] ?? pw.Alignment.centerLeft;
                  return _cell(r[i], bg: PdfColors.white, font: font, bold: bold, align: align);
                }),
              );
            }),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text("Print Issuing..."),
            SizedBox(height: 16),
            SizedBox(height: 60, width: 60, child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ),
      ),
    );
  }
}
