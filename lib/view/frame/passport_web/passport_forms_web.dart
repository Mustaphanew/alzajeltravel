// passport_forms_web.dart
import 'dart:math' as math;

import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets/date_dropdown_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:alzajeltravel/controller/passport/passports_forms_controller.dart';
import 'package:alzajeltravel/controller/passport/passport_controller.dart';
import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/widgets/country_picker.dart';
import 'package:alzajeltravel/view/frame/passport/contact_information_form.dart';

// review
import 'package:alzajeltravel/view/frame/travelers_review/travelers_review_page.dart';
import 'package:alzajeltravel/model/passport/traveler_review/traveler_review_model.dart';
import 'package:alzajeltravel/model/passport/passport_model.dart';
import 'package:alzajeltravel/utils/enums.dart';

import 'passport_form_web.dart';
import 'package:showcaseview/showcaseview.dart';

// ✅ two_dimensional_scrollables
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class PassportsFormsWebPage extends StatefulWidget {
  final int adultsCounter;
  final int childrenCounter;
  final int infantsInLapCounter;

  const PassportsFormsWebPage({
    super.key,
    required this.adultsCounter,
    required this.childrenCounter,
    required this.infantsInLapCounter,
  });

  @override
  State<PassportsFormsWebPage> createState() => _PassportsFormsWebPageState();
}

class _PassportsFormsWebPageState extends State<PassportsFormsWebPage> {
  // ✅ Controllers (TableView يستخدمها للتمرير)
  final _vCtrl = ScrollController();
  final _hCtrl = ScrollController();

  final _webFormKey = GlobalKey<FormState>();

  // ✅ widths
  static const double wScan = 40;
  static const double wGiven = 180;
  static const double wSur = 120;
  static const double wDob = 320;
  static const double wSex = 100;
  static const double wPass = 130;
  static const double wNat = 100;
  static const double wIss = 100;
  static const double wExp = 320;

  // ✅ spacing/border
  static const double _hMargin = 8;
  static const double _colSpace = 8;
  static const double _borderW = 1;

  // ✅ header heights
  static const double _groupHeaderH = 40;
  static const double _columnsHeaderH = 50;

  bool showTextBox = true;

  final GlobalKey _scanShowcaseKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    ShowcaseView.register(
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.insideRight,
        gapBetweenContentAndAction: 8,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        try {
          ShowcaseView.get().startShowCase([_scanShowcaseKey]);
        } catch (_) {}
      });
    });
  }

  @override
  void dispose() {
    _vCtrl.dispose();
    _hCtrl.dispose();
    ShowcaseView.get().unregister();
    super.dispose();
  }

  // --- Helpers ---
  Widget _pc(String tag, Widget Function(PassportController pc) b) {
    return GetBuilder<PassportController>(tag: tag, builder: b);
  }

  List<double> get _colWidths => const [
        wScan, // 0 scan (pinned)
        wGiven, // 1
        wSur, // 2
        wDob, // 3
        wSex, // 4
        wPass, // 5
        wNat, // 6
        wIss, // 7
        wExp, // 8
      ];

  double get _dataRowH => showTextBox ? 70 : 35;

  BorderSide _side(ColorScheme cs) => BorderSide(color: cs.outline, width: _borderW);

  // ✅ border grid (منع تكرار السماكة)
  Border _gridBorder({
    required ColorScheme cs,
    required bool top,
    required bool left,
    required bool right,
    required bool bottom,
  }) {
    final s = _side(cs);
    return Border(
      top: top ? s : BorderSide.none,
      left: left ? s : BorderSide.none,
      right: right ? s : BorderSide.none,
      bottom: bottom ? s : BorderSide.none,
    );
  }

  EdgeInsetsGeometry _cellPadding(int col) {
    final half = _colSpace / 2;
    if (col == 0) {
      return EdgeInsetsDirectional.only(start: _hMargin, end: half);
    }
    if (col == _colWidths.length - 1) {
      return EdgeInsetsDirectional.only(start: half, end: _hMargin);
    }
    return EdgeInsetsDirectional.symmetric(horizontal: half);
  }

  double _innerWidth(int col) {
    final w = _colWidths[col];
    final pad = _cellPadding(col);
    return math.max(0, w - pad.horizontal);
  }

  Widget _cellBox({
    required ColorScheme cs,
    required int row,
    required int col,
    required Widget child,
    Color? bg,
    Border? borderOverride,
    AlignmentDirectional alignment = AlignmentDirectional.centerStart,
    EdgeInsets? paddingOverride,
  }) {
    final border = borderOverride ??
        _gridBorder(
          cs: cs,
          top: row == 0,
          left: col == 0,
          right: true,
          bottom: true,
        );

    return Container(
      alignment: alignment,
      padding: paddingOverride ?? _cellPadding(col),
      decoration: BoxDecoration(
        color: bg,
        border: border,
      ),
      child: child,
    );
  }

  // --------- Header Widgets ----------
  Widget _groupHeaderText(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _scanHeaderCell() {
    return Showcase(
      key: _scanShowcaseKey,
      title: 'Scan passport'.tr,
      titlePadding: const EdgeInsets.only(bottom: 12),
      description: 'You can fill traveler data by scanning the passport'.tr,
      descriptionPadding: const EdgeInsets.only(bottom: 6),
      titleAlignment: AlignmentDirectional.centerStart,
      tooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: "",
          leadIcon: ActionButtonIcon(
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
          ),
          padding: const EdgeInsets.all(4),
          textStyle: const TextStyle(color: Colors.white),
          onTap: ShowcaseView.get().dismiss,
        ),
      ],
      child: Tooltip(
        message: "Scan passport".tr,
        child: Center(
          child: GestureDetector(
            onTap: () => ShowcaseView.get().startShowCase([_scanShowcaseKey]),
            child: const Icon(Icons.camera_alt, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _columnHeaderCell(ColorScheme cs, int col) {
    const titleStyle = TextStyle(fontWeight: FontWeight.bold);

    Widget title(String t) => Text(t, overflow: TextOverflow.ellipsis, style: titleStyle);

    Widget help(String t) => Text(
          t,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        );

    switch (col) {
      case 0:
        return _scanHeaderCell();
      case 1:
        return title('Given names'.tr);
      case 2:
        return title('SURNAMES'.tr);
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            title('Date of birth'.tr),
            help('You must specify the first year, then the month, then the day'.tr),
          ],
        );
      case 4:
        return title('Sex'.tr);
      case 5:
        return title('DOCUMENT NUMBER'.tr);
      case 6:
        return title('NATIONALITY'.tr);
      case 7:
        return title('ISSUING COUNTRY'.tr);
      case 8:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            title('DATE OF EXPIRY'.tr),
            help('You must specify the first year, then the month, then the day'.tr),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // --------- Body Cells ----------
  Widget _bodyCell(
    PassportsFormsController formsController,
    dynamic traveler,
    int visualIndex,
    int col,
  ) {
    final tag = traveler.tag as String;
    final travelerIndex = traveler.index as int;
    final ageGroup = traveler.ageGroup;

    final onlyEnAlphaNumSpace = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z ]")),
    ];

    switch (col) {
      case 0:
        return SizedBox(
          width: _innerWidth(0),
          child: IconButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () {},
          ),
        );

      case 1:
        return _pc(tag, (pc) {
          final ageLabel = formsController.ageGroupLabel(ageGroup);
          if (showTextBox) {
            return WebTableTextField(
              width: _innerWidth(1),
              controller: pc.givenNamesCtr,
              formatters: onlyEnAlphaNumSpace,
              showLabel: true,
              label: 'Given names'.tr + ' (${'traveler'.tr} $travelerIndex: $ageLabel)',
            );
          }
          return Text(pc.givenNamesCtr.text, overflow: TextOverflow.ellipsis);
        });

      case 2:
        return _pc(tag, (pc) {
          if (showTextBox) {
            return WebTableTextField(
              width: _innerWidth(2),
              controller: pc.surnamesCtr,
              formatters: onlyEnAlphaNumSpace,
              label: 'SURNAMES'.tr,
            );
          }
          return Text(pc.surnamesCtr.text, overflow: TextOverflow.ellipsis);
        });

      case 3:
        return _pc(tag, (pc) {
          if (showTextBox) {
            return SizedBox(
              width: _innerWidth(3),
              child: DateDropdownRow(
                title: const SizedBox.shrink(),
                initialDate: pc.model.dateOfBirth,
                minDate: formsController.minDob(ageGroup),
                maxDate: formsController.maxDob(ageGroup),
                onDateChanged: pc.setDateOfBirth,
                validator: (date) {
                  if (date == null) return 'Please select a valid date'.tr;
                  if (date.isAfter(DateTime.now())) return 'Date of birth cannot be in the future'.tr;
                  return null;
                },
              ),
            );
          }
          return Text(AppFuns.formatFullDate(pc.model.dateOfBirth));
        });

      case 4:
        return _pc(tag, (pc) {
          if (showTextBox) {
            return WebTableSexField(width: _innerWidth(4), controller: pc);
          }
          return Text("${pc.model.sex?.label ?? ''}", overflow: TextOverflow.ellipsis);
        });

      case 5:
        return _pc(tag, (pc) {
          if (showTextBox) {
            return WebTableTextField(
              width: _innerWidth(5),
              controller: pc.documentNumberCtr,
              formatters: [FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9]"))],
              caps: TextCapitalization.characters,
              label: 'DOCUMENT NUMBER'.tr,
            );
          }
          return Text("${pc.model.documentNumber ?? ''}", overflow: TextOverflow.ellipsis);
        });

      case 6:
        return _pc(tag, (pc) {
          final full = countryDisplayName(pc.model.nationality, formsController.lang);
          if (showTextBox) {
            return WebTableCountryField(
              width: _innerWidth(6),
              label: 'NATIONALITY'.tr,
              valueShort: full,
              tooltip: full.isEmpty ? null : full,
              onTap: () async {
                final CountryModel? picked = await Get.to<CountryModel>(() => const CountryPicker());
                if (picked != null) {
                  pc.setNationality(picked);
                  try {
                    pc.update();
                  } catch (_) {}
                }
              },
            );
          }
          return Text("${pc.model.nationality?.name[AppVars.lang] ?? ''}", overflow: TextOverflow.ellipsis);
        });

      case 7:
        return _pc(tag, (pc) {
          final full = countryDisplayName(pc.model.issuingCountry, formsController.lang);
          if (showTextBox) {
            return WebTableCountryField(
              width: _innerWidth(7),
              label: 'ISSUING COUNTRY'.tr,
              valueShort: full,
              tooltip: full.isEmpty ? null : full,
              onTap: () async {
                final CountryModel? picked = await Get.to<CountryModel>(() => const CountryPicker());
                if (picked != null) {
                  pc.setIssuingCountry(picked);
                  try {
                    pc.update();
                  } catch (_) {}
                }
              },
            );
          }
          return Text("${pc.model.issuingCountry?.name[AppVars.lang] ?? ''}", overflow: TextOverflow.ellipsis);
        });

      case 8:
        return _pc(tag, (pc) {
          final min = formsController.lastDateInSearch.add(const Duration(days: 180));
          final max = DateTime(formsController.lastDateInSearch.year + 12, 12, 31);

          if (showTextBox) {
            return SizedBox(
              width: _innerWidth(8),
              child: DateDropdownRow(
                title: const SizedBox.shrink(),
                initialDate: pc.model.dateOfExpiry,
                minDate: min,
                maxDate: max,
                onDateChanged: pc.setDateOfExpiry,
                validator: (date) => date == null ? 'Please select a valid date'.tr : null,
              ),
            );
          }
          return Text(AppFuns.formatFullDate(pc.model.dateOfExpiry));
        });

      default:
        return const SizedBox.shrink();
    }
  }

  // ✅ Validate ALL travelers (حتى غير الظاهرين بسبب lazy build)
  bool _validateAllTravelers(PassportsFormsController formsController) {
    final travelers = formsController.sortedTravelers;

    for (int i = 0; i < travelers.length; i++) {
      final t = travelers[i];
      final tag = t.tag as String;

      PassportController pc;
      try {
        pc = Get.find<PassportController>(tag: tag);
      } catch (_) {
        continue;
      }

      String? err;
      if (pc.givenNamesCtr.text.trim().isEmpty) err = 'Please enter given names'.tr;
      else if (pc.surnamesCtr.text.trim().isEmpty) err = 'Please enter surnames'.tr;
      else if (pc.model.dateOfBirth == null) err = 'Please select date of birth'.tr;
      else if (pc.model.dateOfBirth!.isAfter(DateTime.now())) err = 'Date of birth cannot be in the future'.tr;
      else if (pc.model.sex == null) err = 'Please select sex'.tr;
      else if (pc.documentNumberCtr.text.trim().isEmpty) err = 'Please enter document number'.tr;
      else if (pc.model.nationality == null) err = 'Please select nationality'.tr;
      else if (pc.model.issuingCountry == null) err = 'Please select issuing country'.tr;
      else if (pc.model.dateOfExpiry == null) err = 'Please select expiry date'.tr;
      else {
        final min = formsController.lastDateInSearch.add(const Duration(days: 180));
        if (pc.model.dateOfExpiry!.isBefore(min)) {
          err = 'Passport expiry must be at least 6 months after travel date'.tr;
        }
      }

      if (err != null) {
        // حاول تسكرول لمكانه (حساب تقريبي ممتاز لأن الارتفاعات Fixed)
        final offsetY = _groupHeaderH + _columnsHeaderH + (i * _dataRowH);
        _vCtrl.animateTo(
          offsetY,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );

        Get.snackbar(
          'Validation'.tr,
          err,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _saveWeb(PassportsFormsController formsController) async {
    AppFuns.hideKeyboard();

    // ✅ validate الظاهر
    final visibleOk = _webFormKey.currentState?.validate() ?? true;

    // ✅ validate الكل (مهم بسبب lazy)
    final allOk = _validateAllTravelers(formsController);

    if (!visibleOk || !allOk) return;

    // validate بيانات الاتصال
    if (!formsController.validateContactForm()) return;

    final passports = formsController.collectModels();

    context.loaderOverlay.show();
    final bookingResponse =
        await formsController.createBookingServer(passports, formsController.contactModel);
    if (context.mounted) context.loaderOverlay.hide();

    if (bookingResponse == null) return;

    final insertId = bookingResponse['insert_id'];
    if (insertId == null) {
      Get.snackbar(
        'Error'.tr,
        'Booking request failed, please try again.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final List<dynamic> passengersJson = (bookingResponse['passengers'] as List?) ?? [];
    final List<TravelerReviewModel> travelersReviewList = [];

    double _parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    AgeGroup _ageGroupFromAny(dynamic v) {
      final s = (v ?? '').toString().trim().toLowerCase();
      if (s == 'inf' || s == 'infant') return AgeGroup.infant;
      if (s == 'cnn' || s == 'chd' || s == 'child') return AgeGroup.child;
      if (s == 'adt' || s == 'adult') return AgeGroup.adult;
      return AgeGroup.adult;
    }

    for (int index = 0; index < passengersJson.length; index++) {
      final Map<String, dynamic>? passengerJson =
          (passengersJson[index] is Map<String, dynamic>) ? passengersJson[index] as Map<String, dynamic> : null;

      final baseFare = _parseDouble(passengerJson?['Base_Amount']);
      final taxTotal = _parseDouble(passengerJson?['Tax_Total']);

      final PassportModel travelerPassport = PassportModel.fromJson({
        "documentNumber": passengerJson?['passport_no'],
        "givenNames": passengerJson?['first_name'],
        "surnames": passengerJson?['last_name'],
        "dateOfBirth": passengerJson?['dob'],
        "sex": passengerJson?['gender'],
        "nationality": passengerJson?['nationality'],
        "issueCountry": passengerJson?['issue_country'],
        "dateOfExpiry": passengerJson?['expiry_date'],
      });

      travelersReviewList.add(
        TravelerReviewModel(
          passport: travelerPassport,
          baseFare: baseFare,
          taxTotal: taxTotal,
          seat: null,
          ageGroup: _ageGroupFromAny(passengerJson?['pax_type']),
        ),
      );
    }

    Get.to(() => TravelersReviewPage(
          travelers: travelersReviewList,
          insertId: insertId,
          contact: formsController.contactModel,
        ));
  }

  Widget _buildTwoDimTable(
    ColorScheme cs,
    PassportsFormsController formsController,
    List<dynamic> travelers,
  ) {
    final headerBg0 = cs.secondaryContainer; // group header
    final headerBg1 = cs.surfaceContainerHighest; // columns header

    const int columnCount = 9;
    final int rowCount = travelers.length + 2; // row0 group, row1 columns

    // ✅ pinned
    const int pinnedRowCount = 2;
    const int pinnedColumnCount = 1;

    // ✅ IMPORTANT:
    // لا يمكن merge عبر pinned/unpinned
    // traveler header سيكون merged من col 1 إلى col 4 (span=4)
    const int travelerStart = pinnedColumnCount; // 1
    const int travelerSpan = 4; // 1..4
    const int passportStart = 5;
    const int passportSpan = 4; // 5..8

    // --- Merged cells (Row 0) ---
    // خلية للعمود pinned (scan) منفصلة (لا دمج)
    final scanGroupCell = TableViewCell(
      child: _cellBox(
        cs: cs,
        row: 0,
        col: 0,
        bg: headerBg0,
        borderOverride: _gridBorder(
          cs: cs,
          top: true,
          left: true,
          right: true, // فاصل pinned/unpinned
          bottom: true,
        ),
        alignment: AlignmentDirectional.center,
        child: const SizedBox.shrink(),
      ),
    );

    final travelerHeaderCell = TableViewCell(
      columnMergeStart: travelerStart,
      columnMergeSpan: travelerSpan,
      child: _cellBox(
        cs: cs,
        row: 0,
        col: travelerStart,
        bg: headerBg0,
        // لا نرسم left هنا (الحد موجود من العمود 0 right)
        borderOverride: _gridBorder(
          cs: cs,
          top: true,
          left: false,
          right: true, // فاصل قبل passport
          bottom: true,
        ),
        child: _groupHeaderText('Traveler data'.tr),
      ),
    );

    final passportHeaderCell = TableViewCell(
      columnMergeStart: passportStart,
      columnMergeSpan: passportSpan,
      child: _cellBox(
        cs: cs,
        row: 0,
        col: passportStart,
        bg: headerBg0,
        borderOverride: _gridBorder(
          cs: cs,
          top: true,
          left: false, // الفاصل مرسوم من traveler right
          right: true,
          bottom: true,
        ),
        child: _groupHeaderText('Passport data'.tr),
      ),
    );

    TableSpan _buildRowSpan(int index) {
      if (index == 0) return const TableSpan(extent: FixedTableSpanExtent(_groupHeaderH));
      if (index == 1) return const TableSpan(extent: FixedTableSpanExtent(_columnsHeaderH));
      return TableSpan(extent: FixedTableSpanExtent(_dataRowH));
    }

    TableSpan _buildColumnSpan(int index) {
      // ✅ آخر عمود يتمدد لو المساحة أكبر
      if (index == 8) {
        return const TableSpan(
          extent: MaxTableSpanExtent(
            FixedTableSpanExtent(wExp),
            RemainingTableSpanExtent(),
          ),
        );
      }
      return TableSpan(extent: FixedTableSpanExtent(_colWidths[index]));
    }

    TableViewCell _buildCell(BuildContext context, TableVicinity v) {
      final r = v.row;
      final c = v.column;

      // ===== Row 0: Group header (merged) =====
      if (r == 0) {
        if (c == 0) return scanGroupCell;
        if (c >= travelerStart && c <= (travelerStart + travelerSpan - 1)) return travelerHeaderCell;
        if (c >= passportStart && c <= (passportStart + passportSpan - 1)) return passportHeaderCell;
      }

      // ===== Row 1: Column headers (pinned) =====
      if (r == 1) {
        return TableViewCell(
          child: _cellBox(
            cs: cs,
            row: r,
            col: c,
            bg: headerBg1,
            child: SizedBox(
              width: _innerWidth(c),
              child: _columnHeaderCell(cs, c),
            ),
          ),
        );
      }

      // ===== Rows 2..: Data =====
      final visualIndex = r - 2;
      if (visualIndex < 0 || visualIndex >= travelers.length) {
        return const TableViewCell(child: SizedBox.shrink());
      }

      final traveler = travelers[visualIndex];

      return TableViewCell(
        child: _cellBox(
          cs: cs,
          row: r,
          col: c,
          child: _bodyCell(formsController, traveler, visualIndex, c),
        ),
      );
    }

    // ✅ cacheExtent “يغطي كل الجدول” = تعطيل lazy عمليًا
    final totalH = _groupHeaderH + _columnsHeaderH + (travelers.length * _dataRowH);
    final totalW = _colWidths.fold<double>(0.0, (a, b) => a + b) + (2 * _hMargin);
    final forcedCacheExtent = math.max(totalH, totalW) + 1000; // هامش أمان

    return Form(
      key: _webFormKey,
      child: CupertinoScrollbar(
        controller: _vCtrl,
        thumbVisibility: true,
        notificationPredicate: (n) => n.metrics.axis == Axis.vertical,
        child: CupertinoScrollbar(
          controller: _hCtrl,
          thumbVisibility: true,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
          child: TableView.builder(
            columnCount: columnCount,
            rowCount: rowCount,
            cacheExtent: forcedCacheExtent,
            pinnedRowCount: pinnedRowCount,
            pinnedColumnCount: pinnedColumnCount,
            diagonalDragBehavior: DiagonalDragBehavior.free,
            verticalDetails: ScrollableDetails.vertical(
              controller: _vCtrl,
            ),
            horizontalDetails: ScrollableDetails.horizontal(
              controller: _hCtrl,
              reverse: true,
            ),
            rowBuilder: _buildRowSpan,
            columnBuilder: _buildColumnSpan,
            cellBuilder: _buildCell,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PassportsFormsController>(
      init: PassportsFormsController(
        adultsCounter: widget.adultsCounter,
        childrenCounter: widget.childrenCounter,
        infantsInLapCounter: widget.infantsInLapCounter,
      ),
      builder: (formsController) {
        final cs = Theme.of(context).colorScheme;
        final travelers = formsController.sortedTravelers;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            final ok = await AppFuns.confirmExit(
              title: "Exit".tr,
              message: "Are you sure you want to exit?".tr,
            );

            if (ok && context.mounted) {
              Navigator.of(context).pop(result);
            }
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Travelers data'.tr),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      showTextBox = !showTextBox;
                      formsController.update();
                    },
                    child: Text(showTextBox ? 'Hide input fields'.tr : 'Show input fields'.tr),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: _buildTwoDimTable(cs, formsController, travelers),
                  ),

                  // ✅ خارج الجدول (مبني مثل ما كان عندك)
                  Opacity(
                    opacity: 0,
                    child: SizedBox(
                      height: 10,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ContactInformationForm(controller: formsController),
                      ),
                    ),
                  ),

                  // Bottom bar ثابت
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Total flight".tr),
                              Text(
                                AppFuns.priceWithCoin(formsController.totalFlight, formsController.currency),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _saveWeb(formsController),
                          child: Text("Save and continue".tr),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
