import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

enum _PickerMode { day, month }

class DatePickerSingleWidget2 extends StatefulWidget {
  final int index;
  const DatePickerSingleWidget2({super.key, required this.index});

  @override
  State<DatePickerSingleWidget2> createState() => _DatePickerSingleWidget2State();
}

class _DatePickerSingleWidget2State extends State<DatePickerSingleWidget2>
    with TickerProviderStateMixin {
  late final TabController tabController;

  // min/max مثل Syncfusion
  late final DateTime _minDay; // اليوم
  late final DateTime _maxDay; // اليوم + 360

  // حالة التقويم
  _PickerMode _mode = _PickerMode.day;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // للسنة في Month Picker
  int _monthPickerYear = DateTime.now().year;

  bool _initFromFormDone = false;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);

  String _localeTag() {
    final loc = Get.locale;
    if (loc == null) return 'en';
    if (loc.countryCode == null || loc.countryCode!.isEmpty) return loc.languageCode;
    return '${loc.languageCode}_${loc.countryCode}';
  }

  String _monthName(DateTime d) {
    final locale = _localeTag();
    return DateFormat.MMMM(locale).format(DateTime(2020, d.month, 1));
  }

  bool _dayEnabled(DateTime day) {
    final d = _dateOnly(day);
    return !d.isBefore(_minDay) && !d.isAfter(_maxDay);
  }

  bool _monthEnabled(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return !(end.isBefore(_minDay) || start.isAfter(_maxDay));
  }

  bool get _canPrev {
    if (_mode == _PickerMode.month) {
      return _monthPickerYear > _minDay.year;
    }
    final minMonth = _monthStart(_minDay); // بداية شهر اليوم
    return _monthStart(_focusedDay).isAfter(minMonth);
  }

  bool get _canNext {
    if (_mode == _PickerMode.month) {
      return _monthPickerYear < _maxDay.year;
    }
    final maxMonth = _monthStart(_maxDay); // بداية شهر max
    return _monthStart(_focusedDay).isBefore(maxMonth);
  }

  void _prev() {
    if (!_canPrev) return;
    setState(() {
      if (_mode == _PickerMode.month) {
        _monthPickerYear--;
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      }
    });
  }

  void _next() {
    if (!_canNext) return;
    setState(() {
      if (_mode == _PickerMode.month) {
        _monthPickerYear++;
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      }
    });
  }

  void _toggleMode() {
    setState(() {
      if (_mode == _PickerMode.day) {
        _mode = _PickerMode.month;
        _monthPickerYear = _focusedDay.year;
      } else {
        _mode = _PickerMode.day;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);

    _minDay = _dateOnly(DateTime.now());
    _maxDay = _minDay.add(const Duration(days: 360));

    _focusedDay = _minDay;
    _monthPickerYear = _focusedDay.year;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget _buildBlueHeader() {
    final title = (_mode == _PickerMode.day)
        ? '${_monthName(_focusedDay)} ${_focusedDay.year}'
        : '$_monthPickerYear';

    final iconColor = Colors.white;
    final disabledColor = Colors.white.withOpacity(.35);

    return Container(
      height: 54,
      color: AppConsts.primaryColor,
      child: Row(
        children: [
          IconButton(
            onPressed: _canPrev ? _prev : null,
            icon: Icon(Icons.chevron_left, color: _canPrev ? iconColor : disabledColor),
          ),
          Expanded(
            child: InkWell(
              onTap: _toggleMode,
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _canNext ? _next : null,
            icon: Icon(Icons.chevron_right, color: _canNext ? iconColor : disabledColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    final locale = _localeTag();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: GridView.builder(
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 26,
          crossAxisSpacing: 16,
          childAspectRatio: 2.8,
        ),
        itemBuilder: (context, index) {
          final month = index + 1;

          final enabled = _monthEnabled(_monthPickerYear, month);
          final selectedMonth =
              (_focusedDay.year == _monthPickerYear && _focusedDay.month == month);

          final monthLabel = DateFormat.MMMM(locale).format(DateTime(2020, month, 1));

          return InkWell(
            onTap: enabled
                ? () {
                    setState(() {
                      _focusedDay = DateTime(_monthPickerYear, month, 1);
                      _mode = _PickerMode.day;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              alignment: Alignment.center,
              decoration: selectedMonth
                  ? BoxDecoration(
                      border: Border.all(color: cs.primaryFixed, width: 1.6),
                      borderRadius: BorderRadius.circular(999),
                    )
                  : null,
              child: Text(
                monthLabel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: !enabled
                      ? Colors.grey.shade500
                      : (selectedMonth ? cs.primaryFixed : cs.primaryFixed),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ هنا التعديل المهم لحل الخطأ
  Widget _buildDayCalendar({
    required SearchFlightController controller,
    required int i,
  }) {
    final form = controller.forms[i];

    // ✅ بدلاً من firstDay = اليوم (الذي يسبب المشكلة)
    // نجعل firstDay بداية الشهر، و lastDay نهاية شهر max
    final calFirstDay = DateTime(_minDay.year, _minDay.month, 1);
    final calLastDay = DateTime(_maxDay.year, _maxDay.month + 1, 0);

    final cs = Theme.of(context).colorScheme;

    return TableCalendar(
      locale: _localeTag(),
      firstDay: calFirstDay,
      lastDay: calLastDay,
      focusedDay: _focusedDay,

      shouldFillViewport: true,
      availableGestures: AvailableGestures.all,

      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerVisible: false,

      daysOfWeekHeight: 40,
      daysOfWeekStyle: DaysOfWeekStyle(

        // ✅ هذا هو الـ Divider بين أسماء الأيام وأرقام الأيام
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade500,
              width: 0.5,
            ),
          ),
        ),
        dowTextFormatter: (date, locale) => DateFormat.EEEE(locale).format(date),
        weekdayStyle: TextStyle(color: cs.primaryFixed, fontSize: 14),
        weekendStyle: TextStyle(color: cs.primaryFixed, fontSize: 14),
      ),

      // ✅ منع الماضي/المدى عن طريق predicate
      enabledDayPredicate: _dayEnabled,

      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

      calendarStyle: CalendarStyle(
        outsideDaysVisible: false, 
        isTodayHighlighted: false,
        disabledTextStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        defaultTextStyle: TextStyle(color: cs.primaryFixed, fontSize: 16),
        weekendTextStyle: TextStyle(color: cs.primaryFixed, fontSize: 16),

        selectedDecoration: BoxDecoration(
          color: AppConsts.secondaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppConsts.primaryColor, width: 1.8),
        ),
        selectedTextStyle: TextStyle(
          color: AppConsts.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        cellMargin: const EdgeInsets.all(6),
      ),

      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },

      onDaySelected: (selectedDay, focusedDay) {
        final picked = _dateOnly(selectedDay);
        if (!_dayEnabled(picked)) return;

        form.departureDatePickerController.selectedDate = picked;

        controller.update(['form-$i']);
        Get.back(result: 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int i = widget.index;

    return GetBuilder<SearchFlightController>(
      id: 'form-$i',
      builder: (controller) {
        final form = controller.forms[i];

        // تهيئة أول مرة من قيمة الفورم (لو محفوظة)
        if (!_initFromFormDone) {
          final stored = form.departureDatePickerController.selectedDate;
          if (stored != null) {
            _selectedDay = _dateOnly(stored);
            _focusedDay = _dateOnly(stored);
            _monthPickerYear = _focusedDay.year;
          } else {
            _focusedDay = _minDay;
            _monthPickerYear = _focusedDay.year;
          }
          _initFromFormDone = true;
        }

        return SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
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
                      Tab(
                        child: Text(
                          "Leaving Date".tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Column(
                  children: [
                    _buildBlueHeader(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: (_mode == _PickerMode.month)
                            ? _buildMonthPicker()
                            : _buildDayCalendar(controller: controller, i: i),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
