import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/date_picker/_date_picker_widgets.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

enum _PickerMode { day, month }

class DatePickerSingleWidget2 extends StatefulWidget {
  final int index;

  /// ✅ مهم لو عندك SearchFlightController بنظام tag
  final String? controllerTag;

  const DatePickerSingleWidget2({
    super.key,
    required this.index,
    this.controllerTag,
  });

  @override
  State<DatePickerSingleWidget2> createState() => _DatePickerSingleWidget2State();
}

class _DatePickerSingleWidget2State extends State<DatePickerSingleWidget2>
    with TickerProviderStateMixin {
  late final TabController tabController;

  // min/max مثل Syncfusion
  late final DateTime _minDay; // اليوم
  late final DateTime _maxDay; // اليوم + 360

  _PickerMode _mode = _PickerMode.day;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int _monthPickerYear = DateTime.now().year;
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
    final minMonth = _monthStart(_minDay);
    return _monthStart(_focusedDay).isAfter(minMonth);
  }

  bool get _canNext {
    if (_mode == _PickerMode.month) {
      return _monthPickerYear < _maxDay.year;
    }
    final maxMonth = _monthStart(_maxDay);
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

  /// ✅ قبل بناء GetBuilder لازم نتأكد أن controller موجود (tag أو default)
  bool _hasController() {
    final t = widget.controllerTag;
    if (t != null && Get.isRegistered<SearchFlightController>(tag: t)) return true;
    return Get.isRegistered<SearchFlightController>();
  }

  /// ✅ tag آمن: لو ما هو مسجل لا نمرره
  String? _safeTag() {
    final t = widget.controllerTag;
    if (t != null && Get.isRegistered<SearchFlightController>(tag: t)) return t;
    return null; // default
  }

  Widget _buildBlueHeader() {
    final title = (_mode == _PickerMode.day)
        ? '${_monthName(_focusedDay)} ${_focusedDay.year}'
        : '$_monthPickerYear';

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
            enabled: _canPrev,
            onTap: _prev,
          ),
          Expanded(
            child: InkWell(
              onTap: _toggleMode,
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
                      turns: _mode == _PickerMode.month ? 0.5 : 0,
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
            enabled: _canNext,
            onTap: _next,
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    final locale = _localeTag();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

          final enabled = _monthEnabled(_monthPickerYear, month);
          final selectedMonth =
              (_focusedDay.year == _monthPickerYear && _focusedDay.month == month);
          final monthLabel =
              DateFormat.MMMM(locale).format(DateTime(2020, month, 1));

          return InkWell(
            onTap: enabled
                ? () {
                    setState(() {
                      _focusedDay = DateTime(_monthPickerYear, month, 1);
                      _mode = _PickerMode.day;
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
                  fontWeight: selectedMonth ? FontWeight.w800 : FontWeight.w600,
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
    required SearchFlightController controller,
    required int i,
  }) {
    // ✅ حماية من index
    if (i < 0 || i >= controller.forms.length) {
      return Center(child: Text("Invalid form index".tr));
    }

    final form = controller.forms[i];

    // ✅ نجعل firstDay بداية الشهر، و lastDay نهاية شهر max
    final calFirstDay = DateTime(_minDay.year, _minDay.month, 1);
    final calLastDay = DateTime(_maxDay.year, _maxDay.month + 1, 0);

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

      enabledDayPredicate: _dayEnabled,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        isTodayHighlighted: true,
        todayDecoration: BoxDecoration(
          color: AppConsts.primaryColor.withValues(alpha: isDark ? 0.35 : 0.1),
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

      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },

      onDaySelected: (selectedDay, focusedDay) {
        final picked = _dateOnly(selectedDay);
        if (!_dayEnabled(picked)) return;

        // ✅ حدّث الحالة المحلية أيضًا
        setState(() {
          _selectedDay = picked;
          _focusedDay = focusedDay;
        });

        form.departureDatePickerController.selectedDate = picked;

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
      return Center(
        child: Text("Search controller not ready".tr),
      );
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
                        color:
                            AppConsts.secondaryColor.withValues(alpha: 0.45),
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
                          indicatorWeight: 3,
                          indicatorPadding:
                              const EdgeInsets.symmetric(horizontal: -8),
                          padding: EdgeInsets.zero,
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.flight_takeoff_rounded,
                                    size: 16,
                                    color: AppConsts.secondaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Leaving Date".tr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
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
              ],
            ),
        );
      },
    );
  }
}
