

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


class DatePickerRangeWidget extends StatefulWidget {
  final int index; // <-- مهم: أي form هذا
  const DatePickerRangeWidget({super.key, required this.index});

  @override
  State<DatePickerRangeWidget> createState() => _DatePickerRangeWidgetState();
}

class _DatePickerRangeWidgetState extends State<DatePickerRangeWidget>
    with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    tabController.dispose(); // مِلْك الويدجت نفسه
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int i = widget.index;

    return GetBuilder<SearchFlightController>(
      id: 'form-$i', // إعادة بناء جزئية لهذا الـ form
      builder: (controller) {
        final form = controller.forms[i];

        return Scaffold(
          appBar: AppBar(
            // backgroundColor: AppConsts.tertiaryColor[200],
            title:  Text("Select Dates".tr),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.clear,),
              onPressed: () => Get.back(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: SizedBox(
                height: 40,
                child: TabBar(
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicatorColor: AppConsts.secondaryColor,
                  labelColor: AppConsts.secondaryColor,
                  indicatorWeight: 5,
                  padding: EdgeInsets.zero,
                  tabs:  [
                    Tab(child: Text("Leaving Date".tr)),
                    Tab(child: Text("Going Date".tr)),
                  ],
                ),
              ),
            ),
          ),

          body: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(), // منع السحب
            children: [
              // ======= التبويب 1: تاريخ المغادرة =======
              SfDateRangePicker(
                showNavigationArrow: true,
                controller: form.departureDatePickerController,
                selectionColor: AppConsts.secondaryColor,

                todayHighlightColor: AppConsts.secondaryColor,
                
                
                selectionTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: AppConsts.primaryColor,
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                headerHeight: 50,
                view: DateRangePickerView.month,
                minDate: DateTime.now(),
                maxDate: DateTime.now().add(const Duration(days: 360)),
                selectionMode: DateRangePickerSelectionMode.single,
                onSelectionChanged:
                    (DateRangePickerSelectionChangedArgs value) async {
                  // القيمة تكون DateTime مع selectionMode.single
                  final selected = value.value as DateTime;

                  // احفظ التاريخ في كنترولر الـ form
                  form.departureDatePickerController.selectedDate = selected;

                  // صفّر تاريخ العودة إذا كان موجود (اختياريًا لتحفيز المستخدم يختار من جديد)
                  form.returnDatePickerController.selectedDate = null;

                  // حدّث هذا الـ form فقط ثم روح لتبويب العودة
                  controller.update(['form-$i']);
                  tabController.animateTo(1);
                },
              ),

              // ======= التبويب 2: تاريخ العودة =======
              SfDateRangePicker(
                showNavigationArrow: true,
                controller: form.returnDatePickerController,
                selectionColor: AppConsts.secondaryColor,

                todayHighlightColor: AppConsts.secondaryColor,
                
                selectionTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: AppConsts.primaryColor,
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                headerHeight: 50,
                view: DateRangePickerView.month,
                // امنع اختيار تاريخ عودة قبل المغادرة
                minDate: form.departureDatePickerController.selectedDate ?? DateTime.now(),
                selectionMode: DateRangePickerSelectionMode.single,
                onSelectionChanged:
                    (DateRangePickerSelectionChangedArgs value) async {
                  final selected = value.value as DateTime;

                  // تحقّق أن المغادرة موجودة وأن العودة >= المغادرة
                  final leaving = form.departureDatePickerController.selectedDate;
                  if (leaving == null) {
                    // لو ما في مغادرة، ارجَع للتبويب الأول يختارها
                    tabController.animateTo(0);
                    return;
                  }
                  if (selected.isBefore(leaving)) {
                    // ما المفروض تصير بسبب minDate، لكن للسلامة
                    return;
                  }

                  form.returnDatePickerController.selectedDate = selected;

                  // حدّث هذا الـ form فقط
                  controller.update(['form-$i']);

                  // اقفل الشاشة وخلّ الأب يحدّث الحقول النصيّة
                  Get.back(result: 1);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
