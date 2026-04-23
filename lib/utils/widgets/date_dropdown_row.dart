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

  final String? helpText;

  /// Validator مثل TextFormField:
  /// يأخذ DateTime? ويُرجع String? (رسالة خطأ) أو null لو صحيح
  final String? Function(DateTime?)? validator;

  /// رسالة افتراضية لو ما تم تمرير validator
  final String defaultValidationMessage;

  /// كول باك يرجع التاريخ كل ما تغيّر
  final ValueChanged<DateTime?>? onDateChanged;

  final bool enabled;

  const DateDropdownRow({
    super.key,
    required this.title,
    this.initialDate,
    this.minDate,
    this.maxDate,
    this.helpText,
    this.validator,
    this.defaultValidationMessage = 'Please select a valid date of birth',
    this.onDateChanged,
    this.enabled = true,
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
                // السنة (4 أرقام → تحتاج مساحة)
                Expanded(
                  flex: 3,
                  child: _buildDropdownContainer(
                    context: context,
                    kind: _DateDropdownKind.year,
                    value: selectedYear,
                    disabled: false,
                    label: 'Year'.tr,
                    items: years
                        .map(
                          (y) => _buildMenuItem(
                            context: context,
                            value: y,
                            text: y,
                            isSelected: selectedYear == y,
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
                const SizedBox(width: 6),

                // الشهر (يحتاج أكبر مساحة لعرض الاسم مثل "10-أكتوبر")
                Expanded(
                  flex: 4,
                  child: _buildDropdownContainer(
                    context: context,
                    kind: _DateDropdownKind.month,
                    value: selectedMonth,
                    disabled: (selectedYear == null),
                    label: 'Month'.tr,
                    items: availableMonths
                        .map(
                          (m) => _buildMenuItem(
                            context: context,
                            value: m['value']!,
                            text: '${int.parse(m['value'].toString())}-${m['name']!.tr}',
                            isSelected: selectedMonth == m['value'],
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
                const SizedBox(width: 6),

                // اليوم (رقم قصير 1..31)
                Expanded(
                  flex: 2,
                  child: _buildDropdownContainer(
                    context: context,
                    kind: _DateDropdownKind.day,
                    value: selectedDay,
                    disabled: (selectedYear == null || selectedMonth == null),
                    label: 'Day'.tr,
                    items: days
                        .map(
                          (d) => _buildMenuItem(
                            context: context,
                            value: d,
                            text: '${int.parse(d.toString())}',
                            isSelected: selectedDay == d,
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
            // You must specify the first year, then the month, then the day
            if (widget.helpText != null)
              Text(
                widget.helpText!,
                style: TextStyle(
                  fontFamily: AppConsts.font,
                  fontSize: AppConsts.sm,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  errorText,
                  style: TextStyle(
                    fontFamily: AppConsts.font,
                    color: cs.error,
                    fontSize: AppConsts.sm,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// بناء عنصر قائمة عصري مع تمييز العنصر المختار:
  /// - الدارك: ذهبي على خلفية كحليّة
  /// - اللايت: كحلي على خلفية بيضاء/هادئة
  DropdownMenuItem<String> _buildMenuItem({
    required BuildContext context,
    required String value,
    required String text,
    required bool isSelected,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // لون التوكيد يتبع الثيم
    final Color accent =
        isDark ? AppConsts.secondaryColor : AppConsts.primaryColor;

    final Color selectedBg = accent.withValues(alpha: isDark ? 0.20 : 0.10);
    final Color selectedBorder = accent.withValues(alpha: isDark ? 0.65 : 0.55);

    // النص العادي: في الدارك أبيض ناعم، في اللايت رمادي داكن قريب من primary لسهولة القراءة
    final Color normalText = isDark
        ? Colors.white.withValues(alpha: 0.88)
        : cs.onSurface;

    return DropdownMenuItem<String>(
      value: value,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: selectedBorder, width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: accent,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppConsts.font,
                  fontSize: AppConsts.sm,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.2,
                  color: isSelected ? accent : normalText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({
    required BuildContext context,
    required _DateDropdownKind kind,
    required String? value,
    required bool disabled,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required String? error,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool hasValue = value != null && value.isNotEmpty;

    // لون التوكيد (accent) يختلف باختلاف الثيم:
    // - الدارك: ذهبي يلمع على الخلفيّة الكحليّة
    // - اللايت: كحلي يظهر بوضوح على الخلفيّة البيضاء
    final Color accent =
        isDark ? AppConsts.secondaryColor : AppConsts.primaryColor;

    final Color borderColor = (error != null)
        ? cs.error
        : (disabled || !widget.enabled
            ? cs.outline.withValues(alpha: 0.30)
            : (hasValue
                ? accent.withValues(alpha: 0.85)
                : cs.outline.withValues(alpha: 0.50)));

    final Color labelColor = (error != null)
        ? cs.error
        : (disabled || !widget.enabled
            ? cs.onSurface.withValues(alpha: 0.4)
            : (hasValue
                ? accent
                : cs.onSurface.withValues(alpha: 0.75)));

    // خلفية قائمة المنبثقة: كحلية عميقة في الدارك، بيضاء جدًا فاتحة بلمسة كحلية في اللايت.
    final Color menuBg = isDark
        ? const Color(0xFF0F1A3F)
        : const Color(0xFFFAFBFF);

    final Color fillColor = disabled || !widget.enabled
        ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
        : (isDark
            ? cs.surface.withValues(alpha: 0.55)
            : Colors.white);

    return DropdownButtonFormField<String>(
      value: value,
      iconSize: 0,
      validator: (_) => null, // الفاليديشن الحقيقي في FormField الخارجي
      padding: EdgeInsets.zero,
      dropdownColor: menuBg,
      borderRadius: BorderRadius.circular(16),
      elevation: 10,
      menuMaxHeight: 360,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsetsDirectional.only(
          start: 8,
          end: 4,
          top: 10,
          bottom: 10,
        ),
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: AppConsts.font,
          color: labelColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: AppConsts.font,
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1, color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: hasValue ? 1.3 : 1,
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 1.5,
            color: accent,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1, color: borderColor),
        ),
        errorStyle: TextStyle(
          fontFamily: AppConsts.font,
          color: cs.error,
          fontSize: AppConsts.sm,
        ),
      ),
      isExpanded: true,
      icon: Padding(
        padding: const EdgeInsetsDirectional.only(end: 2),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16,
          color: disabled || !widget.enabled
              ? cs.onSurface.withValues(alpha: 0.35)
              : accent,
        ),
      ),
      style: TextStyle(
        fontFamily: AppConsts.font,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
      selectedItemBuilder: (ctx) => items
          .map(
            (it) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 2, end: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    _selectedTextFor(kind, it.value ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppConsts.font,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (widget.enabled) ? (disabled ? null : onChanged) : null,
      items: items,
    );
  }

  /// صياغة نص العنصر المختار داخل الحقل بحسب نوع الحقل (سنة/شهر/يوم).
  String _selectedTextFor(_DateDropdownKind kind, String value) {
    if (value.isEmpty) return '';
    switch (kind) {
      case _DateDropdownKind.year:
        return value;
      case _DateDropdownKind.month:
        final m = _monthsAll.firstWhere(
          (e) => e['value'] == value,
          orElse: () => const {'value': '', 'name': ''},
        );
        final idx = int.tryParse(value) ?? 0;
        final name = (m['name'] ?? '').toString();
        return name.isEmpty ? idx.toString() : '$idx-${name.tr}';
      case _DateDropdownKind.day:
        return (int.tryParse(value) ?? 0).toString();
    }
  }
}

enum _DateDropdownKind { year, month, day }
