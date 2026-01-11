

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


class DatePickerSingleWidget extends StatefulWidget {
  final int index; // <-- لأي form سيُطبّق؟
  const DatePickerSingleWidget({super.key, required this.index});

  @override
  State<DatePickerSingleWidget> createState() => _DatePickerSingleWidgetState();
}

class _DatePickerSingleWidgetState extends State<DatePickerSingleWidget>
    with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int i = widget.index;

    return GetBuilder<SearchFlightController>(
      id: 'form-$i', // تحديث جزئي لهذا السيجمنت فقط
      builder: (controller) {
        final form = controller.forms[i];

        return Scaffold(
          appBar: AppBar(
            // backgroundColor: AppConsts.tertiaryColor[200],
            title: Text("Select Date".tr),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.clear),
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
                  tabs: [
                    Tab(child: Text("Leaving Date".tr)),
                  ],
                ),
              ),
            ),
          ),

          body: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SfDateRangePicker(
                // backgroundColor: Colors.white,
                showNavigationArrow: true,
                controller: form.departureDatePickerController,
                selectionColor: AppConsts.secondaryColor,
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
                minDate: DateTime.now(), // امنع الماضي (عدّلها لو حاب تسمح بالماضي)
                maxDate: DateTime.now().add(const Duration(days: 360)),
                selectionMode: DateRangePickerSelectionMode.single,

                onSelectionChanged:
                    (DateRangePickerSelectionChangedArgs value) async {
                  // في وضع single تكون القيمة DateTime
                  final selected = value.value as DateTime;

                  // احفظ الاختيار في نفس form
                  form.departureDatePickerController.selectedDate = selected;

                  // حدّث هذا الـ form فقط وأغلق الصفحة
                  controller.update(['form-$i']);
                  Get.back(result: 1); // الأب سيستدعي c.setTxtDepartureDates(i)
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
