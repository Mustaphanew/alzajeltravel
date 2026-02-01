import 'dart:async';
import 'dart:math';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class MyLottie extends StatelessWidget {
  const MyLottie({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Get.context?.theme.colorScheme;
    final gifColor = Get.context?.theme.brightness == Brightness.light ? AppConsts.primaryColor : AppConsts.secondaryColor;
    final txtColor = Get.context?.theme.brightness == Brightness.light ? Colors.black : Colors.white;
    return Directionality(
      textDirection: AppVars.lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: cs!.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox.shrink(), 
            DualRotatingRings(
              outerSize: MediaQuery.of(context).size.width * 0.90,   // عدّل حسب حجم صورتك
              innerSize: MediaQuery.of(context).size.width * 0.75,
              outerStroke: 12,
              innerStroke: 10,
              outerDuration: const Duration(milliseconds: 2000), // سريع
              innerDuration: const Duration(milliseconds: 1500), // أسرع شوي
              innerReverse: true,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cs.onInverseSurface,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(8, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.asset(
                    AppConsts.plnGif, 
                    // color: gifColor,
                  ),
                ),
              ),
            ),
      
            SizedBox.shrink(),
      
            
            Column(
              children: [
                Text(
                  "Search for flights".tr,
                  style: TextStyle(
                    fontFamily: AppConsts.font,
                    color: txtColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 16),
      
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cs.onInverseSurface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NhPulseIcon(
                            size: 40,
                            scale: 0.9,      // يعطيك 32px
                            dotSize: 14,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Please wait".tr,
                                style: TextStyle(
                                  fontFamily: AppConsts.font,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: cs.primaryFixed,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "The process may take several seconds".tr,
                                style: TextStyle(
                                  fontFamily: AppConsts.font,
                                  color: cs.primaryFixed,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      GetBuilder<FakeDownloadController>(
                        init: FakeDownloadController(
                          curve: Curves.easeOutCubic,
                          totalDuration: const Duration(seconds: 10),
                        )..start(),
                        builder: (c) => GradientLinearProgress(
                          value: c.progress,
                          // مطابق للصورة (كحلي -> ذهبي). لو تبي العكس بدّلهم.
                          startColor: cs.secondary,
                          endColor: cs.primary,
                          
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Do not close the page, you will be redirected automatically.".tr,
                  style: TextStyle(
                    fontFamily: AppConsts.font,
                    color: txtColor,
                    fontSize: 12,
                  ),
                ),       
              ],
            ),
            SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}




class GradientLinearProgress extends StatefulWidget {
  const GradientLinearProgress({
    super.key,
    required this.value, // 0.0 -> 1.0
    this.height = 14,
    this.radius = 999,
    required this.startColor,
    required this.endColor,
    this.trackColor,
    this.borderColor,
    this.borderWidth = 1,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 450),
  });

  final double value;
  final double height;
  final double radius;

  final Color startColor;
  final Color endColor;

  final Color? trackColor;
  final Color? borderColor;
  final double borderWidth;

  final bool animate;
  final Duration animationDuration;

  @override
  State<GradientLinearProgress> createState() => _GradientLinearProgressState();
}

class _GradientLinearProgressState extends State<GradientLinearProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late Animation<double> _anim;

  double _shown = 0.0; // القيمة المعروضة (آخر قيمة وصلت لها)

  @override
  void initState() {
    super.initState();
    _shown = widget.value.clamp(0.0, 1.0);
    _ac = AnimationController(vsync: this, duration: widget.animationDuration);
    _anim = AlwaysStoppedAnimation(_shown);
  }

  @override
  void didUpdateWidget(covariant GradientLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    final target = widget.value.clamp(0.0, 1.0);

    if (!widget.animate) {
      _ac.stop();
      _shown = target;
      _anim = AlwaysStoppedAnimation(_shown);
      setState(() {});
      return;
    }

    if (target == _shown) return;

    _ac.duration = widget.animationDuration;
    _anim = Tween<double>(begin: _shown, end: target).animate(
      CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic),
    );

    _ac
      ..stop()
      ..reset()
      ..forward();

    _ac.addListener(() {
      setState(() {
        _shown = _anim.value;
      });
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.trackColor ?? Theme.of(context).colorScheme.surface;
    final border = widget.borderColor ?? Theme.of(context).dividerColor;

    final progress = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [widget.startColor, widget.endColor],
        ),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: track,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: border, width: widget.borderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Padding(
          padding: EdgeInsets.all(widget.borderWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Color(0xFFecebe9)),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: _shown,
                    heightFactor: 1,
                    alignment: AlignmentDirectional.centerStart,
                    child: progress,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FakeDownloadController extends GetxController {
  FakeDownloadController({
    this.totalDuration = const Duration(seconds: 10),
    this.curve = Curves.easeOutCubic, // سريع بالبداية ثم يتباطأ
  });

  final Duration totalDuration;
  final Curve curve;

  final _r = Random();
  final Stopwatch _sw = Stopwatch();

  double progress = 0.0;
  bool isRunning = false;

  Timer? _timer;

  void start() {
    stop();
    progress = 0.0;
    isRunning = true;
    update();

    _sw
      ..reset()
      ..start();

    _scheduleNextTick();
  }

  void stop() {
    isRunning = false;
    _timer?.cancel();
    _timer = null;
    if (_sw.isRunning) _sw.stop();
    update();
  }

  void complete() {
    progress = 1;
    stop();
    update();
  }

  void _scheduleNextTick() {
    if (!isRunning) return;

    final elapsedMs = _sw.elapsedMilliseconds;
    final totalMs = totalDuration.inMilliseconds;

    if (elapsedMs >= totalMs) {
      complete();
      return;
    }

    // time ratio [0..1]
    final t = (elapsedMs / totalMs).clamp(0.0, 1.0);

    // سقف تقدّم حسب الوقت (fast -> slow) مع ترك 1% للنهاية
    final timeCap = (curve.transform(t) * 0.99).clamp(0.0, 0.99);

    final p = progress;

    // نفس أسلوبك: رينجات مختلفة حسب المرحلة
    int delayMin, delayMax;
    double deltaMin, deltaMax;
    double stallProb;

    if (p < 0.15) {
      delayMin = 60;  delayMax = 140;
      deltaMin = 0.010; deltaMax = 0.030;
      stallProb = 0.03;
    } else if (p < 0.70) {
      delayMin = 80;  delayMax = 180;
      deltaMin = 0.006; deltaMax = 0.020;
      stallProb = 0.05;
    } else if (p < 0.92) {
      delayMin = 110; delayMax = 220;
      deltaMin = 0.003; deltaMax = 0.012;
      stallProb = 0.10;
    } else {
      delayMin = 160; delayMax = 320;
      deltaMin = 0.001; deltaMax = 0.006;
      stallProb = 0.18;
    }

    // لو متقدم على الوقت (تجاوز السقف) نخليه يوقف شوي عشان ما يخلص بدري
    final aheadOfTime = p > timeCap + 0.01;

    int delay = _randInt(delayMin, delayMax);

    // لا تسمح بتأخير يتجاوز الوقت المتبقي
    final remainingMs = totalMs - elapsedMs;
    if (delay > remainingMs) delay = remainingMs;

    final stall = aheadOfTime || (_r.nextDouble() < stallProb);

    if (stall) {
      // توقفات "واقعية" لكن ضمن الوقت المتبقي
      final extra = _randInt(150, 650);
      final newDelay = delay + extra;
      delay = newDelay > remainingMs ? remainingMs : newDelay;
    } else {
      var delta = _randDouble(deltaMin, deltaMax);

      // إذا متأخر عن السقف (behind) نخليه “يلحق” بسلاسة بدون قفزات كبيرة
      final lag = timeCap - p;
      if (lag > 0.03) {
        delta = max(delta, lag * _randDouble(0.35, 0.75));
      }

      // لا تتجاوز السقف (ولا تتجاوز 0.99)
      final upperCap = min(timeCap + 0.012, 0.99);
      progress = min(p + delta, upperCap);
      update();
    }

    _timer = Timer(Duration(milliseconds: delay), _scheduleNextTick);
  }

  int _randInt(int min, int max) => min + _r.nextInt(max - min + 1);
  double _randDouble(double min, double max) => min + _r.nextDouble() * (max - min);
}




// two progress rings


/// ====== Helper: build segments contiguously (no gaps in angles) ======
List<RingSegment> buildContiguousSegments({
  required double startDeg,
  required List<double> sweepsDeg,
  required List<Color> colors,
}) {
  assert(sweepsDeg.length == colors.length);

  var cur = startDeg % 360;
  final out = <RingSegment>[];

  for (var i = 0; i < sweepsDeg.length; i++) {
    out.add(RingSegment(
      startDeg: cur,
      sweepDeg: sweepsDeg[i],
      color: colors[i],
    ));
    cur = (cur + sweepsDeg[i]) % 360;
  }

  return out;
}

/// ====== Segment model ======
class RingSegment {
  const RingSegment({
    required this.startDeg, // 0..360
    required this.sweepDeg, // arc length
    required this.color,
  });

  final double startDeg;
  final double sweepDeg;
  final Color color;
}

/// ====== Rotating ring widget ======
class RotatingSegmentRing extends StatelessWidget {
  const RotatingSegmentRing({
    super.key,
    required this.size,
    required this.strokeWidth,
    required this.segments,
    required this.turns,
    this.shadowBlur = 0,
    this.shadowOpacity = 0.0,

    /// مهم لإزالة خطوط/فراغات دقيقة بين الألوان
    /// جرّب 0.6 إلى 1.2 حسب ما يناسبك
    this.overlapDeg = 0.9,
  });

  final double size;
  final double strokeWidth;
  final List<RingSegment> segments;
  final Animation<double> turns;

  final double shadowBlur;
  final double shadowOpacity;

  final double overlapDeg;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RotationTransition(
        turns: turns,
        child: CustomPaint(
          size: Size.square(size),
          painter: _SegmentRingPainter(
            strokeWidth: strokeWidth,
            segments: segments,
            shadowBlur: shadowBlur,
            shadowOpacity: shadowOpacity,
            overlapDeg: overlapDeg,
          ),
        ),
      ),
    );
  }
}

/// ====== Painter ======
class _SegmentRingPainter extends CustomPainter {
  _SegmentRingPainter({
    required this.strokeWidth,
    required this.segments,
    required this.shadowBlur,
    required this.shadowOpacity,
    required this.overlapDeg,
  });

  final double strokeWidth;
  final List<RingSegment> segments;

  final double shadowBlur;
  final double shadowOpacity;

  final double overlapDeg;

  double _degToRad(double deg) => deg * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    // Shadow خفيف اختياري
    if (shadowOpacity > 0 && shadowBlur > 0) {
      final shadowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withOpacity(shadowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);

      canvas.drawArc(rect, 0, math.pi * 2, false, shadowPaint);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // نبدأ من أعلى
    const baseShift = -90.0;

    // Overlap بسيط لإزالة أي خطوط دقيقة بين الألوان (anti-aliasing)
    final overlapRad = _degToRad(overlapDeg);

    for (final s in segments) {
      paint.color = s.color;

      // نوسع القوس قليلًا حتى ما يبان فراغ رفيع
      final start = _degToRad(s.startDeg + baseShift) - overlapRad / 2;
      final sweep = _degToRad(s.sweepDeg) + overlapRad;

      canvas.drawArc(rect, start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentRingPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.shadowBlur != shadowBlur ||
        oldDelegate.shadowOpacity != shadowOpacity ||
        oldDelegate.overlapDeg != overlapDeg ||
        oldDelegate.segments != segments;
  }
}

/// ====== Two rings wrapper ======
class DualRotatingRings extends StatefulWidget {
  const DualRotatingRings({
    super.key,
    required this.child,
    this.outerSize = 300,
    this.innerSize = 250,
    this.outerStroke = 12,
    this.innerStroke = 10,
    this.outerDuration = const Duration(milliseconds: 1600),
    this.innerDuration = const Duration(milliseconds: 1200),
    this.innerReverse = true,

    // لو احتجت تقليل/زيادة تلاصق الألوان
    this.outerOverlapDeg = 0.9,
    this.innerOverlapDeg = 0.9,
  });

  final Widget child;

  final double outerSize;
  final double innerSize;
  final double outerStroke;
  final double innerStroke;

  final Duration outerDuration;
  final Duration innerDuration;
  final bool innerReverse;

  final double outerOverlapDeg;
  final double innerOverlapDeg;

  @override
  State<DualRotatingRings> createState() => _DualRotatingRingsState();
}

class _DualRotatingRingsState extends State<DualRotatingRings>
    with TickerProviderStateMixin {
  late final AnimationController _outer;
  late final AnimationController _inner;

  @override
  void initState() {
    super.initState();

    _outer = AnimationController(vsync: this, duration: widget.outerDuration)
      ..repeat();

    _inner = AnimationController(vsync: this, duration: widget.innerDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _outer.dispose();
    _inner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ===== Outer colors =====
    // const outerAmber = Colors.amber;
    const outer2 = Color(0xFFd9b258);
    const outer3 = Color(0xFFebe1c7);
    const outer4 = Color(0xFFf6f2e7);

    // ===== Inner colors =====
    const inner1 = Color(0xFF1f2453); // navy
    const inner2 = Color(0xFFb6b9c7);
    const inner3 = Color(0xFFdbdde3);

    // ===== Segments: متلاصقة تلقائيًا =====
    // Outer: 4 ألوان متتابعة
    final outerSegments = buildContiguousSegments(
      startDeg: 205,
      // عدّل الأطوال لو تبغى تطابق الصورة أكثر
      sweepsDeg: const [90, 80, 70],
      colors: const [outer2, outer3, outer4],
    );

    // Inner: 3 ألوان متتابعة
    final innerSegments = buildContiguousSegments(
      startDeg: 300,
      sweepsDeg: const [70, 60, 50],
      colors: const [inner1, inner2, inner3],
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        RotatingSegmentRing(
          size: widget.outerSize,
          strokeWidth: widget.outerStroke,
          segments: outerSegments,
          turns: _outer,
          shadowBlur: 8,
          shadowOpacity: 0.04,
          overlapDeg: widget.outerOverlapDeg,
        ),
        RotatingSegmentRing(
          size: widget.innerSize,
          strokeWidth: widget.innerStroke,
          segments: innerSegments,
          turns: widget.innerReverse ? ReverseAnimation(_inner) : _inner,
          shadowBlur: 6,
          shadowOpacity: 0.03,
          overlapDeg: widget.innerOverlapDeg,
        ),
        widget.child,
      ],
    );
  }
}



// NhPulseIcon 

class NhPulseIcon extends StatelessWidget {
  const NhPulseIcon({
    super.key,
    this.size = 32,         // مثل 40px * 0.8 = 32
    this.scale = 1.0,       // لو تبي تحاكي --loaderScale
    this.dotSize = 14,      // عدّلها حسب رغبتك
    this.dotColor = const Color(0xFFD9B258), // نفس النقطة الذهبية بالصورة
  });

  final double size;
  final double scale;

  final double dotSize;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final s = size * scale;

    // CSS: border-radius: 14px على 40px => نسبة 0.35
    final radius = s * 0.35;

    // CSS: border: 1px solid rgba(5, 32, 90, .14)
    const borderColor = Color.fromRGBO(5, 32, 90, 0.14);

    // CSS radial-gradient(circle at 30% 20%, white95%, navy08%)
    // تحويل (30%, 20%) إلى Alignment: x = 0.3*2-1=-0.4 ، y=0.2*2-1=-0.6
    const gradientCenter = Alignment(-0.4, -0.6);

    return SizedBox(
      width: s,
      height: s,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: 1),
          gradient: const RadialGradient(
            center: gradientCenter,
            radius: 1.2,
            colors: [
              Color.fromRGBO(255, 255, 255, 0.95),
              Color.fromRGBO(154, 172, 226, 0.078),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: dotSize * scale,
            height: dotSize * scale,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
