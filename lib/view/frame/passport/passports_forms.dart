import 'package:alzajeltravel/controller/flight/flight_detail_controller.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final List<GlobalKey> _tileKeys = [];

  /// نتأكد أن عدد الـ keys مساوي لعدد المسافرين
  void _ensureTileKeysLength(int length) {
    if (_tileKeys.length != length) {
      _tileKeys
        ..clear()
        ..addAll(List.generate(length, (_) => GlobalKey()));
    }
  }

  /// التمرير حتى يظهر المسافر المحدد في أعلى الشاشة تقريبًا
  void _scrollToTraveler(int index) {
    if (index < 0 || index >= _tileKeys.length) return;

    final key = _tileKeys[index];
    final context = key.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      alignment: 0.0, // 0.0 يعني أعلى الشاشة
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

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
        final travelers = formsController.travelers;

        // نضبط عدد الـ keys بحسب عدد المسافرين
        _ensureTileKeysLength(travelers.length);

        return Scaffold(
          appBar: AppBar(title: Text('Passport forms'.tr)),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeaderRow(cs, formsController),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      children: [
                        // المسافرين + الـ Divider بينهم
                        for (int index = 0; index < travelers.length; index++) ...[
                          if (index > 0) const Divider(),
                          Container(
                            key: _tileKeys[index],
                            child: PassportFormTile(
                              tag: travelers[index].tag,
                              travelerIndex: travelers[index].index,
                              ageGroupLabel: formsController.ageGroupLabel(travelers[index].ageGroup),
                              lang: formsController.lang,
                              isExpanded: formsController.expandedFlags[index],
                              minDob: formsController.minDob(travelers[index].ageGroup),
                              maxDob: formsController.maxDob(travelers[index].ageGroup),
                              onExpansionChanged: (expanded) {
                                formsController.onTileExpansionChanged(index, expanded);
                                if (expanded) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _scrollToTraveler(index);
                                  });
                                }
                              },
                              onNext: (index < travelers.length - 1)
                                  ? () {
                                      formsController.goToNextTraveler(index);
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _scrollToTraveler(index + 1);
                                      });
                                    }
                                  : null,
                            ),
                          ),
                        ],

                        const Divider(),

                        // 👉 فورم بيانات الاتصال في النهاية
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: ContactInformationForm(controller: formsController),
                        ), 
                        SizedBox(height: 36),
                      ], 
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(color: cs.surfaceContainer),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Total flight".tr),
                            Text(AppFuns.priceWithCoin(formsController.totalFlight, formsController.currency), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async { 
                          context.loaderOverlay.show();
                          await formsController.saveAll();
                          if(context.mounted) context.loaderOverlay.hide();
                        },
                        child: Text("Save and continue".tr),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                "Travelers'".tr,
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
