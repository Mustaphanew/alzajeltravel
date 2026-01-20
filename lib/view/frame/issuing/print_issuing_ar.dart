// print_issuing_ar.dart
import 'package:alzajeltravel/controller/travelers_review/travelers_review_controller.dart';
import 'package:alzajeltravel/model/booking_data_model.dart';
import 'package:alzajeltravel/model/flight/flight_segment_model.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:get/get.dart';

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

class PrintIssuingAr extends StatefulWidget {
  final String pnr;
  final BookingDataModel bookingData;
  final RevalidatedFlightModel offerDetail;
  final TravelersReviewController travelersReviewController;
  final ContactModel contact;
  final List<Map<String, dynamic>> baggagesData;

  const PrintIssuingAr({
    super.key,
    required this.pnr,
    required this.bookingData,
    required this.offerDetail,
    required this.travelersReviewController,
    required this.contact,
    required this.baggagesData,
  });

  @override
  State<PrintIssuingAr> createState() => _PrintIssuingArState();
}

class _PrintIssuingArState extends State<PrintIssuingAr> {
  late String splashArSvg;

  static final PdfColor _navy = PdfColor.fromInt(0xFF17204D);
  static final PdfColor _lightGrey = PdfColor.fromInt(0xFFEFEFEF);

  late final List<FlightSegmentModel> segments;
  late final List<TravelerReviewModel> travelers;
  late final TravelerFareSummary summary;

  @override
  void initState() {
    super.initState();

    segments = widget.offerDetail.offer.segments;
    travelers = List<TravelerReviewModel>.from(widget.travelersReviewController.travelers);
    summary = widget.travelersReviewController.summary;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      printIssuing();
    });
  }

  Future imageLoadAsset(String path, {String type = 'png'}) async {
    final logoData = await rootBundle.load(path);
    if (type == 'png' || type == 'jpg') {
      final logoBytes = logoData.buffer.asUint8List();
      return pw.MemoryImage(logoBytes);
    } else if (type == 'svg') {
      final logoString = await rootBundle.loadString(path);
      return logoString;
    }
  }

  Future<pw.Font> fontLoadAsset(String path) async {
    final fontData = await rootBundle.load(path);
    return pw.Font.ttf(fontData);
  }

  String _fmtDate(DateTime? d, {String pattern = 'dd-MM-yyyy'}) {
    if (d == null) return '';
    return AppFuns.replaceArabicNumbers(DateFormat(pattern).format(d));
  }

  String _fmtDateTime(DateTime? d, {String pattern = 'dd-MM-yyyy HH:mm'}) {
    if (d == null) return '';
    return AppFuns.replaceArabicNumbers(DateFormat(pattern).format(d));
  }

  String _fmtMoney(double v, {String currency = ''}) {
    final s = v.toStringAsFixed(2);
    final formatted = s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
    final cur = currency.trim();
    if (cur.isEmpty) return formatted;
    return '$formatted $cur';
  }

  // ===================== Legs helpers (safe) =====================

  List<dynamic> _safeLegs() {
    try {
      final any = (widget.offerDetail.offer as dynamic).legs;
      if (any is List) return any;
    } catch (_) {}
    return <dynamic>[];
  }

  List<FlightSegmentModel> _segmentsFromLeg(dynamic leg) {
    if (leg == null) return <FlightSegmentModel>[];

    try {
      if (leg is List<FlightSegmentModel>) return leg;
      if (leg is List) return leg.whereType<FlightSegmentModel>().toList();

      final segsAny = (leg as dynamic).segments;
      if (segsAny is List<FlightSegmentModel>) return segsAny;
      if (segsAny is List) return segsAny.whereType<FlightSegmentModel>().toList();
    } catch (_) {}

    return <FlightSegmentModel>[];
  }

  String _buildFlightRouteSubtitle() {
    final legs = _safeLegs();
    final legsCount = legs.isNotEmpty ? legs.length : 1;

    final leg0Segments = legs.isNotEmpty ? _segmentsFromLeg(legs[0]) : <FlightSegmentModel>[];

    final String depCode = leg0Segments.isNotEmpty
        ? leg0Segments.first.fromCode
        : (segments.isNotEmpty ? segments.first.fromCode : '-');

    final String arrCode = leg0Segments.isNotEmpty
        ? leg0Segments.last.toCode
        : (segments.isNotEmpty ? segments.last.toCode : '-');

    final tripType = (legsCount <= 1) ? 'ذهاب فقط' : 'ذهاب وعودة';

    final depName = AirportRepo.searchByCode(depCode).name[AppVars.lang];
    final arrName = AirportRepo.searchByCode(arrCode).name[AppVars.lang];

    return '$depName ($depCode) - $arrName ($arrCode) [$tripType]';
  }

  Future<void> printIssuing() async {
    final String currency = widget.bookingData.currency;

    try {
      splashArSvg = await imageLoadAsset(AppConsts.splashArSvg, type: 'svg');

      final bookingNumber = (widget.bookingData.bookingId)
          .toString()
          .replaceAll('/', '_')
          .replaceAll('\\', '_')
          .replaceAll(' ', '_');

      final arabicFont = await fontLoadAsset('assets/fonts/Almaria/Almarai-Regular.ttf');
      final arabicBoldFont = await fontLoadAsset('assets/fonts/Almaria/Almarai-Bold.ttf');

      final doc = pw.Document(
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
      );

      final pnr = widget.pnr.toString();
      final bookingNo = widget.bookingData.bookingId.toString();

      final headerEmail = widget.bookingData.bookedBy.toString();
      final headerPhoneOrRef = widget.bookingData.mobileNo.toString();
      final headerDate = widget.bookingData.createdOn.toString();

      final status = widget.bookingData.status.toJson().toString().tr;

      final contactName = '${widget.contact.firstName} ${widget.contact.lastName}'.trim();
      final contactPhone = '+${widget.contact.phoneCountry.dialcode} ${widget.contact.phone}';
      final contactNationality = widget.contact.nationality.name[AppVars.lang].toString();

      final flightRouteSubtitle = _buildFlightRouteSubtitle();

      // ---------------- Pricing rows from summary ----------------
      final pricingRows = <List<String>>[];

      if (summary.adultCount > 0) {
        pricingRows.add(<String>[
          'بالغ X${summary.adultCount}',
          _fmtMoney(summary.adultsTotalBaseFareAllPassengers),
          _fmtMoney(summary.adultsTotalTaxAllPassengers),
          _fmtMoney(summary.adultsTotalFareAllPassengers),
        ]);
      }

      if (summary.childCount > 0) {
        pricingRows.add(<String>[
          'طفل X${summary.childCount}',
          _fmtMoney(summary.childrenTotalBaseFareAllPassengers),
          _fmtMoney(summary.childrenTotalTaxAllPassengers),
          _fmtMoney(summary.childrenTotalFareAllPassengers),
        ]);
      }

      if (summary.infantLapCount > 0) {
        pricingRows.add(<String>[
          'رضيع X${summary.infantLapCount}',
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
        'الإجمالي الكلي',
        _fmtMoney(totalBase, currency: currency),
        _fmtMoney(totalTax, currency: currency),
        _fmtMoney(totalFare, currency: currency),
      ]);

      final totalAllRowIndex = pricingRows.length - 1;

      // ---------------- Flight detail rows from segments ----------------
      final flightDetailRows = segments.map((s) {
        final depTerminal =
            (s.fromTerminal == null || s.fromTerminal!.trim().isEmpty) ? '-' : s.fromTerminal!.trim();
        final arrTerminal =
            (s.toTerminal == null || s.toTerminal!.trim().isEmpty) ? '-' : s.toTerminal!.trim();

        final depName = AirportRepo.searchByCode(s.fromCode).name[AppVars.lang];
        final arrName = AirportRepo.searchByCode(s.toCode).name[AppVars.lang];

        final depCell = [
          '$depName (${s.fromCode})',
          _fmtDateTime(s.departureDateTime),
          'الصالة ($depTerminal)',
        ].join('\n');

        final arrCell = [
          '$arrName (${s.toCode})',
          _fmtDateTime(s.arrivalDateTime),
          'الصالة ($arrTerminal)',
        ].join('\n');

        final airlineName = AirlineRepo.searchByCode(s.marketingAirlineCode)?.name[AppVars.lang];
        final airlineCell = (airlineName == null || airlineName.toString().trim().isEmpty)
            ? s.marketingAirlineCode
            : '$airlineName (${s.marketingAirlineCode})';

        final flightNoCell = '${s.marketingAirlineCode}-${s.equipmentNumber}';

        return <String>[depCell, arrCell, airlineCell, flightNoCell];
      }).toList(growable: false);

      // ---------------- PDF ----------------
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(24, 20, 24, 24),
          header: (context) => pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // pw.Expanded(
                    //   child: pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.end,
                    //     children: [
                    //       pw.Text(headerEmail, style: pw.TextStyle(fontSize: 11, font: arabicFont)),
                    //       pw.SizedBox(height: 4),
                    //       pw.Text(headerPhoneOrRef, style: pw.TextStyle(fontSize: 11, font: arabicFont)),
                    //       pw.SizedBox(height: 4),
                    //       pw.Text(headerDate, style: pw.TextStyle(fontSize: 11, font: arabicFont)),
                    //     ],
                    //   ),
                    // ),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.AlignmentDirectional.centerStart,
                        child: pw.Text(
                          'قسيمة حجز',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: arabicBoldFont,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // pw.Expanded(
                    pw.Align(
                      alignment: pw.Alignment.topRight,
                      child: pw.SvgImage(svg: splashArSvg, height: 280 / 7),
                    ),
                    // ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Container(height: 1, color: PdfColors.black),
                pw.SizedBox(height: 14),
              ],
            ),
          ),
          build: (context) => [
            // 1) Booking
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: _sectionKeyValue(
                title: 'بيانات الحجز',
                rows: [
                  _kv('PNR', pnr),
                  _kv('رقم الحجز', bookingNo),
                  _kv('التاريخ', headerDate),
                  _kv('الحالة', status),
                ],
                font: arabicFont,
                bold: arabicBoldFont,
              ),
            ),

            pw.SizedBox(height: 18),

            // 2) Contact
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: _sectionKeyValue(
                title: 'بيانات التواصل',
                rows: [
                  _kv('الاسم', contactName),
                  _kv('الهاتف', contactPhone),
                  _kv('الجنسية', contactNationality),
                ],
                font: arabicFont,
                bold: arabicBoldFont,
              ),
            ),

            pw.SizedBox(height: 18),

            // 3) Flight Detail (✅ columns reversed RTL)
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: _sectionTable(
                title: 'تفاصيل الرحلة',
                subtitle: flightRouteSubtitle,
                header: const ['الذهاب', 'الوصول', 'شركة الطيران', 'رقم الرحلة'],
                columnWidths: const {
                  0: pw.FlexColumnWidth(2.2),
                  1: pw.FlexColumnWidth(2.2),
                  2: pw.FlexColumnWidth(1.4),
                  3: pw.FlexColumnWidth(1.2), 
                },
                columnAlignments: const {
                  0: pw.Alignment.centerRight,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                },
                rows: flightDetailRows,
                font: arabicFont,
                bold: arabicBoldFont,
                rtlColumns: true,
              ),
            ),

            pw.SizedBox(height: 18),

            // 4) Travelers (✅ columns reversed RTL)
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: _sectionTable(
                title: 'المسافرون',
                header: const ['الاسم الكامل', 'رقم التذكرة', 'تاريخ الميلاد', 'رقم الجواز'],
                columnWidths: const {
                  0: pw.FlexColumnWidth(2.2),
                  1: pw.FlexColumnWidth(1.6),
                  2: pw.FlexColumnWidth(1.4),
                  3: pw.FlexColumnWidth(1.6),
                },
                columnAlignments: const {
                  0: pw.Alignment.centerRight,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                },
                rows: travelers.map((t) {
                  final passportNumber = (t.passport.documentNumber ?? '').toString();
                  final fullName = (t.passport.fullName).toString();
                  final ticket = (t.ticketNumber ?? 'غير متوفر').toString();
                  final dob = _fmtDate(t.passport.dateOfBirth);
                  return <String>[fullName, ticket, dob, passportNumber];
                }).toList(growable: false),
                font: arabicFont,
                bold: arabicBoldFont,
                rtlColumns: true,
              ),
            ),

            pw.SizedBox(height: 18),

            // 5) Baggage (✅ columns reversed RTL)
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: _sectionTable(
                title: 'الأمتعة',
                header: const ['النوع', 'الوزن'],
                columnWidths: const {
                  0: pw.FlexColumnWidth(2.5),
                  1: pw.FlexColumnWidth(1.0),
                },
                columnAlignments: const {
                  0: pw.Alignment.centerRight,
                  1: pw.Alignment.center,
                },
                rows: widget.baggagesData.map((row) {
                  final type = (row['type'] ?? '').toString();
                  final weight = (row['Weight'] ?? row['weight'] ?? '').toString();
                  return [type, weight];
                }).toList(growable: false),
                font: arabicFont,
                bold: arabicBoldFont,
                rtlColumns: true,
              ),
            ),

            pw.SizedBox(height: 18),

            // 6) Pricing (✅ columns reversed RTL + total highlighted)
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: _sectionTable(
                title: 'التسعير',
                header: const ['النوع', 'السعر الأساسي', 'الضرائب', 'الإجمالي'],
                columnWidths: const {
                  0: pw.FlexColumnWidth(2.0),
                  1: pw.FlexColumnWidth(1.0),
                  2: pw.FlexColumnWidth(1.0),
                  3: pw.FlexColumnWidth(1.2),
                },
                columnAlignments: const {
                  0: pw.Alignment.centerRight,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                },
                rows: pricingRows,
                font: arabicFont,
                bold: arabicBoldFont,
                highlightedRows: {totalAllRowIndex},
                highlightedBg: _lightGrey,
                highlightedBold: true,
                rtlColumns: true,
              ),
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
      print('❌ Error in print_issuing_ar: $e');
      // ignore: avoid_print
      print(s);
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  // -------------------- PDF UI Helpers --------------------

  MapEntry<String, String> _kv(String k, String v) => MapEntry(k, v);

  pw.Widget _sectionHeader(
    String title, {
    required pw.Font bold,
    String? subtitle,
  }) {
    final hasSubtitle = subtitle != null && subtitle.trim().isNotEmpty;

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _navy,
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 12,
              font: bold,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (hasSubtitle) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              subtitle!,
              style: pw.TextStyle(
                fontSize: 10,
                font: bold,
                color: PdfColor.fromInt(0xFFD0D4E5),
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ],
        ],
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
    pw.Alignment align = pw.Alignment.centerRight,
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
        textDirection: pw.TextDirection.rtl,
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
          // value (left) | key (right)
          columnWidths: const {0: pw.FlexColumnWidth(), 1: pw.FixedColumnWidth(160)},
          children: rows.map((r) {
            return pw.TableRow(
              children: [
                _cell(r.value, bg: PdfColors.white, font: font, bold: bold, align: pw.Alignment.centerRight),
                _cell(r.key, bg: _lightGrey, font: font, bold: bold, isHeaderCell: true, align: pw.Alignment.centerRight),
              ],
            );
          }).toList(growable: false),
        ),
      ],
    );
  }

  Map<int, T>? _reverseIndexMap<T>(Map<int, T>? input, int count) {
    if (input == null) return null;
    final out = <int, T>{};
    for (int newIdx = 0; newIdx < count; newIdx++) {
      final oldIdx = count - 1 - newIdx;
      final val = input[oldIdx];
      if (val != null) out[newIdx] = val;
    }
    return out;
  }

  pw.Widget _sectionTable({
    required String title,
    String? subtitle,
    required List<String> header,
    required List<List<String>> rows,
    required pw.Font font,
    required pw.Font bold,
    Map<int, pw.TableColumnWidth>? columnWidths,
    Map<int, pw.Alignment>? columnAlignments,
    Set<int>? highlightedRows,
    PdfColor? highlightedBg,
    bool highlightedBold = false,

    // ✅ هذا هو المفتاح: يعكس الأعمدة فعلياً
    bool rtlColumns = false,
  }) {
    final colCount = header.length;

    final hdr = rtlColumns ? header.reversed.toList(growable: false) : header;

    final bodyRows = rtlColumns
        ? rows.map((r) => r.reversed.toList(growable: false)).toList(growable: false)
        : rows;

    final widths = rtlColumns ? _reverseIndexMap(columnWidths, colCount) : columnWidths;
    final aligns = rtlColumns ? _reverseIndexMap(columnAlignments, colCount) : columnAlignments;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(title, bold: bold, subtitle: subtitle),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          columnWidths: widths,
          children: [
            pw.TableRow(
              children: List.generate(hdr.length, (i) {
                final align = aligns?[i] ?? pw.Alignment.centerRight;
                return _cell(
                  hdr[i],
                  bg: _lightGrey,
                  font: font,
                  bold: bold,
                  isHeaderCell: true,
                  align: align,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                );
              }),
            ),
            ...bodyRows.asMap().entries.map((entry) {
              final rowIndex = entry.key;
              final r = entry.value;

              final isHighlighted = highlightedRows?.contains(rowIndex) ?? false;
              final bg = isHighlighted ? (highlightedBg ?? _lightGrey) : PdfColors.white;

              return pw.TableRow(
                children: List.generate(r.length, (i) {
                  final align = aligns?[i] ?? pw.Alignment.centerRight;
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
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('جارٍ تجهيز وطباعة التقرير...'),
            SizedBox(height: 16),
            SizedBox(height: 60, width: 60, child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ),
      ),
    );
  }
}
