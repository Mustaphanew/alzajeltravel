import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/class_type_controller.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/model/class_type_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class ClassTypeAndTravelers extends StatefulWidget {
  const ClassTypeAndTravelers({super.key});

  @override
  State<ClassTypeAndTravelers> createState() => _ClassTypeAndTravelersState();
}

class _ClassTypeAndTravelersState extends State<ClassTypeAndTravelers> {
  SearchFlightController searchFlightController = Get.find();
  ClassTypeController classTypeController = Get.find();
  TravelersController travelersController = Get.find();

  AgeItem? selectedAgeItem;

  List<AgeItem?> selectedChildrenAgeItems = [];
  List<AgeItem> childrenAgeItems = [
    for (int i = 1; i < 17; i++) AgeItem(id: i, age: i + 1, type: "child"),
  ];

  List<AgeItem?> selectedInfantsSeatsAgeItems = [];
  List<AgeItem> infantsSeatsAgeItems = [
    for (int i = 1; i < 2; i++) AgeItem(id: i, age: i + 1, type: "infant_seat"),
  ];

  List<AgeItem?> selectedInfantsLapAgeItems = [];
  List<AgeItem> infantsLapAgeItems = [
    for (int i = 1; i < 2; i++) AgeItem(id: i, age: i + 1, type: "infant_lap"),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // selectedAgeItem = ageItems[0];

    for (int i = 0; i < travelersController.maxChildrenCounter(); i++) {
      selectedChildrenAgeItems.add(selectedAgeItem);
    }

    for (int i = 0; i < travelersController.maxInfantsInSeatCounter(); i++) {
      selectedInfantsSeatsAgeItems.add(selectedAgeItem);
    }

    for (int i = 0; i < travelersController.maxInfantsInLapCounter(); i++) {
      selectedInfantsLapAgeItems.add(selectedAgeItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false, // حتى لا تملأ الشاشة مباشرة
      initialChildSize: 0.75, // 👈 تبدأ بنصف الشاشة
      minChildSize: 0.30, // 👈 أقل ارتفاع (يمكن سحبها للأسفل)
      maxChildSize: 0.90, // 👈 أقصى ارتفاع عند السحب للأعلى
      builder: (context, scrollController) {
        return Column(
          children: [
            Expanded(
              child: CupertinoScrollbar(
                controller: scrollController,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(100),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // يجعل الارتفاع حسب المحتوى
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 0),
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                CupertinoIcons.back,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              'Class Type and Travelers'.tr,
                              style: TextStyle(
                                fontSize: AppConsts.xlg,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // DropdownSearch<ClassType>(),
                        GetBuilder<ClassTypeController>(
                          builder: (controller) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: ClassTypeDropdown(controller: controller),
                            );
                          },
                        ),

                        GetBuilder<TravelersController>(
                          builder: (controller) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 12),
                                TravelerListTile(
                                  controller: controller,
                                  title: 'Adults'.tr,
                                  body: 'Greater than or equal to 12 years'.tr,
                                  counter: controller.adultsCounter,
                                  changeCounter: controller.changeAdultsCounter,
                                ),
                                const SizedBox(height: 8),
                                TravelerListTile(
                                  controller: controller,
                                  title: 'Children'.tr,
                                  body: 'between 2 and 11 years'.tr,
                                  counter: controller.childrenCounter,
                                  changeCounter:
                                      controller.changeChildrenCounter,
                                ),
                                const SizedBox(height: 8),

                                // for (int i = 0; i < controller.childrenCounter; i++)
                                //   Container(
                                //     width:
                                //         AppConsts.sizeContext(context).width - 64,
                                //     child: DropdownButtonFormField<AgeItem>(
                                //       initialValue: selectedChildrenAgeItems[i],
                                //       decoration: InputDecoration(
                                //         labelText: " Child ${i + 1} Age ",
                                //       ),
                                //       menuMaxHeight: 160,
                                //       items: childrenAgeItems
                                //           .where((e) {
                                //             return e.type == "child";
                                //           })
                                //           .map((item) {
                                //             return DropdownMenuItem<AgeItem>(
                                //               value: item,
                                //               child: Text(item.age.toString()),
                                //             );
                                //           })
                                //           .toList(),
                                //       onChanged: (value) {
                                //         selectedChildrenAgeItems[i] = value;
                                //         controller.update();
                                //       },
                                //     ),
                                //   ),


                                // const SizedBox(height: 8),
                                // TravelerListTile(
                                //   controller: controller,
                                //   title: 'Infants in Seat',
                                //   body: 'Less than 2 years old',
                                //   counter: controller.infantsInSeatCounter,
                                //   changeCounter:
                                //       controller.changeInfantsInSeatCounter,
                                // ),


                                const SizedBox(height: 8),
                                TravelerListTile(
                                  controller: controller,
                                  title: 'Infants in Lap'.tr,
                                  body: 'Less than 2 years old'.tr,
                                  counter: controller.infantsInLapCounter,
                                  changeCounter:
                                      controller.changeInfantsInLapCounter,
                                ),
                                SizedBox(height: 8),
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
            SizedBox(
              height: 60,
              width: AppConsts.sizeContext(context).width * 0.9,
              child: GetBuilder<ClassTypeController>(
                builder: (controller) {
                  return ElevatedButton(
                    onPressed: (controller.selectedClassType == null)
                        ? null
                        : () async {
                            if (controller.selectedClassType != null) {
                              print(
                                "classTypeSelected: ${controller.selectedClassType!.name}",
                              );
                            }
                            Navigator.pop(context);
                          },
                    child: Text("حفظ"),
                  );
                },
              ),
            ),
            SizedBox(height: 40),
          ],
        );
      },
    );
  }
}

class TravelerListTile extends StatelessWidget {
  final String title;
  final String body;
  final TravelersController controller;
  final int counter;
  final Function(int counter) changeCounter;
  const TravelerListTile({
    super.key,
    required this.controller,
    required this.title,
    required this.body,
    required this.changeCounter,
    required this.counter,
  });

  Function()? minusCounter() {
    print("minusCounter: $counter");
    if (changeCounter == controller.changeAdultsCounter && counter > 1) {
      print("minusCounter 2: $counter");
      return () {
        changeCounter(-1);
      };
    } else if (changeCounter == controller.changeChildrenCounter &&
        counter > 0) {
      return () {
        changeCounter(-1);
      };
    } else if (changeCounter == controller.changeInfantsInSeatCounter &&
        counter > 0) {
      return () {
        changeCounter(-1);
      };
    } else if (changeCounter == controller.changeInfantsInLapCounter &&
        counter > 0) {
      return () {
        changeCounter(-1);
      };
    } else {
      return null;
    }
  }

  Function()? plusCounter() {
    if (changeCounter == controller.changeAdultsCounter &&
        controller.travelersCounter() < controller.maxTravelersCounter) {
      return () {
        changeCounter(1);
      };
    } else if (changeCounter == controller.changeChildrenCounter &&
        controller.travelersCounter() < controller.maxTravelersCounter &&
        counter < controller.maxChildrenCounter()) {
      return () {
        changeCounter(1);
      };
    } else if (changeCounter == controller.changeInfantsInSeatCounter &&
        controller.travelersCounter() < controller.maxTravelersCounter &&
        counter < controller.maxInfantsInSeatCounter()) {
      return () {
        changeCounter(1);
      };
    } else if (changeCounter == controller.changeInfantsInLapCounter &&
        controller.travelersCounter() < controller.maxTravelersCounter &&
        counter < controller.maxInfantsInLapCounter()) {
      return () {
        changeCounter(1);
      };
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(start: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppConsts.lg,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: AppConsts.normal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.minus_circle),
                  onPressed: minusCounter(),
                ),
                Text("$counter"),
                IconButton(
                  icon: const Icon(CupertinoIcons.plus_circle),
                  onPressed: plusCounter(),
                ),
              ],
            ),
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
  // ClassType? selected;

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<ClassTypeModel>(
      // دالة إحضار العناصر (مع فلترة حسب نص البحث)
      items: (String? filter, LoadProps? infiniteScrollProps) async {
        return widget.controller.getData(filter);
      },

      filterFn: (item, filter) {
        final q = filter.toLowerCase().trim();
        return item.name['en'].toString().toLowerCase().contains(q) ||
            item.name['ar'].toString().toLowerCase().contains(q);
      },

      // كيف تعرض النص داخل الحقل/العنصر
      itemAsString: (item) {
        return item.name[AppVars.lang];
      },

      // للمقارنة الصحيحة بين العنصر المختار والعناصر (بالـid)
      compareFn: (a, b) {
        return a.id == b.id;
      },

      // اختيار مبدئي (اختياري)
      selectedItem: widget.controller.selectedClassType,

      // ماذا يحدث عند اختيار عنصر
      onChanged: (value) {
        widget.controller.changeSelectedClassType(value);
      },

      // ديكورات الحقل (label/hint/border ...)
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: ' ${'Class Type'.tr} ',
          hintText: 'Select Class Type'.tr,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          // prefix: IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          alignLabelWithHint: true,
          // floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
      ),

      // إعدادات الـpopup (هنا Menu مع خانة بحث)
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,

        cacheItems: true, // بعد التحميل الأول، فلترة محلية فقط
        disableFilter: false, // اسمح للودجت يفلتر باستخدام filterFn

        searchDelay: Duration(milliseconds: 250), // بحث فوري لفلترة محلية
        title: Padding(
          padding: EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 8),
          child: Text('Search'.tr),
        ),
        searchFieldProps: TextFieldProps(
          controller: widget.controller.txtClassType,
          decoration: InputDecoration(
            hintText: '${'Search'.tr} ...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        // شكّل كل عنصر في القائمة
        itemBuilder: (context, item, isSelected, index) => ListTile(
          title: Text(item.name[AppVars.lang]),
          selected: isSelected,
        ),
        // حجم مناسب للقائمة
        constraints: const BoxConstraints(maxHeight: 900),
        // constraints: const BoxConstraints(
        //   minWidth: 0, // مهم للموبايل
        //   maxWidth: 400, // اختَر ما يناسب شاشتك
        //   maxHeight: 500, // اجعل المحتوى ي-scroll بدل ما يقيس intrinsic
        // ),
        // خَلّ الـListView يتمدّد داخل القيود بدل ما يطلب intrinsic height
        listViewProps: const ListViewProps(shrinkWrap: true),
      ),

      // أهم شيء: قيود للدايالوج (العرض/الارتفاع الأقصى)
      // أزرار الملحقات: زر السهم + زر مسح القيمة
      suffixProps: const DropdownSuffixProps(
        clearButtonProps: ClearButtonProps(isVisible: false),
        // dropdownButtonProps: DropdownButtonProps(icon: Icon(Icons.expand_more)),
      ),
    );
  }

}

class AgeItem {
  final int id;
  final int age;
  final String type;
  AgeItem({required this.id, required this.age, required this.type});
}
