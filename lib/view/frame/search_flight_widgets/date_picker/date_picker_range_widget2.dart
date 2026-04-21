import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/date_picker/_date_picker_widgets.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

enum _PickerMode { day, month }

class DatePickerRangeWidget2 extends StatefulWidget {
  final int index; // أي form هذا
  final int initialIndex;

  /// ✅ مهم لو عندك SearchFlightController بنظام tag
  final String? controllerTag;

  const DatePickerRangeWidget2({
    super.key,
    required this.index,
    this.initialIndex = 0,
    this.controllerTag,
  });

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
    final cc = loc.countryCode;
    if (cc == null || cc.isEmpty) return loc.languageCode;
    return '${loc.languageCode}_$cc';
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

  // ✅ قبل بناء GetBuilder لازم نتأكد أن controller موجود (tag أو default)
  bool _hasController() {
    final t = widget.controllerTag;
    if (t != null && Get.isRegistered<SearchFlightController>(tag: t)) return true;
    return Get.isRegistered<SearchFlightController>();
  }

  // ✅ tag آمن: لو ما هو مسجل لا نمرره
  String? _safeTag() {
    final t = widget.controllerTag;
    if (t != null && Get.isRegistered<SearchFlightController>(tag: t)) return t;
    return null;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);

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

    final currentMode = isLeaving ? _leaveMode : _returnMode;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppConsts.primaryColor,
            Color(0xFF1B2A57),
            AppConsts.primaryColor,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppConsts.secondaryColor.withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          NavChevron(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev,
            onTap: () => _prevFor(isLeaving: isLeaving, minDay: minDay),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _toggleModeFor(isLeaving),
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      turns: currentMode == _PickerMode.month ? 0.5 : 0,
                      child: const Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: AppConsts.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          NavChevron(
            icon: Icons.chevron_right_rounded,
            enabled: canNext,
            onTap: () => _nextFor(isLeaving: isLeaving, maxDay: maxDay),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildMonthPicker({
    required bool isLeaving,
    required DateTime minDay,
    required DateTime maxDay,
  }) {
    final locale = _localeTag();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final year = isLeaving ? _leaveMonthPickerYear : _returnMonthPickerYear;
    final focused = isLeaving ? _leaveFocusedDay : _returnFocusedDay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: GridView.builder(
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 12,
          childAspectRatio: 2.8,
        ),
        itemBuilder: (context, index) {
          final month = index + 1;

          final enabled = _monthEnabled(year, month, minDay, maxDay);
          final selectedMonth =
              (focused.year == year && focused.month == month);

          final monthLabel =
              DateFormat.MMMM(locale).format(DateTime(2020, month, 1));

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
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedMonth
                    ? AppConsts.secondaryColor
                        .withValues(alpha: isDark ? 0.18 : 0.2)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : AppConsts.primaryColor.withValues(alpha: 0.04)),
                border: Border.all(
                  color: selectedMonth
                      ? AppConsts.secondaryColor.withValues(alpha: 0.85)
                      : AppConsts.secondaryColor.withValues(alpha: 0.18),
                  width: selectedMonth ? 1.4 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                monthLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      selectedMonth ? FontWeight.w800 : FontWeight.w600,
                  color: !enabled
                      ? cs.onSurface.withValues(alpha: 0.35)
                      : (selectedMonth
                          ? AppConsts.secondaryColor
                          : cs.onSurface),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayCalendar({
    required bool isLeaving,
    required SearchFlightController controller,
    required int i,
    required DateTime minDay,
    required DateTime maxDay,
  }) {
    // ✅ حماية من index
    if (i < 0 || i >= controller.forms.length) {
      return Center(child: Text("Invalid form index".tr));
    }

    final form = controller.forms[i];

    // لمنع Assertion: firstDay/lastDay على مستوى الشهر
    final calFirstDay = DateTime(minDay.year, minDay.month, 1);
    final calLastDay = DateTime(maxDay.year, maxDay.month + 1, 0);

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

      daysOfWeekHeight: 40,
      daysOfWeekStyle: DaysOfWeekStyle(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppConsts.secondaryColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
        ),
        dowTextFormatter: (date, locale) =>
            DateFormat.EEEE(locale).format(date),
        weekdayStyle: TextStyle(
          color: AppConsts.secondaryColor.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        weekendStyle: TextStyle(
          color: AppConsts.secondaryColor.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),

      enabledDayPredicate: (day) => _dayEnabled(day, minDay, maxDay),
      selectedDayPredicate: (day) => isSameDay(selected, day),

      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        isTodayHighlighted: true,
        todayDecoration: BoxDecoration(
          color: AppConsts.primaryColor
              .withValues(alpha: isDark ? 0.35 : 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppConsts.primaryColor.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        todayTextStyle: TextStyle(
          color: isDark ? Colors.white : AppConsts.primaryColor,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        disabledTextStyle: TextStyle(
          color: cs.onSurface.withValues(alpha: 0.3),
          fontSize: 15,
        ),
        defaultTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        weekendTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),

        selectedDecoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4C95A),
              AppConsts.secondaryColor,
              Color(0xFFC98C1F),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: AppConsts.primaryColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppConsts.secondaryColor.withValues(alpha: 0.45),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        selectedTextStyle: const TextStyle(
          color: AppConsts.primaryColor,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
        cellMargin: const EdgeInsets.all(4),
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
          // Leaving: خزّن + صفّر العودة + روح لتبويب العودة
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

        // Return: لازم يكون >= leaving
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
        Get.back(result: picked);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int i = widget.index;

    // ✅ لو ما في Controller مسجل، اعرض صفحة آمنة بدل crash
    if (!_hasController()) {
      return Center(child: Text("Search controller not ready".tr));
    }

    return GetBuilder<SearchFlightController>(
      tag: _safeTag(),
      id: 'form-$i',
      builder: (controller) {
        // ✅ حماية من index
        if (i < 0 || i >= controller.forms.length) {
          return Center(child: Text("Invalid form index".tr));
        }

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
              _returnSelectedDay = null;
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

        return SizedBox(
              height: MediaQuery.of(context).size.height * 0.52,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0D1A45),
                          AppConsts.primaryColor,
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppConsts.secondaryColor
                              .withValues(alpha: 0.45),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        CloseRoundButton(onTap: () => Get.back()),
                        Expanded(
                          child: TabBar(
                            controller: tabController,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerColor: Colors.transparent,
                            indicatorColor: AppConsts.secondaryColor,
                            labelColor: AppConsts.secondaryColor,
                            unselectedLabelColor:
                                Colors.white.withValues(alpha: 0.6),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            indicatorWeight: 3,
                            indicatorPadding:
                                const EdgeInsets.symmetric(horizontal: -6),
                            padding: EdgeInsets.zero,
                            tabs: [
                              Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.flight_takeoff_rounded,
                                      size: 14,
                                      color: AppConsts.secondaryColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text("Leaving Date".tr),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.flight_land_rounded,
                                      size: 14,
                                      color: AppConsts.secondaryColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text("Going Date".tr),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
              
                  Expanded(
                    child: TabBarView(
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
                ],
              ),
            );
      },
    );
  }
}
