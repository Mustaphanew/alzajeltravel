import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

enum _PickerMode { day, month }

class DatePickerRangeWidget2 extends StatefulWidget {
  final int index; // <-- مهم: أي form هذا
  const DatePickerRangeWidget2({super.key, required this.index});

  @override
  State<DatePickerRangeWidget2> createState() => _DatePickerRangeWidget2State();
}

class _DatePickerRangeWidget2State extends State<DatePickerRangeWidget2>
    with TickerProviderStateMixin {
  late final TabController tabController;

  // min/max مثل Syncfusion
  late final DateTime _minDay; // اليوم
  late final DateTime _maxDay; // اليوم + 360

  // ====== Leaving tab state ======
  _PickerMode _leaveMode = _PickerMode.day;
  DateTime _leaveFocusedDay = DateTime.now();
  DateTime? _leaveSelectedDay;
  int _leaveMonthPickerYear = DateTime.now().year;

  // ====== Return tab state ======
  _PickerMode _returnMode = _PickerMode.day;
  DateTime _returnFocusedDay = DateTime.now();
  DateTime? _returnSelectedDay;
  int _returnMonthPickerYear = DateTime.now().year;

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

  bool _dayEnabled(DateTime day, DateTime minDay, DateTime maxDay) {
    final d = _dateOnly(day);
    return !d.isBefore(minDay) && !d.isAfter(maxDay);
  }

  bool _monthEnabled(int year, int month, DateTime minDay, DateTime maxDay) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return !(end.isBefore(minDay) || start.isAfter(maxDay));
  }

  bool _canPrevFor(_PickerMode mode, int monthPickerYear, DateTime focusedDay, DateTime minDay) {
    if (mode == _PickerMode.month) return monthPickerYear > minDay.year;
    return _monthStart(focusedDay).isAfter(_monthStart(minDay));
  }

  bool _canNextFor(_PickerMode mode, int monthPickerYear, DateTime focusedDay, DateTime maxDay) {
    if (mode == _PickerMode.month) return monthPickerYear < maxDay.year;
    return _monthStart(focusedDay).isBefore(_monthStart(maxDay));
  }

  void _prevFor({
    required bool isLeaving,
    required DateTime minDay,
  }) {
    setState(() {
      if (isLeaving) {
        if (!_canPrevFor(_leaveMode, _leaveMonthPickerYear, _leaveFocusedDay, minDay)) return;
        if (_leaveMode == _PickerMode.month) {
          _leaveMonthPickerYear--;
        } else {
          _leaveFocusedDay = DateTime(_leaveFocusedDay.year, _leaveFocusedDay.month - 1, 1);
        }
      } else {
        if (!_canPrevFor(_returnMode, _returnMonthPickerYear, _returnFocusedDay, minDay)) return;
        if (_returnMode == _PickerMode.month) {
          _returnMonthPickerYear--;
        } else {
          _returnFocusedDay = DateTime(_returnFocusedDay.year, _returnFocusedDay.month - 1, 1);
        }
      }
    });
  }

  void _nextFor({
    required bool isLeaving,
    required DateTime maxDay,
  }) {
    setState(() {
      if (isLeaving) {
        if (!_canNextFor(_leaveMode, _leaveMonthPickerYear, _leaveFocusedDay, maxDay)) return;
        if (_leaveMode == _PickerMode.month) {
          _leaveMonthPickerYear++;
        } else {
          _leaveFocusedDay = DateTime(_leaveFocusedDay.year, _leaveFocusedDay.month + 1, 1);
        }
      } else {
        if (!_canNextFor(_returnMode, _returnMonthPickerYear, _returnFocusedDay, maxDay)) return;
        if (_returnMode == _PickerMode.month) {
          _returnMonthPickerYear++;
        } else {
          _returnFocusedDay = DateTime(_returnFocusedDay.year, _returnFocusedDay.month + 1, 1);
        }
      }
    });
  }

  void _toggleModeFor(bool isLeaving) {
    setState(() {
      if (isLeaving) {
        if (_leaveMode == _PickerMode.day) {
          _leaveMode = _PickerMode.month;
          _leaveMonthPickerYear = _leaveFocusedDay.year;
        } else {
          _leaveMode = _PickerMode.day;
        }
      } else {
        if (_returnMode == _PickerMode.day) {
          _returnMode = _PickerMode.month;
          _returnMonthPickerYear = _returnFocusedDay.year;
        } else {
          _returnMode = _PickerMode.day;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    _minDay = _dateOnly(DateTime.now());
    _maxDay = _minDay.add(const Duration(days: 360));

    _leaveFocusedDay = _minDay;
    _leaveMonthPickerYear = _leaveFocusedDay.year;

    _returnFocusedDay = _minDay;
    _returnMonthPickerYear = _returnFocusedDay.year;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget _buildBlueHeader({
    required bool isLeaving,
    required DateTime minDay,
    required DateTime maxDay,
  }) {
    final mode = isLeaving ? _leaveMode : _returnMode;
    final focused = isLeaving ? _leaveFocusedDay : _returnFocusedDay;
    final year = isLeaving ? _leaveMonthPickerYear : _returnMonthPickerYear;

    final title = (mode == _PickerMode.day) ? '${_monthName(focused)} ${focused.year}' : '$year';

    final canPrev = _canPrevFor(mode, year, focused, minDay);
    final canNext = _canNextFor(mode, year, focused, maxDay);

    final iconColor = Colors.white;
    final disabledColor = Colors.white.withOpacity(.35);

    return Container(
      height: 54,
      color: AppConsts.primaryColor,
      child: Row(
        children: [
          IconButton(
            onPressed: canPrev ? () => _prevFor(isLeaving: isLeaving, minDay: minDay) : null,
            icon: Icon(Icons.chevron_left, color: canPrev ? iconColor : disabledColor),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _toggleModeFor(isLeaving),
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
            onPressed: canNext ? () => _nextFor(isLeaving: isLeaving, maxDay: maxDay) : null,
            icon: Icon(Icons.chevron_right, color: canNext ? iconColor : disabledColor),
          ),
        ],
      ),
    );
  }

  // ✅ Month picker بنفس ستايل DatePickerSingleWidget2 (Light/Dark)
  Widget _buildMonthPicker({
    required bool isLeaving,
    required DateTime minDay,
    required DateTime maxDay,
  }) {
    final locale = _localeTag();
    final cs = Theme.of(context).colorScheme;

    final year = isLeaving ? _leaveMonthPickerYear : _returnMonthPickerYear;
    final focused = isLeaving ? _leaveFocusedDay : _returnFocusedDay;

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

          final enabled = _monthEnabled(year, month, minDay, maxDay);
          final selectedMonth = (focused.year == year && focused.month == month);

          final monthLabel = DateFormat.MMMM(locale).format(DateTime(2020, month, 1));

          return InkWell(
            onTap: enabled
                ? () {
                    setState(() {
                      final newFocus = DateTime(year, month, 1);
                      if (isLeaving) {
                        _leaveFocusedDay = newFocus;
                        _leaveMode = _PickerMode.day;
                      } else {
                        _returnFocusedDay = newFocus;
                        _returnMode = _PickerMode.day;
                      }
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
                      : cs.primaryFixed,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Day calendar بنفس ستايل DatePickerSingleWidget2 (Light/Dark)
  Widget _buildDayCalendar({
    required bool isLeaving,
    required SearchFlightController controller,
    required int i,
    required DateTime minDay,
    required DateTime maxDay,
  }) {
    final form = controller.forms[i];

    // لمنع Assertion: firstDay/lastDay على مستوى الشهر
    final calFirstDay = DateTime(minDay.year, minDay.month, 1);
    final calLastDay = DateTime(maxDay.year, maxDay.month + 1, 0);

    final cs = Theme.of(context).colorScheme;

    final focused = isLeaving ? _leaveFocusedDay : _returnFocusedDay;
    final selected = isLeaving ? _leaveSelectedDay : _returnSelectedDay;

    return TableCalendar(
      locale: _localeTag(),
      firstDay: calFirstDay,
      lastDay: calLastDay,
      focusedDay: focused,

      shouldFillViewport: true,
      availableGestures: AvailableGestures.all,

      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerVisible: false,

      // Divider + أسماء الأيام بنفس تصميم Single
      daysOfWeekHeight: 40,
      daysOfWeekStyle: DaysOfWeekStyle(
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

      enabledDayPredicate: (day) => _dayEnabled(day, minDay, maxDay),
      selectedDayPredicate: (day) => isSameDay(selected, day),

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

      onPageChanged: (newFocused) {
        setState(() {
          if (isLeaving) {
            _leaveFocusedDay = newFocused;
          } else {
            _returnFocusedDay = newFocused;
          }
        });
      },

      onDaySelected: (selectedDay, newFocused) {
        final picked = _dateOnly(selectedDay);
        if (!_dayEnabled(picked, minDay, maxDay)) return;

        if (isLeaving) {
          // ✅ Leaving: خزّن + صفّر العودة + روح لتبويب العودة
          setState(() {
            _leaveSelectedDay = picked;
            _leaveFocusedDay = newFocused;

            _returnSelectedDay = null;
            _returnFocusedDay = picked;
            _returnMode = _PickerMode.day;
            _returnMonthPickerYear = picked.year;
          });

          form.departureDatePickerController.selectedDate = picked;
          form.returnDatePickerController.selectedDate = null;

          controller.update(['form-$i']);
          tabController.animateTo(1);
          return;
        }

        // ✅ Return: لازم يكون >= leaving
        final leaving = form.departureDatePickerController.selectedDate;
        if (leaving == null) {
          tabController.animateTo(0);
          return;
        }

        final leaveOnly = _dateOnly(leaving);
        if (picked.isBefore(leaveOnly)) return;

        setState(() {
          _returnSelectedDay = picked;
          _returnFocusedDay = newFocused;
        });

        form.returnDatePickerController.selectedDate = picked;

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

        // init مرة واحدة من القيم المحفوظة
        if (!_initFromFormDone) {
          final dep = form.departureDatePickerController.selectedDate;
          final ret = form.returnDatePickerController.selectedDate;

          if (dep != null) {
            final depD = _dateOnly(dep);
            _leaveSelectedDay = depD;
            _leaveFocusedDay = depD;
            _leaveMonthPickerYear = depD.year;

            if (ret != null) {
              final retD = _dateOnly(ret);
              if (!retD.isBefore(depD) && !retD.isAfter(_maxDay)) {
                _returnSelectedDay = retD;
                _returnFocusedDay = retD;
              } else {
                _returnSelectedDay = null;
                _returnFocusedDay = depD;
              }
            } else {
              _returnFocusedDay = depD;
            }
            _returnMonthPickerYear = _returnFocusedDay.year;
          } else {
            _leaveFocusedDay = _minDay;
            _leaveMonthPickerYear = _leaveFocusedDay.year;

            _returnFocusedDay = _minDay;
            _returnMonthPickerYear = _returnFocusedDay.year;
          }

          _initFromFormDone = true;
        }

        final leavingMin = _minDay;
        final leavingMax = _maxDay;

        final leavingSelected = form.departureDatePickerController.selectedDate;
        final returnMin = leavingSelected != null ? _dateOnly(leavingSelected) : _minDay;
        final returnMax = _maxDay;

        return SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
              title: Text("Select Dates".tr),
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Going Date".tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                // ===== Leaving =====
                Column(
                  children: [
                    _buildBlueHeader(isLeaving: true, minDay: leavingMin, maxDay: leavingMax),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: (_leaveMode == _PickerMode.month)
                            ? _buildMonthPicker(isLeaving: true, minDay: leavingMin, maxDay: leavingMax)
                            : _buildDayCalendar(
                                isLeaving: true,
                                controller: controller,
                                i: i,
                                minDay: leavingMin,
                                maxDay: leavingMax,
                              ),
                      ),
                    ),
                  ],
                ),
          
                // ===== Return =====
                Column(
                  children: [
                    _buildBlueHeader(isLeaving: false, minDay: returnMin, maxDay: returnMax),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: (_returnMode == _PickerMode.month)
                            ? _buildMonthPicker(isLeaving: false, minDay: returnMin, maxDay: returnMax)
                            : _buildDayCalendar(
                                isLeaving: false,
                                controller: controller,
                                i: i,
                                minDay: returnMin,
                                maxDay: returnMax,
                              ),
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
