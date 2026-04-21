import 'dart:async';

import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:get/get.dart';

class TimeRemaining extends StatefulWidget {
  final DateTime? timeLimit;
  final DateTime? createdAt;

  final bool showExpiredAsZeros;
  final String expiredText;

  final double radius;
  final double lineWidth;
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
    if (oldWidget.timeLimit != widget.timeLimit ||
        oldWidget.createdAt != widget.createdAt) {
      _recalc();
      _restartTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final before =
          (_expired, _days, _hours, _minutes, _seconds, _percentRemaining);
      _recalc();
      final after =
          (_expired, _days, _hours, _minutes, _seconds, _percentRemaining);

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
    _days = 0;
    _hours = 0;
    _minutes = 0;
    _seconds = 0;
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
    final locale = AppVars.lang;
    final f = withTime
        ? DateFormat('EEE, dd - MMM - yyyy  h:mm a', locale)
        : DateFormat('EEE, dd - MMM - yyyy', locale);
    return f.format(d);
  }

  Widget _timeBox({
    required String value,
    required String label,
    required double size,
    required ColorScheme cs,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size + 8,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConsts.secondaryColor,
                Color(0xFFD99C2F),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppConsts.primaryColor.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppConsts.secondaryColor.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            AppFuns.replaceArabicNumbers(value),
            style: const TextStyle(
              color: AppConsts.primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.0,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (_expired && !widget.showExpiredAsZeros) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cs.error.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 18, color: cs.error),
                const SizedBox(width: 6),
                Text(
                  widget.expiredText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cs.error,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          bookingDateTimes(cs, isDark),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.radius * 2 + widget.lineWidth,
              height: widget.radius * 2 + widget.lineWidth,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConsts.secondaryColor.withValues(alpha: 0.18),
                    AppConsts.secondaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            CircularPercentIndicator(
              radius: widget.radius,
              lineWidth: widget.lineWidth,
              percent: _percentRemaining,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppConsts.primaryColor.withValues(alpha: 0.08),
              progressColor: AppConsts.secondaryColor,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFuns.replaceArabicNumbers('$_days'),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      color: cs.onSurface,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'days left'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _timeBox(
              value: _two(_hours),
              label: 'Hours'.tr,
              size: widget.boxSize,
              cs: cs,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _timeBox(
              value: _two(_minutes),
              label: 'Minutes'.tr,
              size: widget.boxSize,
              cs: cs,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _timeBox(
              value: _two(_seconds),
              label: 'Seconds'.tr,
              size: widget.boxSize,
              cs: cs,
              isDark: isDark,
            ),
          ],
        ),

        const SizedBox(height: 22),

        bookingDateTimes(cs, isDark),

        const SizedBox(height: 6),
      ],
    );
  }

  Widget bookingDateTimes(ColorScheme cs, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          width: 140,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConsts.secondaryColor.withValues(alpha: 0),
                AppConsts.secondaryColor.withValues(alpha: 0.55),
                AppConsts.secondaryColor.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_note_rounded,
              size: 16,
              color: AppConsts.secondaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Time Deadline'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppFuns.replaceArabicNumbers(
                _formatDate(widget.timeLimit, withTime: true)),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
