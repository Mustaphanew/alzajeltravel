import 'dart:async';

import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:get/get.dart';

class TimeRemaining extends StatefulWidget {
  final DateTime? timeLimit; // Deadline
  final DateTime? createdAt;

  /// لو true يعرض 00 بدل expiredText
  final bool showExpiredAsZeros;

  /// نص عند الانتهاء
  final String expiredText;

  /// حجم الدائرة
  final double radius;

  /// سماكة خط الدائرة
  final double lineWidth;

  /// حجم مربعات الوقت
  final double boxSize;

  const TimeRemaining({
    super.key,
    required this.timeLimit,
    required this.createdAt,
    this.showExpiredAsZeros = true,
    this.expiredText = 'Expired',
    this.radius = 65,
    this.lineWidth = 14,
    this.boxSize = 70,
  });

  @override
  State<TimeRemaining> createState() => _TimeRemainingState();
}

class _TimeRemainingState extends State<TimeRemaining> {
  Timer? _timer;

  late bool _expired;
  late int _days;
  late int _hours;
  late int _minutes;
  late int _seconds;
  late double _percentRemaining;

  @override
  void initState() {
    super.initState();
    _recalc();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant TimeRemaining oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeLimit != widget.timeLimit || oldWidget.createdAt != widget.createdAt) {
      _recalc();
      _restartTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final before = (_expired, _days, _hours, _minutes, _seconds, _percentRemaining);
      _recalc();
      final after = (_expired, _days, _hours, _minutes, _seconds, _percentRemaining);

      if (mounted && before != after) {
        setState(() {});
      }

      if (_expired) {
        _timer?.cancel();
      }
    });
  }

  void _restartTimer() => _startTimer();

  void _recalc() {
    final tl = widget.timeLimit;
    final ca = widget.createdAt;

    if (tl == null) {
      _setExpired();
      return;
    }

    final now = DateTime.now();
    final diff = tl.difference(now);

    if (diff.inSeconds <= 0) {
      _setExpired();
      return;
    }

    _expired = false;

    _days = diff.inDays;
    _hours = diff.inHours % 24;
    _minutes = diff.inMinutes % 60;
    _seconds = diff.inSeconds % 60;

    // نسبة المتبقي (Remaining / Total)
    if (ca == null) {
      _percentRemaining = 0;
    } else {
      final total = tl.difference(ca).inSeconds;
      if (total <= 0) {
        _percentRemaining = 0;
      } else {
        final remaining = diff.inSeconds.clamp(0, total);
        _percentRemaining = (remaining / total).clamp(0.0, 1.0);
      }
    }
  }

  void _setExpired() {
    _expired = true;
    if (widget.showExpiredAsZeros) {
      _days = 0;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    } else {
      _days = 0;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    }
    _percentRemaining = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  String _formatDate(DateTime? d, {bool withTime = false}) {
    if (d == null) return '--';
    final locale = AppVars.lang; // 'ar' / 'en'
    final f = withTime ? DateFormat('EEE, dd - MMM - yyyy  h:mm a', locale) : DateFormat('EEE, dd - MMM - yyyy', locale);
    return f.format(d);
  }

  Widget _timeBox({required String value, required String label, required double size, required ColorScheme cs}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size + 8,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: cs.secondary, borderRadius: BorderRadius.circular(12)),
          child: Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.0)),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // لو انتهى ولم ترغب بالأصفار اعرض نص منتهي
    if (_expired && !widget.showExpiredAsZeros) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(
            widget.expiredText,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.error),
          ),
          const SizedBox(height: 8),
          bookingDateTimes(),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        SizedBox(
          child: CircularPercentIndicator(
            radius: widget.radius,
            lineWidth: widget.lineWidth,
            percent: _percentRemaining,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: cs.onSurface.withOpacity(0.08),
            progressColor: cs.secondary,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_days',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, height: 1.0, color: cs.onSurface),
                ),
                const SizedBox(height: 6),
                Text('days left'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeBox(value: _two(_hours), label: 'Hours'.tr, size: widget.boxSize, cs: cs),
            const SizedBox(width: 16),
            _timeBox(value: _two(_minutes), label: 'Minutes'.tr, size: widget.boxSize, cs: cs),
            const SizedBox(width: 16),
            _timeBox(value: _two(_seconds), label: 'Seconds'.tr, size: widget.boxSize, cs: cs),
          ],
        ),

        const SizedBox(height: 24),

        bookingDateTimes(),

        const SizedBox(height: 8),
      ],
    );
  }

  IntrinsicWidth bookingDateTimes() {
    return IntrinsicWidth(
      child: Column(
        children: [
          Text('Time Deadline'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppFuns.replaceArabicNumbers(_formatDate(widget.timeLimit, withTime: true)),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(thickness: 2),

          // Text(
          //   'Booking created at'.tr,
          //   style: TextStyle(
          //     fontSize: 16,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Text(
          //     AppFuns.replaceArabicNumbers(_formatDate(widget.createdAt, withTime: true)),
          //     style: TextStyle(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
