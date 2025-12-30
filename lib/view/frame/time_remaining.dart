import 'dart:async';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/material.dart';

class TimeRemaining extends StatefulWidget {
  final DateTime? timeLimit;

  /// التحكم في شكل الرقم والحرف والفاصل
  final TextStyle? numberStyle;
  final TextStyle? unitStyle;
  final TextStyle? separatorStyle;

  /// مسافة صغيرة بين الرقم والحرف
  final double gap;

  /// نص عند الانتهاء أو null
  final String expiredText;

  /// لو true يعرض 00 بدل expiredText
  final bool showExpiredAsZeros;

  const TimeRemaining({
    super.key,
    required this.timeLimit,
    this.numberStyle,
    this.unitStyle,
    this.separatorStyle,
    this.gap = 2,
    this.expiredText = 'Expired',
    this.showExpiredAsZeros = true,
  });

  @override
  State<TimeRemaining> createState() => _TimeRemainingState();
}

class _TimeRemainingState extends State<TimeRemaining> {
  Timer? _timer;
  late Map<String, String> _parts;
  late bool _expired;

  @override
  void initState() {
    super.initState();
    _recalc();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant TimeRemaining oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeLimit != widget.timeLimit) {
      _recalc();
      _restartTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final before = _parts;
      final beforeExpired = _expired;

      _recalc();

      // لا تعمل setState إلا إذا تغيرت القيم فعلاً
      if (mounted && (beforeExpired != _expired || !_mapEquals(before, _parts))) {
        setState(() {});
      }

      // أوقف المؤقت عند انتهاء العدّاد (لتوفير الموارد)
      if (_expired) {
        _timer?.cancel();
      }
    });
  }

  void _restartTimer() => _startTimer();

  void _recalc() {
    final tl = widget.timeLimit;
    if (tl == null) {
      _expired = true;
      _parts = widget.showExpiredAsZeros
          ? const {'d': '00', 'h': '00', 'm': '00'}
          : const {'d': '--', 'h': '--', 'm': '--'};
      return;
    }

    final diff = tl.difference(DateTime.now());
    if (diff.isNegative || diff.inSeconds <= 0) {
      _expired = true;
      _parts = widget.showExpiredAsZeros
          ? const {'d': '00', 'h': '00', 'm': '00'}
          : const {'d': '--', 'h': '--', 'm': '--'};
      return;
    }

    _expired = false;

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    _parts = {
      'd': days.toString().padLeft(2, '0'),
      'h': hours.toString().padLeft(2, '0'),
      'm': minutes.toString().padLeft(2, '0'),
    };
  }

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _segment({
    required String value,
    required String unit,
    required TextStyle numberStyle,
    required TextStyle unitStyle,
    required double gap,
  }) {

    if(AppVars.lang == 'ar') {
      if(unit.toLowerCase() == 'd') {
        unit = 'ي';
      }else if(unit.toLowerCase() == 'h') {
        unit = 'س';
      }else if(unit.toLowerCase() == 'm') {
        unit = 'د';
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: numberStyle),
        SizedBox(width: gap),
        Text(unit, style: unitStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final numberStyle = widget.numberStyle ??
        const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.0,
        );

    final unitStyle = widget.unitStyle ??
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.0,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        );

    final separatorStyle = widget.separatorStyle ??
        TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        );

    // لو انتهى ولم ترغب بالأصفار اعرض نص منتهي
    if (_expired && !widget.showExpiredAsZeros) {
      return Text(widget.expiredText, style: unitStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _segment(
          value: _parts['d'] ?? '00',
          unit: 'D',
          numberStyle: numberStyle,
          unitStyle: unitStyle,
          gap: widget.gap,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(':', style: separatorStyle),
        ),
        _segment(
          value: _parts['h'] ?? '00',
          unit: 'H',
          numberStyle: numberStyle,
          unitStyle: unitStyle,
          gap: widget.gap,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(':', style: separatorStyle),
        ),
        _segment(
          value: _parts['m'] ?? '00',
          unit: 'M',
          numberStyle: numberStyle,
          unitStyle: unitStyle,
          gap: widget.gap,
        ),
      ],
    );
  }
}
