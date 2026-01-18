import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';

enum ReportDateField { createdAt, travelDate, cancelOn, voidOn }
enum ReportPeriod { withinDay, untilDay, withinMonth, withinRange }

class SearchAndFilterState {
  final bool applied;
  final BookingStatus? status; // ✅ new
  final String keyword;

  final ReportDateField dateField;
  final ReportPeriod period;

  final DateTime? singleDate;
  final int? year;
  final int? month;

  final DateTime? from;
  final DateTime? to;

  const SearchAndFilterState({
    required this.applied,
    required this.status,
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
  final ExpansionTileController tileController;
  final void Function(SearchAndFilterState state)? onSearch;

  const SearchAndFilter({
    super.key,
    required this.tileController,
    this.onSearch,
  });

  @override
  State<SearchAndFilter> createState() => _SearchAndFilterState();
}

class _SearchAndFilterState extends State<SearchAndFilter> {
  final TextEditingController keywordCtrl = TextEditingController();

  BookingStatus? selectedStatus; // ✅ يبدأ فارغ

  ReportDateField dateField = ReportDateField.createdAt;
  ReportPeriod period = ReportPeriod.withinDay;

  DateTime? singleDate;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  DateTime? rangeFrom;
  DateTime? rangeTo;

  // ---- status options (مثل السابق) ----
  static BookingStatus _pickStatus(List<String> values) {
    for (final v in values) {
      final s = BookingStatus.fromJson(v);
      if (s != BookingStatus.notFound) return s;
    }
    return BookingStatus.notFound;
  }

  late final List<_StatusOption> statusOptions = <_StatusOption>[
    _StatusOption(_pickStatus(['pre-book']), 'Pre-book'),
    _StatusOption(_pickStatus(['confirmed']), 'Confirmed'),
    _StatusOption(_pickStatus(['cancelled', 'canceled']), 'Cancelled'),
    _StatusOption(_pickStatus(['void', 'voided']), 'Void'),
  ].where((e) => e.status != BookingStatus.notFound).toList();

  // ---------- status helpers ----------
  bool get _isCancelledStatus {
    final v = selectedStatus?.apiValue;
    return v == 'cancelled' || v == 'canceled';
  }

  bool get _isVoidStatus {
    final v = selectedStatus?.apiValue;
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

    singleDate = null;
    rangeFrom = null;
    rangeTo = null;

    final now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;

    _applyDefaultDatesForCurrentPeriod();
  }

  // ---------- constraints ----------
  DateTime get _singleLastDate => _todayOnly();
  DateTime get _rangeLastDate => _todayOnly();

  List<int> _yearsList() {
    final nowYear = DateTime.now().year;
    return List.generate(21, (i) => nowYear - i);
  }

  List<int> _monthsForYear(int year) {
    final now = DateTime.now();
    final maxMonth = (year == now.year) ? now.month : 12;
    return List.generate(maxMonth, (i) => i + 1);
  }

  void _clampMonthIfNeeded() {
    final months = _monthsForYear(selectedYear);
    if (!months.contains(selectedMonth)) {
      selectedMonth = months.last;
    }
  }

  @override
  void initState() {
    super.initState();
    _applyDefaultDatesForCurrentPeriod();
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
      lastDate: _rangeLastDate,
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
    final state = SearchAndFilterState(
      applied: true,
      status: selectedStatus,
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

  @override
  Widget build(BuildContext context) {
    final allowedDateFields = _allowedDateFields();
    final safeDateField = allowedDateFields.contains(dateField) ? dateField : ReportDateField.createdAt;

    final years = _yearsList();
    if (!years.contains(selectedYear)) {
      selectedYear = years.first;
    }
    _clampMonthIfNeeded();
    final months = _monthsForYear(selectedYear);
    if (!months.contains(selectedMonth)) {
      selectedMonth = months.last;
    }

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

          // ✅ Status (required)
          DropdownButtonFormField<BookingStatus>(
            value: selectedStatus,
            decoration: InputDecoration(labelText: 'Status'.tr),
            hint: Text('Select status'.tr),
            items: statusOptions
                .map((o) => DropdownMenuItem(value: o.status, child: Text(o.label.tr)))
                .toList(),
            onChanged: (v) {
              setState(() {
                selectedStatus = v;
                _resetToDefaults();
              });
            },
          ),

          const SizedBox(height: 12),

          // Filter by date
          // DropdownButtonFormField<ReportDateField>(
          //   value: safeDateField,
          //   decoration: InputDecoration(labelText: 'Filter by date'.tr),
          //   items: allowedDateFields
          //       .map((f) => DropdownMenuItem(value: f, child: Text(_dateFieldLabel(f))))
          //       .toList(),
          //   onChanged: (v) {
          //     if (v == null) return;
          //     setState(() {
          //       dateField = v;
          //       _resetToDefaults();
          //     });
          //   },
          // ),

          // const SizedBox(height: 12),

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
                _resetToDefaults();
              });
            },
          ),

          const SizedBox(height: 12),

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
            onFieldSubmitted: (_) {
              if (selectedStatus == null) return;
              _onSearchPressed(safeDateField);
            },
          ),

          const SizedBox(height: 16),

          // ✅ Search only (no cancel)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedStatus == null ? null : () => _onSearchPressed(safeDateField),
              child: Text('Search'.tr),
            ),
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

class _StatusOption {
  final BookingStatus status;
  final String label;
  const _StatusOption(this.status, this.label);
}
