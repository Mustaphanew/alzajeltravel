// print_issuing.dart
import 'package:alzajeltravel/controller/travelers_review/travelers_review_controller.dart';
import 'package:alzajeltravel/model/booking_data_model.dart';
import 'package:alzajeltravel/model/flight/flight_segment_model.dart';

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

import 'package:get/get.dart';

class PrintIssuing extends StatefulWidget {
  final String pnr;
  final BookingDataModel bookingData;
  final RevalidatedFlightModel offerDetail;
  final TravelersReviewController travelersReviewController;
  final ContactModel contact;
  final List<Map<String, dynamic>> baggagesData;

  const PrintIssuing({
    super.key,
    required this.pnr,
    required this.bookingData,
    required this.offerDetail,
    required this.travelersReviewController,
    required this.contact,
    required this.baggagesData,
  });

  @override
  State<PrintIssuing> createState() => _PrintIssuingState();
}

class _PrintIssuingState extends State<PrintIssuing> {
  late String splashArSvg;

  // Colors close to sample
  static final PdfColor _navy = PdfColor.fromInt(0xFF17204D);
  static final PdfColor _lightGrey = PdfColor.fromInt(0xFFEFEFEF);

  late final List<FlightSegmentModel> segments;
  late final List<TravelerReviewModel> travelers;
  late final TravelerFareSummary summary;

  @override
  void initState() {
    super.initState();

    // ✅ جهّز البيانات أولاً
    segments = widget.offerDetail.offer.segments;
    travelers = List<TravelerReviewModel>.from(widget.travelersReviewController.travelers);
    summary = widget.travelersReviewController.summary;

    // ✅ اطبع بعد أول frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      printIssuing();
    });
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

  String _fmtDate(DateTime? d, {String pattern = 'dd-MM-yyyy'}) {
    if (d == null) return '';
    return AppFuns.replaceArabicNumbers(DateFormat(pattern).format(d));
  }

  String _fmtDateTime(DateTime? d, {String pattern = 'dd-MM-yyyy HH:mm'}) {
    if (d == null) return '';
    return AppFuns.replaceArabicNumbers(DateFormat(pattern).format(d));
  }

  String _fmtMoney(double v) {
    final s = v.toStringAsFixed(2);
    if (s.endsWith('.00')) return s.substring(0, s.length - 3);
    return s;
  }

  Future<void> printIssuing() async {
    try {
      splashArSvg = await imageLoadAsset(AppConsts.splashArSvg, type: 'svg');

      // اسم الملف = رقم الحجز
      final bookingNumber = (widget.bookingData.bookingId)
          .toString()
          .replaceAll('/', '_')
          .replaceAll('\\', '_')
          .replaceAll(' ', '_');

      // تحميل الخط
      final arabicFont = await fontLoadAsset('assets/fonts/Almaria/Almarai-Regular.ttf');
      final arabicBoldFont = await fontLoadAsset('assets/fonts/Almaria/Almarai-Bold.ttf');

      final doc = pw.Document(
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
      );

      // تجهيز البيانات
      final pnr = (widget.pnr).toString();
      final bookingNo = (widget.bookingData.bookingId).toString();

      final headerEmail = (widget.bookingData.bookedBy).toString();
      final headerPhoneOrRef = (widget.bookingData.mobileNo).toString();
      final headerDate = (widget.bookingData.createdOn).toString();

      final status = (widget.bookingData.status.toJson()).toString();

      final contactName = '${widget.contact.firstName} ${widget.contact.lastName}'.trim();
      final contactPhone = '+${widget.contact.phoneCountry.dialcode} ${widget.contact.phone}';
      final contactNationality = (widget.contact.nationality.name['en'] ?? '').toString();

      // ---------------- Pricing rows from summary ----------------
      final pricingRows = <List<String>>[];

      if (summary.adultCount > 0) {
        pricingRows.add(<String>[
          'Adult X${summary.adultCount}',
          _fmtMoney(summary.adultsTotalBaseFareAllPassengers),
          _fmtMoney(summary.adultsTotalTaxAllPassengers),
          _fmtMoney(summary.adultsTotalFareAllPassengers),
        ]);
      }

      if (summary.childCount > 0) {
        pricingRows.add(<String>[
          'Child X${summary.childCount}',
          _fmtMoney(summary.childrenTotalBaseFareAllPassengers),
          _fmtMoney(summary.childrenTotalTaxAllPassengers),
          _fmtMoney(summary.childrenTotalFareAllPassengers),
        ]);
      }

      if (summary.infantLapCount > 0) {
        pricingRows.add(<String>[
          'Infant X${summary.infantLapCount}',
          _fmtMoney(summary.infantsTotalBaseFareAllPassengers),
          _fmtMoney(summary.infantsTotalTaxAllPassengers),
          _fmtMoney(summary.infantsTotalFareAllPassengers),
        ]);
      }

      final totalBase = summary.adultsTotalBaseFareAllPassengers +
          summary.childrenTotalBaseFareAllPassengers +
          summary.infantsTotalBaseFareAllPassengers;

      final totalTax = summary.adultsTotalTaxAllPassengers +
          summary.childrenTotalTaxAllPassengers +
          summary.infantsTotalTaxAllPassengers;

      final totalFare = summary.adultsTotalFareAllPassengers +
          summary.childrenTotalFareAllPassengers +
          summary.infantsTotalFareAllPassengers;

      pricingRows.add(<String>[
        'Total All',
        _fmtMoney(totalBase),
        _fmtMoney(totalTax),
        _fmtMoney(totalFare),
      ]);

      final totalAllRowIndex = pricingRows.length - 1;

      // ---------------- Flight detail rows from segments ----------------
      // ✅ مطابق للتقرير: Departure/Arrival فيها 3 سطور، Airline سطر واحد، Flight.NO سطر واحد code-equipment
      final flightDetailRows = segments.map((s) {
        final depTerminal =
            (s.fromTerminal == null || s.fromTerminal!.trim().isEmpty) ? '-' : s.fromTerminal!.trim();
        final arrTerminal =
            (s.toTerminal == null || s.toTerminal!.trim().isEmpty) ? '-' : s.toTerminal!.trim();

        final depCell = [
          s.fromCode,
          _fmtDateTime(s.departureDateTime),
          'Terminal ($depTerminal)',
        ].join('\n');

        final arrCell = [
          s.toCode,
          _fmtDateTime(s.arrivalDateTime),
          'Terminal ($arrTerminal)',
        ].join('\n');

        // Airline column: مثل العينة (الكود فقط)
        final airlineCell = s.marketingAirlineCode;

        // ✅ Flight.NO: في نفس السطر marketingAirlineCode-equipmentNumber
        final flightNoCell = '${s.marketingAirlineCode}-${s.equipmentNumber}';

        return <String>[depCell, arrCell, airlineCell, flightNoCell];
      }).toList(growable: false);

      // ---------------- PDF ----------------
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
                          'BOOKINGVOUCHER',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: arabicBoldFont,
                            fontWeight: pw.FontWeight.bold,
                          ),
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

            // 1) Booking
            _sectionKeyValue(
              title: 'Booking',
              rows: [
                _kv('PNR', pnr),
                _kv('Booking Number', bookingNo),
                _kv('Date', headerDate),
                _kv('Status', status),
              ],
              font: arabicFont,
              bold: arabicBoldFont,
            ),

            pw.SizedBox(height: 18),

            // 2) Contact
            _sectionKeyValue(
              title: 'Contact',
              rows: [
                _kv('Name', contactName),
                _kv('Phone', contactPhone),
                _kv('Nationality', contactNationality),
              ],
              font: arabicFont,
              bold: arabicBoldFont,
            ),

            pw.SizedBox(height: 18),

            // ✅ 3) Flight Detail (مكانه هنا مثل التقرير)
            _sectionTable(
              title: 'Flight Detail',
              header: const ['Departure', 'Arrival', 'Airline', 'Flight.NO'],
              columnWidths: const {
                0: pw.FlexColumnWidth(2.2),
                1: pw.FlexColumnWidth(2.2),
                2: pw.FlexColumnWidth(1.3),
                3: pw.FlexColumnWidth(1.7),
              },
              rows: flightDetailRows,
              font: arabicFont,
              bold: arabicBoldFont,
            ),

            pw.SizedBox(height: 18),

            // 4) Travelers
            _sectionTable(
              title: 'Travelers',
              header: const ['Full name', 'Ticket', 'Date of birth', 'Passport Number'],
              columnWidths: const {
                0: pw.FlexColumnWidth(2.2),
                1: pw.FlexColumnWidth(1.6),
                2: pw.FlexColumnWidth(1.4),
                3: pw.FlexColumnWidth(1.6),
              },
              rows: travelers.map((t) {
                final passportNumber = (t.passport.documentNumber ?? '').toString();
                final fullName = (t.passport.fullName).toString();
                final ticket = (t.ticketNumber ?? 'N/A').toString();
                final dob = _fmtDate(t.passport.dateOfBirth);
                return <String>[fullName, ticket, dob, passportNumber];
              }).toList(growable: false),
              font: arabicFont,
              bold: arabicBoldFont,
            ),

            pw.SizedBox(height: 18),

            // 5) Baggage Info
            _sectionTable(
              title: 'Baggage Info',
              header: const ['Type', 'Weight'],
              columnWidths: const {0: pw.FlexColumnWidth(2.5), 1: pw.FlexColumnWidth(1.0)},
              columnAlignments: const {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
              rows: widget.baggagesData.map((row) {
                final type = (row['type'] ?? '').toString();
                final weight = (row['Weight'] ?? row['weight'] ?? '').toString();
                return [type, weight];
              }).toList(growable: false),
              font: arabicFont,
              bold: arabicBoldFont,
            ),

            pw.SizedBox(height: 18),

            // 6) Pricing Info (Total All row = light grey)
            _sectionTable(
              title: 'Pricing Info',
              header: const ['Type', 'Base Fare', 'Tax', 'Total fare'],
              columnWidths: const {
                0: pw.FlexColumnWidth(2.0),
                1: pw.FlexColumnWidth(1.0),
                2: pw.FlexColumnWidth(1.0),
                3: pw.FlexColumnWidth(1.2),
              },
              // مثل التقرير: Base/Tax وسط، Total fare يمين
              columnAlignments: const {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
              rows: pricingRows,
              font: arabicFont,
              bold: arabicBoldFont,
              // ✅ Total All row style
              highlightedRows: {totalAllRowIndex},
              highlightedBg: _lightGrey,
              highlightedBold: true,
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
      await saveAndOpenPdf(bytes: bytes, fileName: bookingNumber);
    } catch (e, s) {
      // ignore: avoid_print
      print('❌ Error in printIssuing: $e');
      // ignore: avoid_print
      print(s);
    } finally {
      if (mounted) Navigator.pop(context);
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
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 12,
          font: bold,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _cell(
    String text, {
    required PdfColor bg,
    required pw.Font font,
    pw.Font? bold,
    bool isHeaderCell = false,
    bool isBold = false,
    pw.Alignment align = pw.Alignment.centerLeft,
    pw.EdgeInsets padding = const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
  }) {
    final useBold = (isHeaderCell || isBold) && bold != null;

    return pw.Container(
      alignment: align,
      color: bg,
      padding: padding,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          font: useBold ? bold : font,
          fontWeight: (isHeaderCell || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
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
          children: rows.map((r) {
            return pw.TableRow(
              children: [
                _cell(r.key, bg: _lightGrey, font: font, bold: bold, isHeaderCell: true),
                _cell(r.value, bg: PdfColors.white, font: font, bold: bold),
              ],
            );
          }).toList(growable: false),
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

    // ✅ لإبراز صفوف معينة (مثل Total All)
    Set<int>? highlightedRows,
    PdfColor? highlightedBg,
    bool highlightedBold = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(title, bold: bold),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          columnWidths: columnWidths,
          children: [
            // Header row
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

            // Body rows
            ...rows.asMap().entries.map((entry) {
              final rowIndex = entry.key;
              final r = entry.value;

              final isHighlighted = highlightedRows?.contains(rowIndex) ?? false;
              final bg = isHighlighted ? (highlightedBg ?? _lightGrey) : PdfColors.white;

              return pw.TableRow(
                children: List.generate(r.length, (i) {
                  final align = columnAlignments?[i] ?? pw.Alignment.centerLeft;
                  return _cell(
                    r[i],
                    bg: bg,
                    font: font,
                    bold: bold,
                    align: align,
                    isBold: isHighlighted && highlightedBold,
                  );
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
          children: [
            Text('Print Issuing...'.tr),
            const SizedBox(height: 16),
            const SizedBox(height: 60, width: 60, child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ),
      ),
    );
  }
}
