import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../utils/app_consts.dart';

class MyDate extends StatefulWidget {
  const MyDate({super.key});

  @override
  State<MyDate> createState() => _MyDateState();
}

class _MyDateState extends State<MyDate> with SingleTickerProviderStateMixin {
  DateRangePickerController leavingDate =
      DateRangePickerController();
  DateRangePickerController goingDate =
      DateRangePickerController();

  late final TabController tabController;

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("MyDate"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: SizedBox(
              height: 30,
              child: TabBar(
                controller: tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                // indicatorWeight: 30,
                dividerHeight: 0,
                dividerColor: Colors.transparent,
                padding: EdgeInsets.all(0),
                indicator: BoxDecoration(color: AppConsts.secondaryColor),
                tabs: const [
                  Tab(child: Text("Leaving Date")),
                  Tab(child: Text("Going Date")),
                ],
              ),
            ),
          ),
        ),
      
        body: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(), // ⬅️ يمنع السحب
          children: [
            SfDateRangePicker(
              backgroundColor: Colors.white,
              controller: leavingDate,
              selectionColor: AppConsts.secondaryColor,
              selectionTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              headerStyle: DateRangePickerHeaderStyle(
                backgroundColor: AppConsts.primaryColor,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      
              view: DateRangePickerView.month,
              minDate: DateTime.now(),
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedRange: PickerDateRange(
                DateTime.now().subtract(const Duration(days: 0)),
                DateTime.now().add(const Duration(days: 0)),
              ),
              // showActionButtons: true,
              onSelectionChanged:
                  (DateRangePickerSelectionChangedArgs value) async {
                    print("onSelectionChanged value: ${value.value}");
                    tabController.animateTo(1);
                  },
              onSubmit: (value) {
                print("onSubmit value: $value");
              },
            ),
      
            SfDateRangePicker(
              backgroundColor: Colors.white,
              controller: goingDate,
              selectionColor: AppConsts.secondaryColor,
              selectionTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              headerStyle: DateRangePickerHeaderStyle(
                backgroundColor: AppConsts.primaryColor,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      
              view: DateRangePickerView.month,
              minDate: DateTime.now(),
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedRange: PickerDateRange(
                DateTime.now().subtract(const Duration(days: 0)),
                DateTime.now().add(const Duration(days: 0)),
              ),
              // showActionButtons: true,
              onSelectionChanged:
                  (DateRangePickerSelectionChangedArgs value) async {
                    print("onSelectionChanged value: ${value.value}");
                  },
              onSubmit: (value) {
                print("onSubmit value: $value");
              },
            ),
          ],
        ),
      ),
    );
  }

}
