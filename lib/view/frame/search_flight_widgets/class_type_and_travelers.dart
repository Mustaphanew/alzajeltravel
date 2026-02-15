// lib/view/frame/search_flight_widgets/class_type_and_travelers.dart

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/controller/class_type_controller.dart';
import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/model/class_type_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class ClassTypeAndTravelers extends StatefulWidget {

  final bool isCanbin;

  const ClassTypeAndTravelers({super.key, required this.isCanbin});

  @override
  State<ClassTypeAndTravelers> createState() => _ClassTypeAndTravelersState();
}

class _ClassTypeAndTravelersState extends State<ClassTypeAndTravelers> {
  final ClassTypeController classTypeController =
    Get.isRegistered<ClassTypeController>()
        ? Get.find<ClassTypeController>()
        : Get.put(ClassTypeController(), permanent: true);

  final TravelersController travelersController =
    Get.isRegistered<TravelersController>()
        ? Get.find<TravelersController>()
        : Get.put(TravelersController(), permanent: true);

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.25,
      maxChildSize: 0.65,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Material(
            color: cs.surface,
            child: Column(
              children: [
                // محتوى قابل للتمرير
                Expanded(
                  child: CupertinoScrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(100),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),

                            // Handle
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: cs.outlineVariant,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Header
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(CupertinoIcons.back, color: cs.onSurface),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                Expanded(
                                  child: Text(
                                    "Class Type and Travelers".tr,
                                    style: TextStyle(
                                      fontSize: AppConsts.xlg,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppConsts.font,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Class type dropdown
                            GetBuilder<ClassTypeController>(
                              builder: (ctrl) {
                                if(widget.isCanbin == true){
                                  // return ClassTypeDropdown(controller: ctrl);
                                  return ClassTypeButtons(controller: ctrl);
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            const SizedBox(height: 12),

                            // Travelers counters
                            GetBuilder<TravelersController>(
                              builder: (ctrl) {
                                if(widget.isCanbin == true){
                                  return const SizedBox.shrink();
                                }
                                  return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TravelerListTile(
                                      type: TravelerType.adults,
                                      controller: ctrl,
                                      title: "Adults".tr,
                                      body: "Greater than or equal to 12 years".tr,
                                      counter: ctrl.adultsCounter,
                                      icon: Icon(FontAwesomeIcons.solidUser, size: 22, color: Colors.blue[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    TravelerListTile(
                                      type: TravelerType.children,
                                      controller: ctrl,
                                      title: "Children".tr,
                                      body: "between 2 and 11 years".tr,
                                      counter: ctrl.childrenCounter,
                                      icon: Icon(FontAwesomeIcons.child, size: 22, color: Colors.green[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    TravelerListTile(
                                      type: TravelerType.infantsLap,
                                      controller: ctrl,
                                      title: "Infants in Lap".tr,
                                      body: "Less than 2 years old".tr,
                                      counter: ctrl.infantsInLapCounter,
                                      icon: Icon(FontAwesomeIcons.babyCarriage, size: 22, color: Colors.red[600]),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // زر الحفظ (ثابت تحت)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: SizedBox(
                    height: 52,
                    width: AppConsts.sizeContext(context).width * 0.9,
                    child: GetBuilder<ClassTypeController>(
                      builder: (ctrl) {
                        return ElevatedButton(
                          onPressed: (ctrl.selectedClassType == null)
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                },
                          child: Text("Save".tr),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum TravelerType { adults, children, infantsSeat, infantsLap }

class TravelerListTile extends StatelessWidget {
  final TravelerType type;
  final String title;
  final String body;
  final TravelersController controller;
  final int counter;
  final Widget icon;

  const TravelerListTile({
    super.key,
    required this.type,
    required this.controller,
    required this.title,
    required this.body,
    required this.counter,
    required this.icon,
  });

  void _change(int delta) {
    switch (type) {
      case TravelerType.adults:
        controller.changeAdultsCounter(delta);
        break;
      case TravelerType.children:
        controller.changeChildrenCounter(delta);
        break;
      case TravelerType.infantsSeat:
        controller.changeInfantsInSeatCounter(delta);
        break;
      case TravelerType.infantsLap:
        controller.changeInfantsInLapCounter(delta);
        break;
    }
  }

  bool get canMinus {
    switch (type) {
      case TravelerType.adults:
        return counter > 1;
      case TravelerType.children:
      case TravelerType.infantsSeat:
      case TravelerType.infantsLap:
        return counter > 0;
    }
  }

  bool get canPlus {
    final totalOk = controller.travelersCounter() < controller.maxTravelersCounter;
    if (!totalOk) return false;

    switch (type) {
      case TravelerType.adults:
        return true;
      case TravelerType.children:
        return counter < controller.maxChildrenCounter();
      case TravelerType.infantsSeat:
        return counter < controller.maxInfantsInSeatCounter();
      case TravelerType.infantsLap:
        return counter < controller.maxInfantsInLapCounter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: icon,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppConsts.lg,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConsts.font,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: AppConsts.normal,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppConsts.font,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.minus_circle),
                onPressed: canMinus ? () => _change(-1) : null,
              ),
              Text(
                "$counter",
                style: TextStyle(
                  fontFamily: AppConsts.font,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.plus_circle),
                onPressed: canPlus ? () => _change(1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClassTypeDropdown extends StatefulWidget {
  final ClassTypeController controller;
  const ClassTypeDropdown({super.key, required this.controller});

  @override
  State<ClassTypeDropdown> createState() => _ClassTypeDropdownState();
}

class _ClassTypeDropdownState extends State<ClassTypeDropdown> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = AppVars.lang ?? 'en';

    return DropdownSearch<ClassTypeModel>(
      // تحميل العناصر
      items: (String? filter, LoadProps? infiniteScrollProps) async {
        return widget.controller.getData(filter);
      },

      // فلترة محلية
      filterFn: (item, filter) {
        final q = filter.toLowerCase().trim();
        final en = (item.name['en'] ?? '').toString().toLowerCase();
        final ar = (item.name['ar'] ?? '').toString().toLowerCase();
        return en.contains(q) || ar.contains(q);
      },

      itemAsString: (item) => (item.name[lang] ?? item.name['en'] ?? '').toString(),

      compareFn: (a, b) => a.id == b.id,

      selectedItem: widget.controller.selectedClassType,

      onChanged: (value) => widget.controller.changeSelectedClassType(value),

      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: " ${'Class Type'.tr} ",
          hintText: "Select Class Type".tr,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(FontAwesomeIcons.chair, size: 20, color: Colors.green[600]),
        ),
      ),

      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        cacheItems: true,
        disableFilter: false,
        searchDelay: const Duration(milliseconds: 250),

        title: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 8, top: 16, bottom: 8),
          child: Text("Search".tr, style: TextStyle(color: cs.onSurface)),
        ),

        searchFieldProps: TextFieldProps(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: "${'Search'.tr} ...",
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),

        itemBuilder: (context, item, isSelected, index) => ListTile(
          title: Text((item.name[lang] ?? item.name['en'] ?? '').toString()),
          selected: isSelected,
        ),

        constraints: const BoxConstraints(maxHeight: 900),
        listViewProps: const ListViewProps(shrinkWrap: true),
      ),

      suffixProps: const DropdownSuffixProps(
        clearButtonProps: ClearButtonProps(isVisible: false),
      ),
    );
  }
}

// _________________________________


class ClassTypeButtons extends StatefulWidget {
  final ClassTypeController controller;
  const ClassTypeButtons({super.key, required this.controller});

  @override
  State<ClassTypeButtons> createState() => _ClassTypeButtonsState();
}

class _ClassTypeButtonsState extends State<ClassTypeButtons> {
  @override
  void initState() {
    super.initState();

    // حمّل البيانات مرة واحدة
    if (widget.controller.classTypes.isEmpty) {
      widget.controller.loadClassTypes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = Get.locale?.languageCode ?? 'en';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          "Class Type".tr,
          style: TextStyle(
            fontSize: AppConsts.lg,
            fontWeight: FontWeight.w600,
            fontFamily: AppConsts.font,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),

        GetBuilder<ClassTypeController>(
          builder: (ctrl) {
            if (ctrl.classTypes.isEmpty) {
              return const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.classTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3.2,
              ),
              itemBuilder: (context, index) {
                final item = ctrl.classTypes[index];
                final isSelected = ctrl.selectedClassType?.id == item.id;

                final label = (item.name[lang] ?? item.name['en'] ?? '').toString();

                return isSelected
                    ? ElevatedButton(
                        onPressed: () async {
                          ctrl.changeSelectedClassType(item);
                          Get.back();
                        },
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: AppConsts.font,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () async {
                          ctrl.changeSelectedClassType(item);
                          Get.back();
                        },
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: AppConsts.font,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
              },
            );
          },
        ),
      ],
    );
  }
}
