import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:alzajeltravel/controller/passport/passports_forms_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/view/frame/passport/contact_information_form.dart';
import 'package:alzajeltravel/view/frame/passport/passport_form.dart';

class PassportsFormsPage extends StatefulWidget {
  final int adultsCounter;
  final int childrenCounter;
  final int infantsInLapCounter;

  const PassportsFormsPage({super.key, required this.adultsCounter, required this.childrenCounter, required this.infantsInLapCounter});

  @override
  State<PassportsFormsPage> createState() => _PassportsFormsPageState();
}

class _PassportsFormsPageState extends State<PassportsFormsPage> {
  final ScrollController _scrollController = ScrollController();



  // مفتاح لكل عنصر (مسافر) في القائمة
final Map<String, GlobalKey> _tileKeysByTag = {};
String? _lastAutoScrolledTag;

  /// نتأكد أن عدد الـ keys مساوي لعدد المسافرين
  // void _ensureTileKeysLength(int length) {
  //   if (_tileKeys.length != length) {
  //     _tileKeys
  //       ..clear()
  //       ..addAll(List.generate(length, (_) => GlobalKey()));
  //   }
  // }

void _ensureTileKeysForAll(List travelers) {
  for (final t in travelers) {
    _tileKeysByTag.putIfAbsent(t.tag, () => GlobalKey());
  }
}

void _scrollToTravelerTag(String tag) {
  final key = _tileKeysByTag[tag];
  final ctx = key?.currentContext;
  if (ctx == null) return;

  Scrollable.ensureVisible(
    ctx,
    alignment: 0.0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}


  /// التمرير حتى يظهر المسافر المحدد في أعلى الشاشة تقريبًا
  // void _scrollToTraveler(int index) {
  //   if (index < 0 || index >= _tileKeys.length) return;

  //   final key = _tileKeys[index];
  //   final context = key.currentContext;
  //   if (context == null) return;

  //   Scrollable.ensureVisible(
  //     context,
  //     alignment: 0.0, // 0.0 يعني أعلى الشاشة
  //     duration: const Duration(milliseconds: 300),
  //     curve: Curves.easeInOut,
  //   );
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

        

        // نضبط عدد الـ keys بحسب عدد المسافرين
        _ensureTileKeysForAll(formsController.travelers); // لضمان وجود keys لكل tags

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scaffoldBg = isDark ? cs.surface : const Color(0xFFFAF6F1);

        return PopScope(

          canPop: false, // نمنع الرجوع تلقائيًا ونقرر نحن بعد التأكيد
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            final ok = await AppFuns.confirmExit(
              title: "Exit".tr,
              message: "Are you sure you want to exit?".tr,
            );

            if (ok && context.mounted) {
              Navigator.of(context).pop(result);
              // أو فقط pop() إذا ما تحتاج result
            }
          },


          child: SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: scaffoldBg,
              appBar: AppBar(
                title: Text(
                  'Travelers data'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: AppConsts.xlg,
                  ),
                ),
                backgroundColor: AppConsts.primaryColor,
                foregroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: AppConsts.xlg,
                ),
                elevation: 0,
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    // _buildHeaderRow(cs, formsController),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Column(
                          spacing: 0,
                          children: [
                            // المسافرين + الـ Divider بينهم
for (int index = 0; index < travelers.length; index++) ...[
  // final t = travelers[index];

  Container(
    key: _tileKeysByTag[travelers[index].tag],
    child: PassportFormTile(
      tag: travelers[index].tag,
      index: index,
      travelerIndex: travelers[index].index,
      ageGroupLabel: formsController.ageGroupLabel(travelers[index].ageGroup),
      lang: formsController.lang,

      // مهم: نجيب isExpanded حسب tag وليس حسب index المعروض
      isExpanded: formsController.isExpandedByTag(travelers[index].tag),

      minDob: formsController.minDob(travelers[index].ageGroup),
      maxDob: formsController.maxDob(travelers[index].ageGroup),

      onExpansionChanged: (expanded) {
        formsController.onTileExpansionChangedByTag(travelers[index].tag, expanded);
        if (expanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToTravelerTag(travelers[index].tag);
          });
        }
      },

      onNext: (index < travelers.length - 1)
          ? () {
              final nextTag = formsController.openNextByTag(travelers[index].tag);
              if (nextTag != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToTravelerTag(nextTag);
                });
              }
            }
          : null,
      onSave: () {
        formsController.collapseAll();
      },
    ),
  ),
],
            
                            // فورم بيانات الاتصال — مخفي بصريًا لكنه يبقى في شجرة الـ widgets
                            // حتى يظل الكنترولر وformKey مهيّأَين ويُحفظا مع باقي البيانات
                            Offstage(
                              offstage: true,
                              child: ContactInformationForm(controller: formsController),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildBottomBar(context, cs, formsController),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ColorScheme cs,
    PassportsFormsController formsController,
  ) {
    final priceText = AppFuns.priceWithCoin(
      formsController.totalFlight,
      formsController.currency,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppConsts.primaryColor,
            AppConsts.primaryColor.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppConsts.primaryColor.withValues(alpha: 0.25),
            offset: const Offset(0, -4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total flight".tr,
                  style: TextStyle(
                    fontSize: AppConsts.sm,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  priceText,
                  style: const TextStyle(
                    color: AppConsts.secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppConsts.xxlg,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              context.loaderOverlay.show(
                progress: "Passenger data is being saved".tr,
              );
              await formsController.saveAll();
              if (context.mounted) context.loaderOverlay.hide();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConsts.secondaryColor,
              foregroundColor: AppConsts.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: AppConsts.normal,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text("Save and continue".tr),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(ColorScheme cs, PassportsFormsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: (Get.isDarkMode) ? cs.scrim : Colors.transparent,
        border: Border(bottom: BorderSide(color: cs.outline, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Travelers data".tr,
                style: const TextStyle(fontSize: AppConsts.xlg, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // IconButton(
          //   tooltip: 'Collapse all'.tr,
          //   onPressed: controller.collapseAll,
          //   icon: SvgPicture.asset(AppConsts.collapse, height: 20, width: 20, color: (Get.isDarkMode) ? cs.secondary : cs.primary),
          // ),
          // IconButton(
          //   tooltip: 'Expand all'.tr,
          //   onPressed: controller.expandAll,
          //   icon: SvgPicture.asset(AppConsts.expand, height: 20, width: 20, color: (Get.isDarkMode) ? cs.secondary : cs.primary),
          // ),
        ],
      ),
    );
  }
}
