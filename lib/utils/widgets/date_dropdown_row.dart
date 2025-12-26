import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // الأيام 01..31 (تتغيّر حسب الشهر/السنة)
  List<String> days = List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));

  // الأشهر
  final List<Map<String, String>> months = const [
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

  // السنوات
  late final List<String> years;

  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _minDate = widget.minDate ?? DateTime(now.year - 120, 1, 1);
    _maxDate = widget.maxDate ?? now;

    // لو minDate > maxDate نبدّلهم
    if (_maxDate.isBefore(_minDate)) {
      final tmp = _minDate;
      _minDate = _maxDate;
      _maxDate = tmp;
    }

    // توليد السنوات من الأعلى (maxYear) إلى الأدنى (minYear)
    years = List.generate(_maxDate.year - _minDate.year + 1, (index) => (_maxDate.year - index).toString());

    // تطبيق initialDate لو موجودة وفي النطاق
    final init = widget.initialDate;
    if (init != null && _isInRange(init, _minDate, _maxDate)) {
      selectedYear = init.year.toString();
      selectedMonth = init.month.toString().padLeft(2, '0');
      _updateDaysForMonthYear(selectedMonth, selectedYear);
      selectedDay = init.day.toString().padLeft(2, '0');
    }
  }

  @override
  void didUpdateWidget(covariant DateDropdownRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      setState(() {
        final init = widget.initialDate;
        if (init != null && _isInRange(init, _minDate, _maxDate)) {
          selectedYear = init.year.toString();
          selectedMonth = init.month.toString().padLeft(2, '0');
          _updateDaysForMonthYear(selectedMonth, selectedYear);
          selectedDay = init.day.toString().padLeft(2, '0');
        }
      });
    }
  }

  bool _isInRange(DateTime d, DateTime min, DateTime max) {
    return !d.isBefore(min) && !d.isAfter(max);
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  void _updateDaysForMonthYear(String? month, String? year) {
    if (month == null) {
      days = List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
      selectedDay = null;
      return;
    }

    final m = int.parse(month);
    final y = year != null ? int.tryParse(year) : null;

    int maxDay;
    if (m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12) {
      maxDay = 31;
    } else if (m == 4 || m == 6 || m == 9 || m == 11) {
      maxDay = 30;
    } else {
      // February
      if (y == null || _isLeapYear(y)) {
        maxDay = 29;
      } else {
        maxDay = 28;
      }
    }

    days = List.generate(maxDay, (i) => (i + 1).toString().padLeft(2, '0'));

    // لو اليوم الحالي خارج الرينج الجديد نخليه null
    if (selectedDay != null && !days.contains(selectedDay)) {
      selectedDay = null;
    }
  }

  // ___________ دوال التغيير ___________

  void changeYear(String value) {
    setState(() {
      selectedYear = value;
      // selectedMonth = null;
      selectedDay = null;
      _updateDaysForMonthYear(selectedMonth, selectedYear);
    });
    widget.onDateChanged?.call(selectedDateOrNull);
  }

  void changeMonth(String value) {
    setState(() {
      selectedMonth = value;
      _updateDaysForMonthYear(selectedMonth, selectedYear);
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

    return date;
  }

  /// يستخدم داخل الـ validator (مثل TextFormField)
  String? _runValidator(DateTime? date) {
    if (widget.validator != null) {
      return widget.validator!(date);
    }
    // الافتراضي لو ما في validator مخصّص
    if (date == null) {
      return widget.defaultValidationMessage;
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

  // _______________________________ UI _______________________________

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime?>(
      // نفس TextFormField: نمرر التاريخ للـ validator
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
                    textColor: Colors.black,
                    items: years
                        .map(
                          (y) => DropdownMenuItem<String>(
                            value: y,
                            child: Text(y, style: TextStyle(color: cs.onSurface)),
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
                  flex: 3,
                  child: _buildDropdownContainer(
                    context: context,
                    value: selectedMonth,
                    disabled: false,
                    label: 'Month'.tr,
                    textColor: Colors.black,
                    items: months
                        .map(
                          (m) => DropdownMenuItem<String>(
                            value: m['value'],
                            child: Text('${m['value']} - ${m['name']!.tr}', style: TextStyle(color: cs.onSurface)),
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
                  flex: 2,
                  child: _buildDropdownContainer(
                    context: context,
                    value: selectedDay,
                    disabled: (selectedYear == null || selectedMonth == null),
                    label: 'Day'.tr,
                    textColor: Colors.black,
                    items: days
                        .map(
                          (d) => DropdownMenuItem<String>(
                            value: d,
                            child: Text(d, style: TextStyle(color: cs.onSurface)),
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
              "You must specify the first year, then the month, then the day".tr, 
              style: const TextStyle(
                fontSize: AppConsts.sm,
                color: Colors.grey,
              )),

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
    required Color textColor,
    required String? error,
  }) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = (error != null) ? cs.error : (disabled ? Colors.grey[300]! : Colors.grey);

    return DropdownButtonFormField<String>(
      // 👈 المهم: استخدم value بدل initialValue
      value: value,

      // initialValue: value,  // احذف هذه السطر
      validator: (_) => null, // الفاليديشن الحقيقي في FormField الخارجي
      decoration: InputDecoration(
        contentPadding: EdgeInsetsDirectional.only(start: 8),
        labelText: label,
        labelStyle: TextStyle(fontSize: 14),
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
      style: const TextStyle(fontSize: 16),
      onChanged: disabled ? null : onChanged,
      items: items,
    );
  }
}
