// date_dropdown_row.dart

import 'package:flutter/material.dart';
import '../app_consts.dart';
import 'package:get/get.dart';

class DateDropdownRow extends StatefulWidget {
  final Widget title;

  /// التاريخ الابتدائي (اختياري)
  final DateTime? initialDate;

  /// أقل تاريخ مسموح (اختياري)
  final DateTime? minDate;

  /// أعلى تاريخ مسموح (اختياري)
  final DateTime? maxDate;

  /// Validator مثل TextFormField:
  /// يأخذ DateTime? ويُرجع String? (رسالة خطأ) أو null لو صحيح
  final String? Function(DateTime?)? validator;

  /// رسالة افتراضية لو ما تم تمرير validator
  final String defaultValidationMessage;

  /// كول باك يرجع التاريخ كل ما تغيّر
  final ValueChanged<DateTime?>? onDateChanged;

  const DateDropdownRow({
    super.key,
    required this.title,
    this.initialDate,
    this.minDate,
    this.maxDate,
    this.validator,
    this.defaultValidationMessage = 'Please select a valid date of birth',
    this.onDateChanged,
  });

  @override
  State<DateDropdownRow> createState() => _DateDropdownRowState();
}

class _DateDropdownRowState extends State<DateDropdownRow> {
  late DateTime _minDate;
  late DateTime _maxDate;

  // الأشهر (الأساس)
  static const List<Map<String, String>> _monthsAll = [
    {'value': '01', 'name': 'Jan'},
    {'value': '02', 'name': 'Feb'},
    {'value': '03', 'name': 'Mar'},
    {'value': '04', 'name': 'Apr'},
    {'value': '05', 'name': 'May'},
    {'value': '06', 'name': 'Jun'},
    {'value': '07', 'name': 'Jul'},
    {'value': '08', 'name': 'Aug'},
    {'value': '09', 'name': 'Sep'},
    {'value': '10', 'name': 'Oct'},
    {'value': '11', 'name': 'Nov'},
    {'value': '12', 'name': 'Dec'},
  ];

  // الأشهر المتاحة حسب السنة
  List<Map<String, String>> availableMonths = [];

  // الأيام المتاحة حسب الشهر/السنة + min/max
  List<String> days = [];

  // السنوات
  late List<String> years;

  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    _rebuildLimitsAndLists(applyInitialDate: true);
  }

  @override
  void didUpdateWidget(covariant DateDropdownRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    final limitsChanged = widget.minDate != oldWidget.minDate || widget.maxDate != oldWidget.maxDate;
    final initialChanged = widget.initialDate != oldWidget.initialDate;

    if (limitsChanged || initialChanged) {
      setState(() {
        _rebuildLimitsAndLists(applyInitialDate: true);
      });
    }
  }

  // -------------------- Helpers --------------------

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isInRange(DateTime d, DateTime min, DateTime max) {
    final dd = _dateOnly(d);
    final mn = _dateOnly(min);
    final mx = _dateOnly(max);
    return !dd.isBefore(mn) && !dd.isAfter(mx);
  }

  int _daysInMonth(int year, int month) {
    // يوم 0 من الشهر التالي = آخر يوم في هذا الشهر
    return DateTime(year, month + 1, 0).day;
  }

  void _rebuildLimitsAndLists({required bool applyInitialDate}) {
    final now = DateTime.now();

    _minDate = _dateOnly(widget.minDate ?? DateTime(now.year - 120, 1, 1));
    _maxDate = _dateOnly(widget.maxDate ?? now);

    // لو minDate > maxDate نبدّلهم
    if (_maxDate.isBefore(_minDate)) {
      final tmp = _minDate;
      _minDate = _maxDate;
      _maxDate = tmp;
    }

    years = List.generate(
      _maxDate.year - _minDate.year + 1,
      (index) => (_maxDate.year - index).toString(),
    );

    if (applyInitialDate) {
      selectedYear = null;
      selectedMonth = null;
      selectedDay = null;

      final init = widget.initialDate;
      if (init != null && _isInRange(init, _minDate, _maxDate)) {
        selectedYear = init.year.toString();
        selectedMonth = init.month.toString().padLeft(2, '0');
        selectedDay = init.day.toString().padLeft(2, '0');
      }
    }

    _updateAvailableMonthsForYear(selectedYear);

    // لو الشهر المختار صار خارج المتاح (بعد تغيير min/max أو السنة)
    if (selectedMonth != null && !availableMonths.any((m) => m['value'] == selectedMonth)) {
      selectedMonth = null;
      selectedDay = null;
    }

    _updateAvailableDaysForMonthYear(selectedMonth, selectedYear);

    // لو اليوم المختار صار خارج المتاح
    if (selectedDay != null && !days.contains(selectedDay)) {
      selectedDay = null;
    }
  }

  void _updateAvailableMonthsForYear(String? yearStr) {
    if (yearStr == null) {
      // غير مهم لأن dropdown سيكون disabled
      availableMonths = List<Map<String, String>>.from(_monthsAll);
      return;
    }

    final y = int.tryParse(yearStr);
    if (y == null) {
      availableMonths = List<Map<String, String>>.from(_monthsAll);
      return;
    }

    int startMonth = 1;
    int endMonth = 12;

    if (y == _minDate.year) startMonth = _minDate.month;
    if (y == _maxDate.year) endMonth = _maxDate.month;

    availableMonths = _monthsAll.where((m) {
      final mv = int.parse(m['value']!);
      return mv >= startMonth && mv <= endMonth;
    }).toList();
  }

  void _updateAvailableDaysForMonthYear(String? month, String? year) {
    if (month == null || year == null) {
      days = [];
      selectedDay = null;
      return;
    }

    final m = int.tryParse(month);
    final y = int.tryParse(year);

    if (m == null || y == null) {
      days = [];
      selectedDay = null;
      return;
    }

    int startDay = 1;
    int endDay = _daysInMonth(y, m);

    if (y == _minDate.year && m == _minDate.month) {
      startDay = _minDate.day;
    }
    if (y == _maxDate.year && m == _maxDate.month) {
      endDay = _maxDate.day;
    }

    if (startDay > endDay) {
      days = [];
      selectedDay = null;
      return;
    }

    days = List.generate(endDay - startDay + 1, (i) => (startDay + i).toString().padLeft(2, '0'));

    if (selectedDay != null && !days.contains(selectedDay)) {
      selectedDay = null;
    }
  }

  // -------------------- Change Handlers --------------------

  void changeYear(String value) {
    setState(() {
      selectedYear = value;

      // بعد تغيير السنة لازم نعيد فلترة الشهور
      _updateAvailableMonthsForYear(selectedYear);

      // لو الشهر الحالي صار خارج المتاح نخليه null
      if (selectedMonth != null && !availableMonths.any((m) => m['value'] == selectedMonth)) {
        selectedMonth = null;
      }

      selectedDay = null;
      _updateAvailableDaysForMonthYear(selectedMonth, selectedYear);
    });

    widget.onDateChanged?.call(selectedDateOrNull);
  }

  void changeMonth(String value) {
    setState(() {
      selectedMonth = value;
      selectedDay = null;
      _updateAvailableDaysForMonthYear(selectedMonth, selectedYear);
    });

    widget.onDateChanged?.call(selectedDateOrNull);
  }

  void changeDay(String value) {
    setState(() {
      selectedDay = value;
    });

    widget.onDateChanged?.call(selectedDateOrNull);
  }

  /// ترجع DateTime لو التاريخ صحيح وفي النطاق، أو null لو غير صحيح
  DateTime? get selectedDateOrNull {
    if (selectedDay == null || selectedMonth == null || selectedYear == null) {
      return null;
    }

    final year = int.parse(selectedYear!);
    final month = int.parse(selectedMonth!);
    final day = int.parse(selectedDay!);

    final date = DateTime(year, month, day);

    // تأكد إنه نفس اليوم/الشهر/السنة (عشان 31 Feb مثلاً)
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }

    // التأكد من النطاق min/max
    if (!_isInRange(date, _minDate, _maxDate)) {
      return null;
    }

    return _dateOnly(date);
  }

  /// يستخدم داخل الـ validator (مثل TextFormField)
  String? _runValidator(DateTime? date) {
    if (widget.validator != null) {
      return widget.validator!(date);
    }
    if (date == null) {
      return widget.defaultValidationMessage.tr;
    }
    return null;
  }

  /// لو حاب ترسله للسيرفر
  String? get apiDateString {
    final date = selectedDateOrNull;
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime?>(
      validator: (_) => _runValidator(selectedDateOrNull),
      builder: (state) {
        final cs = Theme.of(context).colorScheme;
        final errorText = state.errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.title,
            Row(
              children: [
                // السنة
                Expanded(
                  flex: 2,
                  child: _buildDropdownContainer(
                    context: context,
                    value: selectedYear,
                    disabled: false,
                    label: 'Year'.tr,
                    items: years
                        .map(
                          (y) => DropdownMenuItem<String>(
                            value: y,
                            child: Text(
                              y, 
                              style: TextStyle(
                                color: cs.onSurface,
                                fontFamily: AppConsts.font,
                                fontSize: AppConsts.normal,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      changeYear(val);
                      state.didChange(selectedDateOrNull);
                    },
                    error: errorText,
                  ),
                ),
                const SizedBox(width: 4),

                // الشهر
                Expanded(
                  flex: 2,
                  child: _buildDropdownContainer(
                    context: context,
                    value: selectedMonth,
                    disabled: (selectedYear == null),
                    label: 'Month'.tr,
                    items: availableMonths
                        .map(
                          (m) => DropdownMenuItem<String>(
                            value: m['value'],
                            child: Text(
                              '${int.parse(m['value'].toString())}-${m['name']!.tr}',
                              style: TextStyle(
                                fontFamily: AppConsts.font,
                                color: cs.onSurface,
                                fontSize: AppConsts.normal,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      changeMonth(val);
                      state.didChange(selectedDateOrNull);
                    },
                    error: errorText,
                  ),
                ),
                const SizedBox(width: 4),

                // اليوم
                Expanded(
                  flex: 1,
                  child: _buildDropdownContainer(
                    context: context,
                    value: selectedDay,
                    disabled: (selectedYear == null || selectedMonth == null),
                    label: 'Day'.tr,
                    items: days
                        .map(
                          (d) => DropdownMenuItem<String>(
                            value: d,
                            child: Text(
                              '${int.parse(d.toString())}', 
                              style: TextStyle(
                                fontFamily: AppConsts.font,
                                color: cs.onSurface,
                                fontSize: AppConsts.normal,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      changeDay(val);
                      state.didChange(selectedDateOrNull);
                    },
                    error: errorText,
                  ),
                ),
              ],
            ),
            Text(
              'You must specify the first year, then the month, then the day'.tr,
              style: TextStyle(
                fontSize: AppConsts.sm,
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  errorText,
                  style: TextStyle(color: cs.error, fontSize: AppConsts.sm),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownContainer({
    required BuildContext context,
    required String? value,
    required bool disabled,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required String? error,
  }) {
    final cs = Theme.of(context).colorScheme;

    final borderColor = (error != null)
        ? cs.error
        : (disabled ? cs.outline.withOpacity(0.4) : cs.outline);

    return DropdownButtonFormField<String>(
      value: value,
      iconSize: 0,
      validator: (_) => null, // الفاليديشن الحقيقي في FormField الخارجي
      padding: EdgeInsets.only(top: 0),
      decoration: InputDecoration(
        contentPadding: const EdgeInsetsDirectional.only(start: 8),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1, color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1, color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1, color: borderColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1, color: borderColor),
        ),
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      style: const TextStyle(fontSize: 14),
      onChanged: disabled ? null : onChanged,
      items: items,
    );
  }
}
