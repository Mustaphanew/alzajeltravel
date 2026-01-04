import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';

enum ReportDateField { createdAt, travelDate, cancelOn, voidOn }
enum ReportPeriod { withinDay, untilDay, withinMonth, withinRange }

class SearchAndFilterState {
  final bool applied; // ✅ هل تم تنفيذ البحث؟
  final String keyword;

  final ReportDateField dateField;
  final ReportPeriod period;

  // withinDay / untilDay
  final DateTime? singleDate;

  // withinMonth
  final int? year;
  final int? month;

  // withinRange
  final DateTime? from;
  final DateTime? to;

  const SearchAndFilterState({
    required this.applied,
    required this.keyword,
    required this.dateField,
    required this.period,
    this.singleDate,
    this.year,
    this.month,
    this.from,
    this.to,
  });
}

class SearchAndFilter extends StatefulWidget {
  final BookingStatus status;
  final ExpansionTileController tileController;
  final void Function(SearchAndFilterState state)? onSearch;
  final void Function()? onCancel;

  const SearchAndFilter({
    super.key,
    required this.status,
    required this.tileController,
    this.onSearch,
    this.onCancel,
  });

  @override
  State<SearchAndFilter> createState() => _SearchAndFilterState();
}

class _SearchAndFilterState extends State<SearchAndFilter> {
  final TextEditingController keywordCtrl = TextEditingController();

  bool hasSearched = false;

  ReportDateField dateField = ReportDateField.createdAt;
  ReportPeriod period = ReportPeriod.withinDay;

  DateTime? singleDate;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  DateTime? rangeFrom;
  DateTime? rangeTo;

  // ---------- status helpers ----------
  bool get _isCancelledStatus {
    final v = widget.status.apiValue;
    return v == 'cancelled' || v == 'canceled';
  }

  bool get _isVoidStatus {
    final v = widget.status.apiValue;
    return v == 'void' || v == 'voided';
  }

  List<ReportDateField> _allowedDateFields() {
    final fields = <ReportDateField>[
      ReportDateField.createdAt,
      ReportDateField.travelDate,
    ];
    if (_isCancelledStatus) fields.add(ReportDateField.cancelOn);
    if (_isVoidStatus) fields.add(ReportDateField.voidOn);
    return fields;
  }

  // ---------- defaults ----------
  DateTime _todayOnly() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void _applyDefaultDatesForCurrentPeriod() {
    final today = _todayOnly();
    final now = DateTime.now();

    if (period == ReportPeriod.withinDay || period == ReportPeriod.untilDay) {
      singleDate = today;
    }

    if (period == ReportPeriod.withinMonth) {
      selectedYear = now.year;
      selectedMonth = now.month;
      _clampMonthIfNeeded();
    }

    if (period == ReportPeriod.withinRange) {
      rangeFrom = today;
      rangeTo = today;
    }
  }

  void _resetToDefaults({bool clearKeyword = false}) {
    final allowed = _allowedDateFields();
    if (!allowed.contains(dateField)) {
      dateField = ReportDateField.createdAt;
    }

    if (clearKeyword) keywordCtrl.text = '';

    // reset dates to today's defaults
    singleDate = null;
    rangeFrom = null;
    rangeTo = null;

    final now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;

    _applyDefaultDatesForCurrentPeriod();

    hasSearched = false;
  }

  // ---------- constraints ----------
  DateTime get _singleLastDate => _todayOnly(); // withinDay/untilDay <= today
  DateTime get _rangeLastDate => _todayOnly(); // withinRange <= today

  List<int> _yearsList() {
    final nowYear = DateTime.now().year;
    return List.generate(21, (i) => nowYear - i); // current .. current-20
  }

  List<int> _monthsForYear(int year) {
    final now = DateTime.now();
    final maxMonth = (year == now.year) ? now.month : 12;
    return List.generate(maxMonth, (i) => i + 1);
  }

  void _clampMonthIfNeeded() {
    final months = _monthsForYear(selectedYear);
    if (!months.contains(selectedMonth)) {
      // لو السنة الحالية والشهر المختار أكبر من الشهر الحالي
      selectedMonth = months.last;
    }
  }

  @override
  void initState() {
    super.initState();
    // defaults on start
    _applyDefaultDatesForCurrentPeriod();
  }

  @override
  void didUpdateWidget(covariant SearchAndFilter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغير status قد تتغير خيارات Filter by date
    final allowed = _allowedDateFields();
    if (!allowed.contains(dateField)) {
      setState(() {
        dateField = ReportDateField.createdAt;
        _resetToDefaults();
      });
    }
  }

  @override
  void dispose() {
    keywordCtrl.dispose();
    super.dispose();
  }

  // ---------- pickers ----------
  Future<void> _pickSingleDate() async {
    final today = _todayOnly();
    final initial = singleDate ?? today;
    final initSafe = initial.isAfter(today) ? today : initial;

    final picked = await showDatePicker(
      context: context,
      initialDate: initSafe,
      firstDate: DateTime(2000, 1, 1),
      lastDate: _singleLastDate,
    );
    if (picked == null) return;

    setState(() => singleDate = picked);
  }

  Future<void> _pickRangeFrom() async {
    final today = _todayOnly();
    final initial = rangeFrom ?? today;
    final initSafe = initial.isAfter(today) ? today : initial;

    final picked = await showDatePicker(
      context: context,
      initialDate: initSafe,
      firstDate: DateTime(2000, 1, 1),
      lastDate: _rangeLastDate,
    );
    if (picked == null) return;

    setState(() {
      rangeFrom = picked;
      if (rangeTo != null && rangeTo!.isBefore(rangeFrom!)) {
        rangeTo = rangeFrom;
      }
    });
  }

  Future<void> _pickRangeTo() async {
    final today = _todayOnly();
    final initial = rangeTo ?? today;
    final initSafe = initial.isAfter(today) ? today : initial;

    final first = rangeFrom ?? DateTime(2000, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initSafe,
      firstDate: first,
      lastDate: _rangeLastDate, // <= today
    );
    if (picked == null) return;

    setState(() {
      rangeTo = picked;
      if (rangeFrom != null && rangeFrom!.isAfter(rangeTo!)) {
        rangeFrom = rangeTo;
      }
    });
  }

  // ---------- labels & formatting ----------
  String _dateFieldLabel(ReportDateField f) {
    switch (f) {
      case ReportDateField.createdAt:
        return 'Created at'.tr;
      case ReportDateField.travelDate:
        return 'Travel date'.tr;
      case ReportDateField.cancelOn:
        return 'Cancel on'.tr;
      case ReportDateField.voidOn:
        return 'Void on'.tr;
    }
  }

  String _periodLabel(ReportPeriod p) {
    switch (p) {
      case ReportPeriod.withinDay:
        return 'Within day'.tr;
      case ReportPeriod.untilDay:
        return 'Until day'.tr;
      case ReportPeriod.withinMonth:
        return 'Within month'.tr;
      case ReportPeriod.withinRange:
        return 'Within range'.tr;
    }
  }

  String _formatPickedDate(DateTime? d) {
    if (d == null) return 'Select date'.tr;
    final s = DateFormat('EEEE, dd - MMMM - yyyy', AppVars.lang).format(d);
    return AppFuns.replaceArabicNumbers(s);
  }

  String _monthName(int month) {
    final s = DateFormat('MMMM', AppVars.lang).format(DateTime(2026, month, 1));
    return AppFuns.replaceArabicNumbers(s);
  }

  void _onSearchPressed(ReportDateField safeDateField) {
    setState(() => hasSearched = true);

    final state = SearchAndFilterState(
      applied: true,
      keyword: keywordCtrl.text.trim(),
      dateField: safeDateField,
      period: period,
      singleDate: (period == ReportPeriod.withinDay || period == ReportPeriod.untilDay) ? singleDate : null,
      year: (period == ReportPeriod.withinMonth) ? selectedYear : null,
      month: (period == ReportPeriod.withinMonth) ? selectedMonth : null,
      from: (period == ReportPeriod.withinRange) ? rangeFrom : null,
      to: (period == ReportPeriod.withinRange) ? rangeTo : null,
    );

    widget.onSearch?.call(state);
    widget.tileController.collapse();
  }

  void _onCancelSearchPressed(ReportDateField safeDateField) {
    setState(() {
      _resetToDefaults(clearKeyword: true);
    });

    // ممكن ترجع state applied=false إذا تحب
    widget.onCancel?.call();
    widget.onSearch?.call(
      SearchAndFilterState(
        applied: false,
        keyword: '',
        dateField: safeDateField,
        period: period,
        singleDate: (period == ReportPeriod.withinDay || period == ReportPeriod.untilDay) ? singleDate : null,
        year: (period == ReportPeriod.withinMonth) ? selectedYear : null,
        month: (period == ReportPeriod.withinMonth) ? selectedMonth : null,
        from: (period == ReportPeriod.withinRange) ? rangeFrom : null,
        to: (period == ReportPeriod.withinRange) ? rangeTo : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allowedDateFields = _allowedDateFields();
    final safeDateField = allowedDateFields.contains(dateField) ? dateField : ReportDateField.createdAt;

    // withinMonth dropdown safe lists
    final years = _yearsList();
    if (!years.contains(selectedYear)) {
      selectedYear = years.first;
    }
    _clampMonthIfNeeded();
    final months = _monthsForYear(selectedYear);
    if (!months.contains(selectedMonth)) {
      selectedMonth = months.last;
    }

    // ensure defaults exist per current period
    if (period == ReportPeriod.withinDay || period == ReportPeriod.untilDay) {
      singleDate ??= _todayOnly();
    }
    if (period == ReportPeriod.withinRange) {
      rangeFrom ??= _todayOnly();
      rangeTo ??= _todayOnly();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Filter by date
          DropdownButtonFormField<ReportDateField>(
            value: safeDateField,
            decoration: InputDecoration(labelText: 'Filter by date'.tr),
            items: allowedDateFields
                .map((f) => DropdownMenuItem(value: f, child: Text(_dateFieldLabel(f))))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                dateField = v;
                _resetToDefaults(); // ✅ رجّع التواريخ لليوم الحالي
              });
            },
          ),

          const SizedBox(height: 12),

          // Period
          DropdownButtonFormField<ReportPeriod>(
            value: period,
            decoration: InputDecoration(labelText: 'Period'.tr),
            items: ReportPeriod.values
                .map((p) => DropdownMenuItem(value: p, child: Text(_periodLabel(p))))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                period = v;
                _resetToDefaults(); // ✅ رجّع التواريخ لليوم الحالي حسب الفترة
              });
            },
          ),

          const SizedBox(height: 12),

          // Dynamic fields
          if (period == ReportPeriod.withinDay || period == ReportPeriod.untilDay) ...[
            _DatePickerField(
              label: 'Select date'.tr,
              value: _formatPickedDate(singleDate),
              onTap: _pickSingleDate,
            ),
          ],

          if (period == ReportPeriod.withinMonth) ...[
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedYear,
                    decoration: InputDecoration(labelText: 'Year'.tr),
                    items: years
                        .map((y) => DropdownMenuItem<int>(
                              value: y,
                              child: Text(AppFuns.replaceArabicNumbers(y.toString())),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        selectedYear = v;
                        _clampMonthIfNeeded();
                        hasSearched = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedMonth,
                    decoration: InputDecoration(labelText: 'Month'.tr),
                    items: _monthsForYear(selectedYear)
                        .map((m) => DropdownMenuItem<int>(
                              value: m,
                              child: Text(_monthName(m)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        selectedMonth = v;
                        hasSearched = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],

          if (period == ReportPeriod.withinRange) ...[
            _DatePickerField(
              label: 'From'.tr,
              value: _formatPickedDate(rangeFrom),
              onTap: _pickRangeFrom,
            ),
            const SizedBox(height: 12),
            _DatePickerField(
              label: 'To'.tr,
              value: _formatPickedDate(rangeTo),
              onTap: _pickRangeTo,
            ),
          ],

          const SizedBox(height: 12),

          // Global search
          TextFormField(
            controller: keywordCtrl,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Global search'.tr,
              hintText: 'Type keyword...'.tr,
            ),
            onFieldSubmitted: (_) => _onSearchPressed(safeDateField),
          ),


          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _onSearchPressed(safeDateField),
                  child: Text('Search'.tr),
                ),
              ),
              if (hasSearched) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onCancelSearchPressed(safeDateField),
                    child: Text('Cancel search'.tr),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value),
      ),
    );
  }
}
