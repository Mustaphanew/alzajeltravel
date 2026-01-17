import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:mrz_parser/mrz_parser.dart';
import 'package:path_provider/path_provider.dart';

typedef AttemptCallback = void Function(int attempt, int total, String tag);

class MrzScanException implements Exception {
  final String messageKey;
  MrzScanException(this.messageKey);

  @override
  String toString() => messageKey;
}

class MrzScanService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  void dispose() => _recognizer.close();

  /// ✅ الآن 24 محاولة (12 القديمة + 12 جديدة أقوى)
  Future<Map<String, dynamic>> scanPassport(
    File original, {
    AttemptCallback? onAttempt,
    int maxAttempts = 24,
  }) async {
    final base = await _prepareBase(original);

    final tempFiles = <File>[];
    try {
      // -------------------------------
      // Attempt 1: base full  (كما هو)
      // -------------------------------
      onAttempt?.call(1, maxAttempts, 'base_full');
      final out1 = await _runOcrTryParse(base.baseFile);
      if (out1.parsed != null) {
        final fixed = await _postFixParsedIfNeeded(out1.parsed!);
        return _resultToJson(
          fixed.result,
          fixed.usedLines,
          attempt: 1,
          tag: 'base_full',
        );
      }

      // ---------------------------------------------------------
      // Attempt 2: auto-rect (if possible) else fallback strip BW
      // (كما هو)
      // ---------------------------------------------------------
      onAttempt?.call(2, maxAttempts, 'auto_rect_or_strip_bw');
      final rect = _guessMrzRect(
        out1.recognizedText,
        imageWidth: base.image.width.toDouble(),
        imageHeight: base.image.height.toDouble(),
      );

      final attempt2Spec = _AttemptSpec(
        tag: rect != null ? 'auto_rect_bw' : 'strip_bw_055',
        crop: rect != null
            ? _CropRect(rect)
            : const _CropFrac(x0: 0.0, y0: 0.68, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 230,
        sharpenLevel: 1,
      );

      final attempt2File =
          await _renderAttemptFile(base.image, attempt2Spec, index: 2);
      tempFiles.add(attempt2File);

      final out2 = await _runOcrTryParse(attempt2File);
      if (out2.parsed != null) {
        final fixed = await _postFixParsedIfNeeded(out2.parsed!);
        return _resultToJson(
          fixed.result,
          fixed.usedLines,
          attempt: 2,
          tag: attempt2Spec.tag,
        );
      }

      // -------------------------------
      // Attempts 3..12 (كما هي تماماً)
      // -------------------------------
      final plan10 = _buildPlan10();
      var attemptNo = 3;

      for (final spec in plan10) {
        if (attemptNo > maxAttempts) break;

        onAttempt?.call(attemptNo, maxAttempts, spec.tag);

        final f = await _renderAttemptFile(base.image, spec, index: attemptNo);
        tempFiles.add(f);

        final out = await _runOcrTryParse(f);
        if (out.parsed != null) {
          final fixed = await _postFixParsedIfNeeded(out.parsed!);
          return _resultToJson(
            fixed.result,
            fixed.usedLines,
            attempt: attemptNo,
            tag: spec.tag,
          );
        }
        attemptNo++;
      }

      // ----------------------------------------------------------
      // Attempts 13..24 (12 محاولات جديدة أقوى)
      // مبنية على image_prep.dart:
      //   normalize + sharpen + Otsu + upscale + crops/rotations
      // ----------------------------------------------------------
      final planExtra12 = _buildPlanExtra12();
      for (final spec in planExtra12) {
        if (attemptNo > maxAttempts) break;

        onAttempt?.call(attemptNo, maxAttempts, spec.tag);

        final f = await _renderAttemptFile(base.image, spec, index: attemptNo);
        tempFiles.add(f);

        final out = await _runOcrTryParse(f);
        if (out.parsed != null) {
          final fixed = await _postFixParsedIfNeeded(out.parsed!);
          return _resultToJson(
            fixed.result,
            fixed.usedLines,
            attempt: attemptNo,
            tag: spec.tag,
          );
        }
        attemptNo++;
      }

      throw MrzScanException('Could not extract MRZ.');
    } finally {
      for (final f in tempFiles) {
        try {
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      try {
        if (await base.baseFile.exists()) await base.baseFile.delete();
      } catch (_) {}
    }
  }

  // --------------------------------------------------------------------------
  // Attempts plan (Attempts 3..12)  ✅ كما هي
  // --------------------------------------------------------------------------

  List<_AttemptSpec> _buildPlan10() {
    return const [
      _AttemptSpec(
        tag: 'strip_gray_sharp',
        crop: _CropFrac(x0: 0.0, y0: 0.68, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: false,
        threshold: 0.0,
        contrast: 220,
        sharpenLevel: 1,
      ),
      _AttemptSpec(
        tag: 'strip_bw_055_sharp',
        crop: _CropFrac(x0: 0.0, y0: 0.68, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 1,
      ),
      _AttemptSpec(
        tag: 'strip_bw_045_strong',
        crop: _CropFrac(x0: 0.0, y0: 0.68, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.45,
        contrast: 250,
        sharpenLevel: 2,
      ),
      _AttemptSpec(
        tag: 'tight22_bw_055_strong',
        crop: _CropFrac(x0: 0.0, y0: 0.78, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 250,
        sharpenLevel: 2,
      ),
      _AttemptSpec(
        tag: 'tight20_bw_045_strong',
        crop: _CropFrac(x0: 0.0, y0: 0.80, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.45,
        contrast: 255,
        sharpenLevel: 2,
      ),
      _AttemptSpec(
        tag: 'right_strip_bw_055',
        crop: _CropFrac(x0: 0.30, y0: 0.66, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 1,
      ),
      _AttemptSpec(
        tag: 'right_strip_bw_rot_-2',
        crop: _CropFrac(x0: 0.30, y0: 0.66, x1: 1.0, y1: 1.0),
        rotateDeg: -2,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 1,
      ),
      _AttemptSpec(
        tag: 'right_strip_bw_rot_+2',
        crop: _CropFrac(x0: 0.30, y0: 0.66, x1: 1.0, y1: 1.0),
        rotateDeg: 2,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 1,
      ),
      _AttemptSpec(
        tag: 'strip_bw_rot_-2_strong',
        crop: _CropFrac(x0: 0.0, y0: 0.70, x1: 1.0, y1: 1.0),
        rotateDeg: -2,
        bw: true,
        threshold: 0.55,
        contrast: 255,
        sharpenLevel: 2,
      ),
      _AttemptSpec(
        tag: 'bottom45_bw',
        crop: _CropFrac(x0: 0.0, y0: 0.55, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 1,
      ),
    ];
  }

  // --------------------------------------------------------------------------
  // ✅ Attempts 13..24 (مستوحاة من image_prep.dart و mrz_utils.dart)
  // - normalize (img.normalize)
  // - strong sharpen (مستوى 2/3)
  // - Otsu binarization
  // - Upscale width أكبر (2800)
  // - قص أدق + ميلان بسيط
  // --------------------------------------------------------------------------

  List<_AttemptSpec> _buildPlanExtra12() {
    return const [
      // 13: strip + normalize + otsu + upscale
      _AttemptSpec(
        tag: 'extra_strip_norm_otsu_up2800',
        crop: _CropFrac(x0: 0.0, y0: 0.68, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 230,
        sharpenLevel: 2,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 14: strip tighter + normalize + otsu
      _AttemptSpec(
        tag: 'extra_strip_y072_norm_otsu_up2800',
        crop: _CropFrac(x0: 0.0, y0: 0.72, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 2,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 15: strip x-trim + normalize + otsu (يزيل الحواف المزخرفة)
      _AttemptSpec(
        tag: 'extra_strip_xtrim_norm_otsu_up2800',
        crop: _CropFrac(x0: 0.02, y0: 0.68, x1: 0.98, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 2,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 16: strip x-trim + rotate -1.5
      _AttemptSpec(
        tag: 'extra_strip_xtrim_rot_-15_norm_otsu',
        crop: _CropFrac(x0: 0.02, y0: 0.68, x1: 0.98, y1: 1.0),
        rotateDeg: -1.5,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 2,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 17: strip x-trim + rotate +1.5
      _AttemptSpec(
        tag: 'extra_strip_xtrim_rot_+15_norm_otsu',
        crop: _CropFrac(x0: 0.02, y0: 0.68, x1: 0.98, y1: 1.0),
        rotateDeg: 1.5,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 2,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 18: tighter 25% (MRZ فقط تقريباً)
      _AttemptSpec(
        tag: 'extra_tight25_norm_otsu_up2800',
        crop: _CropFrac(x0: 0.0, y0: 0.75, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 250,
        sharpenLevel: 3,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 19: tighter 18% (قد تنجح مع MRZ القريبة جداً)
      _AttemptSpec(
        tag: 'extra_tight18_norm_otsu_up2800',
        crop: _CropFrac(x0: 0.0, y0: 0.82, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 250,
        sharpenLevel: 3,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 20: right strip + normalize + otsu (للجواز المفتوح)
      _AttemptSpec(
        tag: 'extra_right_norm_otsu_up2800',
        crop: _CropFrac(x0: 0.25, y0: 0.66, x1: 1.0, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 2,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 21: right strip + rotate -2
      _AttemptSpec(
        tag: 'extra_right_rot_-2_norm_otsu',
        crop: _CropFrac(x0: 0.25, y0: 0.66, x1: 1.0, y1: 1.0),
        rotateDeg: -2,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 2,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 22: right strip + rotate +2
      _AttemptSpec(
        tag: 'extra_right_rot_+2_norm_otsu',
        crop: _CropFrac(x0: 0.25, y0: 0.66, x1: 1.0, y1: 1.0),
        rotateDeg: 2,
        bw: true,
        threshold: 0.55,
        contrast: 240,
        sharpenLevel: 2,
        normalize: true,
        otsu: true,
        upscaleWidth: 2800,
      ),

      // 23: fixed threshold 0.50 + normalize (بدون Otsu)
      _AttemptSpec(
        tag: 'extra_strip_norm_fixed_050_up2800',
        crop: _CropFrac(x0: 0.02, y0: 0.68, x1: 0.98, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.50,
        contrast: 250,
        sharpenLevel: 2,
        normalize: true,
        otsu: false,
        upscaleWidth: 2800,
      ),

      // 24: fixed threshold 0.60 + normalize (بدون Otsu)
      _AttemptSpec(
        tag: 'extra_strip_norm_fixed_060_up2800',
        crop: _CropFrac(x0: 0.02, y0: 0.68, x1: 0.98, y1: 1.0),
        rotateDeg: 0,
        bw: true,
        threshold: 0.60,
        contrast: 250,
        sharpenLevel: 2,
        normalize: true,
        otsu: false,
        upscaleWidth: 2800,
      ),
    ];
  }

  // --------------------------------------------------------------------------
  // OCR + Parsing (Safe)
  // --------------------------------------------------------------------------

  Future<_ScanOutcome> _runOcrTryParse(File file) async {
    final inputImage = InputImage.fromFile(file);
    final recognizedText = await _recognizer.processImage(inputImage);

    final orderedRows = _extractOrderedRows(recognizedText);

    final candidateLines = <String>[
      ..._rowsToMrzishLines(orderedRows),
      ..._fallbackLinesFromPlainText(recognizedText.text),
    ];

    final unique = _uniqueKeepOrder(candidateLines);
    final parsed = _tryParseMrzSafe(unique);

    return _ScanOutcome(recognizedText: recognizedText, parsed: parsed);
  }

  _ParsedMrz? _tryParseMrzSafe(List<String> linesTopToBottom) {
    if (linesTopToBottom.isEmpty) return null;

    // 1) Adjacent first (كما كان)
    for (int i = 0; i < linesTopToBottom.length; i++) {
      // TD1 (3x30)
      if (i + 2 < linesTopToBottom.length) {
        final c = [
          _fitToLen(linesTopToBottom[i], 30, preferDocStart: true),
          _fitToLen(linesTopToBottom[i + 1], 30),
          _fitToLen(linesTopToBottom[i + 2], 30),
        ];
        final r = _tryParseWithRepairsSafe(c);
        if (r != null) return _ParsedMrz(r, c);
      }

      // TD2/MRV-B (2x36)
      if (i + 1 < linesTopToBottom.length) {
        final c36 = [
          _fitToLen(linesTopToBottom[i], 36, preferDocStart: true),
          _fitToLen(linesTopToBottom[i + 1], 36),
        ];
        final r36 = _tryParseWithRepairsSafe(c36);
        if (r36 != null) return _ParsedMrz(r36, c36);
      }

      // TD3/MRV-A (2x44)
      if (i + 1 < linesTopToBottom.length) {
        var l1 = _fitToLen(linesTopToBottom[i], 44, preferDocStart: true);
        var l2 = _fitToLen(linesTopToBottom[i + 1], 44);

        // Repairs (givenNames + personal noise + digits)
        l1 = _repairTd3Line1NameDelimiter(l1);
        l1 = _fixNameFieldDigitsToLetters(l1);
        l2 = _cleanTd3Line2PersonalNumberNoise(l2);

        final c44 = [l1, l2];
        final r44 = _tryParseWithRepairsSafe(c44);
        if (r44 != null) return _ParsedMrz(r44, c44);
      }
    }

    // 2) ✅ إضافة منطق mrz_utils.dart: جرب الأزواج غير المتجاورة (يرفع النجاح)
    final limit = linesTopToBottom.length > 20 ? 20 : linesTopToBottom.length;

    for (int i = 0; i < limit; i++) {
      for (int j = i + 1; j < limit; j++) {
        final a = linesTopToBottom[i];
        final b = linesTopToBottom[j];

        // TD3 44 (order a,b)
        final p1 = _tryParseTwoLines(a, b, 44);
        if (p1 != null) return p1;

        // TD3 44 (order b,a)
        final p2 = _tryParseTwoLines(b, a, 44);
        if (p2 != null) return p2;

        // TD2 36 (order a,b)
        final p3 = _tryParseTwoLines(a, b, 36);
        if (p3 != null) return p3;

        // TD2 36 (order b,a)
        final p4 = _tryParseTwoLines(b, a, 36);
        if (p4 != null) return p4;
      }
    }

    return null;
  }

  _ParsedMrz? _tryParseTwoLines(String line1, String line2, int len) {
    var l1 = _fitToLen(line1, len, preferDocStart: true);
    var l2 = _fitToLen(line2, len);

    if (len == 44) {
      l1 = _fixNameFieldDigitsToLetters(_repairTd3Line1NameDelimiter(l1));
      l2 = _cleanTd3Line2PersonalNumberNoise(l2);
    }

    final candidate = [l1, l2];
    final r = _tryParseWithRepairsSafe(candidate);
    if (r != null) return _ParsedMrz(r, candidate);
    return null;
  }

  MRZResult? _tryParseWithRepairsSafe(List<String> candidate) {
    final variants = <List<String>>[];

    variants.add(candidate);
    variants.add(candidate.map(_normalizeMrzString).toList());
    variants.add(candidate.map(_fixWeirdRuns).toList());

    if (candidate.length == 2 &&
        candidate[0].length == 44 &&
        candidate[1].length == 44) {
      variants.add([
        _fixNameFieldDigitsToLetters(_repairTd3Line1NameDelimiter(candidate[0])),
        _cleanTd3Line2PersonalNumberNoise(_fixTd3Line2Digits(candidate[1])),
      ]);

      variants.add([
        candidate[0],
        _fixTd3Line2Digits(candidate[1]),
      ]);
    }

    final seen = <String>{};
    for (final v in variants) {
      final key = v.join('\n');
      if (!seen.add(key)) continue;

      try {
        final r = MRZParser.tryParse(v);
        if (r != null) return r;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // Post-fix: إذا parser نجح لكن givenNames فارغ
  // --------------------------------------------------------------------------

  Future<_ParsedMrz> _postFixParsedIfNeeded(_ParsedMrz parsed) async {
    final r = parsed.result;

    if (r.givenNames.trim().isEmpty &&
        parsed.usedLines.length == 2 &&
        parsed.usedLines[0].length == 44 &&
        parsed.usedLines[1].length == 44) {
      final fixedL1 = _fixNameFieldDigitsToLetters(
          _repairTd3Line1NameDelimiter(parsed.usedLines[0]));
      final fixedL2 = _fixTd3Line2Digits(
          _cleanTd3Line2PersonalNumberNoise(parsed.usedLines[1]));

      if (fixedL1 != parsed.usedLines[0] || fixedL2 != parsed.usedLines[1]) {
        try {
          final reparsed = MRZParser.tryParse([fixedL1, fixedL2]);
          if (reparsed != null) {
            return _ParsedMrz(reparsed, [fixedL1, fixedL2]);
          }
        } catch (_) {}
      }
    }

    return parsed;
  }

  // --------------------------------------------------------------------------
  // Build MRZ-ish lines from OCR
  // --------------------------------------------------------------------------

  List<String> _extractOrderedRows(RecognizedText rt) {
    final ocrLines = <_OcrLine>[];

    for (final b in rt.blocks) {
      for (final l in b.lines) {
        final text = l.text.trim();
        if (text.isEmpty) continue;
        ocrLines.add(_OcrLine(text: text, box: l.boundingBox));
      }
    }

    ocrLines.sort((a, b) => a.box.top.compareTo(b.box.top));

    final yTol = 14.0;
    final rows = <List<_OcrLine>>[];

    for (final line in ocrLines) {
      if (rows.isEmpty) {
        rows.add([line]);
        continue;
      }
      final lastRow = rows.last;
      final lastY = lastRow.first.box.center.dy;
      if ((line.box.center.dy - lastY).abs() <= yTol) {
        lastRow.add(line);
      } else {
        rows.add([line]);
      }
    }

    final rowTexts = <String>[];
    for (final row in rows) {
      row.sort((a, b) => a.box.left.compareTo(b.box.left));
      rowTexts.add(row.map((e) => e.text).join(''));
    }

    return rowTexts;
  }

  List<String> _rowsToMrzishLines(List<String> rows) {
    final out = <String>[];
    for (final row in rows) {
      final norm = _normalizeMrzString(row);
      if (norm.isEmpty) continue;

      for (final s in _splitIfMerged(norm)) {
        final t = s.trim();
        if (_looksLikeMrzLine(t)) out.add(t);
      }
    }
    return out;
  }

  List<String> _fallbackLinesFromPlainText(String raw) {
    final norm = _normalizeMrzString(raw.replaceAll('\r', '\n'));
    final lines = norm
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final out = <String>[];
    for (final l in lines) {
      for (final s in _splitIfMerged(l)) {
        if (_looksLikeMrzLine(s)) out.add(s);
      }
    }
    return out;
  }

  bool _looksLikeMrzLine(String s) {
    if (s.length < 15) return false;
    if (!s.contains('<')) return false;
    if (s.length > 160) return false;
    return true;
  }

  List<String> _splitIfMerged(String s) {
    final x = s.replaceAll(RegExp(r'\s+'), '');
    if (x.length < 55) return [x];

    final targets = [44, 36, 30];
    for (final t in targets) {
      for (final k in [2, 3]) {
        final total = t * k;
        if (x.length >= total - 12 && x.length <= total + 12) {
          final padded = x.padRight(total, '<');
          return List.generate(
              k, (i) => padded.substring(i * t, (i + 1) * t));
        }
      }
    }
    return [x];
  }

  String _fitToLen(String s, int target, {bool preferDocStart = false}) {
    var x = _normalizeMrzString(s);

    if (x.length == target) return x;

    if (x.length < target) {
      return x.padRight(target, '<');
    }

    // إضافة من mrz_utils.dart: لو أطول بفارق بسيط حاول أخذ آخر target
    if (x.length > target && x.length <= target + 20) {
      if (preferDocStart) {
        final starts = ['P<', 'I<', 'V<', 'A<', 'C<'];
        for (final st in starts) {
          final idx = x.indexOf(st);
          if (idx >= 0 && idx + target <= x.length) {
            return x.substring(idx, idx + target);
          }
        }
      }
      return x.substring(x.length - target);
    }

    if (preferDocStart) {
      final starts = ['P<', 'I<', 'V<', 'A<', 'C<'];
      for (final st in starts) {
        final idx = x.indexOf(st);
        if (idx >= 0 && idx + target <= x.length) {
          return x.substring(idx, idx + target);
        }
      }
    }

    return x.substring(0, target);
  }

  // --------------------------------------------------------------------------
  // Repairs
  // --------------------------------------------------------------------------

  String _normalizeMrzString(String s) {
    var x = s.toUpperCase();

    x = x
        .replaceAll('«', '<')
        .replaceAll('‹', '<')
        .replaceAll('＜', '<')
        .replaceAll('﹤', '<')
        .replaceAll('《', '<')
        .replaceAll('〉', '<')
        .replaceAll('＞', '<')
        .replaceAll('>', '<'); // ✅ من mrz_utils.dart

    x = x.replaceAll(RegExp(r'\s+'), '');
    x = x.replaceAll(RegExp(r'[^A-Z0-9<\n]'), '');
    return x;
  }

  String _fixWeirdRuns(String s) {
    return s.replaceAllMapped(RegExp(r'K{3,}'), (m) => '<' * m[0]!.length);
  }

  String _repairTd3Line1NameDelimiter(String line1) {
    if (line1.length != 44) return line1;

    final start = 5; // P<XXX
    final idx = line1.indexOf('<', start);
    if (idx == -1) return line1;

    if (idx + 1 < line1.length && line1[idx + 1] != '<') {
      final repaired =
          line1.substring(0, idx) + '<<' + line1.substring(idx + 1);
      return repaired.length >= 44
          ? repaired.substring(0, 44)
          : repaired.padRight(44, '<');
    }

    return line1;
  }

  String _fixNameFieldDigitsToLetters(String line1) {
    if (line1.length != 44) return line1;

    const map = {
      '0': 'O',
      '1': 'I',
      '2': 'Z',
      '5': 'S',
      '8': 'B',
      '6': 'G',
    };

    final chars = line1.split('');
    for (int i = 5; i < chars.length; i++) {
      final c = chars[i];
      if (map.containsKey(c)) {
        chars[i] = map[c]!;
      }
    }
    return chars.join('');
  }

  String _cleanTd3Line2PersonalNumberNoise(String line2) {
    if (line2.length != 44) return line2;

    final personal = line2.substring(28, 42);
    final fillCount = '<'.allMatches(personal).length;
    final letters = RegExp(r'[A-Z]').allMatches(personal).length;
    final digits = RegExp(r'[0-9]').allMatches(personal).length;

    if (fillCount >= 10 && letters >= 1 && digits == 0) {
      final fixedPersonal = personal.replaceAll(RegExp(r'[A-Z]'), '<');
      return line2.substring(0, 28) + fixedPersonal + line2.substring(42);
    }

    if (fillCount >= 10) {
      final chars = personal.split('');
      for (int i = 1; i < chars.length - 1; i++) {
        final c = chars[i];
        if (RegExp(r'[A-Z]').hasMatch(c) &&
            chars[i - 1] == '<' &&
            chars[i + 1] == '<') {
          chars[i] = '<';
        }
      }
      final repaired = chars.join('');
      return line2.substring(0, 28) + repaired + line2.substring(42);
    }

    return line2;
  }

  String _fixTd3Line2Digits(String line2) {
    if (line2.length != 44) return line2;

    const mapDigit = {
      'O': '0',
      'Q': '0',
      'D': '0',
      'I': '1',
      'L': '1',
      'Z': '2',
      'S': '5',
      'G': '6',
      'B': '8',
    };

    const mapLetter = {
      '0': 'O',
      '1': 'I',
      '2': 'Z',
      '5': 'S',
      '8': 'B',
      '6': 'G',
    };

    String fixDigits(String s) =>
        s.split('').map((c) => mapDigit[c] ?? c).join('');
    String fixLetters(String s) =>
        s.split('').map((c) => mapLetter[c] ?? c).join('');

    final chars = line2.split('');

    final nat =
        fixLetters(chars.sublist(10, 13).join()).padRight(3, '<').substring(0, 3);
    chars.setRange(10, 13, nat.split(''));

    final bd =
        fixDigits(chars.sublist(13, 19).join()).padRight(6, '0').substring(0, 6);
    chars.setRange(13, 19, bd.split(''));

    final exp =
        fixDigits(chars.sublist(21, 27).join()).padRight(6, '0').substring(0, 6);
    chars.setRange(21, 27, exp.split(''));

    for (final idx in [9, 19, 27, 42, 43]) {
      if (idx >= 0 && idx < chars.length) {
        chars[idx] = mapDigit[chars[idx]] ?? chars[idx];
      }
    }

    return chars.join('');
  }

  // --------------------------------------------------------------------------
  // Auto rect guess
  // --------------------------------------------------------------------------

  Rect? _guessMrzRect(
    RecognizedText rt, {
    required double imageWidth,
    required double imageHeight,
  }) {
    final scored = <_OcrLineScore>[];

    for (final b in rt.blocks) {
      for (final l in b.lines) {
        final t = _normalizeMrzString(l.text);
        if (t.isEmpty) continue;

        final lt = '<'.allMatches(t).length;
        if (lt < 4) continue;

        final y = l.boundingBox.center.dy / imageHeight;
        if (y < 0.45) continue;

        final score = lt.toDouble() + y * 10.0;
        scored.add(_OcrLineScore(box: l.boundingBox, score: score));
      }
    }

    if (scored.isEmpty) return null;

    scored.sort((a, b) => b.score.compareTo(a.score));
    final top = scored.take(4).toList();

    Rect r = top.first.box;
    for (final x in top.skip(1)) {
      r = r.expandToInclude(x.box);
    }

    final padX = imageWidth * 0.03;
    final padY = imageHeight * 0.03;

    final left = (r.left - padX).clamp(0.0, imageWidth);
    final topY = (r.top - padY).clamp(0.0, imageHeight);
    final right = (r.right + padX).clamp(0.0, imageWidth);
    final bottom = (r.bottom + padY).clamp(0.0, imageHeight);

    final out = Rect.fromLTRB(left, topY, right, bottom);

    if (out.width < imageWidth * 0.25 || out.height < imageHeight * 0.08) {
      return null;
    }
    return out;
  }

  // --------------------------------------------------------------------------
  // Image prep + attempt rendering
  // --------------------------------------------------------------------------

  Future<_PreparedBase> _prepareBase(File original) async {
    final bytes = await original.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw MrzScanException('Could not extract MRZ.');

    var image = img.bakeOrientation(decoded);

    if (image.width > 2400) {
      image = img.copyResize(image, width: 2400);
    }

    final file = await _writeTempPng(image, 'mrz_base');
    return _PreparedBase(image: image, baseFile: file);
  }

  Future<File> _renderAttemptFile(
    img.Image base,
    _AttemptSpec spec, {
    required int index,
  }) async {
    try {
      img.Image x = base;

      // Crop
      if (spec.crop is _CropFrac) {
        x = _cropFrac(x, spec.crop as _CropFrac);
      } else if (spec.crop is _CropRect) {
        x = _cropRect(x, (spec.crop as _CropRect).rect);
      }

      // Rotate
      if (spec.rotateDeg.abs() > 0.01) {
        x = img.copyRotate(x, angle: spec.rotateDeg);
      }

      // Avoid too tiny
      if (x.width < 30 || x.height < 30) {
        x = base;
      }

      // Resize:
      // - للمحاولات القديمة: نفس المنطق (1600..2200)
      // - للمحاولات الجديدة: upscaleWidth (مثل 2800) إن وُجد
      const minW = 1600;
      const maxW = 2200;

      if (spec.upscaleWidth != null) {
        final target = spec.upscaleWidth!;
        if (x.width < target) {
          x = img.copyResize(
            x,
            width: target,
            maintainAspect: true,
            interpolation: img.Interpolation.linear,
          );
        }
      } else {
        if (x.width < minW) {
          x = img.copyResize(x, width: minW);
        } else if (x.width > maxW) {
          x = img.copyResize(x, width: maxW);
        }
      }

      // Grayscale
      img.grayscale(x);

      // ✅ Normalize (من image_prep.dart)
      if (spec.normalize) {
        x = img.normalize(
          x,
          min: 0,
          max: 255,
          maskChannel: img.Channel.luminance,
        );
      }

      // Contrast
      img.contrast(x, contrast: spec.contrast);

      // Sharpen (level 1/2/3)
      if (spec.sharpenLevel > 0 && x.width >= 3 && x.height >= 3) {
        x = _applySharpenLevels(x, spec.sharpenLevel);
      }

      // BW: fixed threshold OR Otsu (من image_prep.dart)
      if (spec.bw) {
        if (spec.otsu) {
          final thr = _otsuThreshold(x); // 0..255
          x = _binarize(x, threshold: thr);
        } else {
          x = _binarizeFixed(x, threshold01: spec.threshold);
        }
      }

      return _writeTempPng(x, 'mrz_try_${index}_${spec.tag}');
    } catch (_) {
      return _writeTempPng(base, 'mrz_try_${index}_fallback');
    }
  }

  img.Image _cropFrac(img.Image base, _CropFrac crop) {
    final w = base.width;
    final h = base.height;

    int x = (w * crop.x0).round();
    int y = (h * crop.y0).round();
    int cw = (w * (crop.x1 - crop.x0)).round();
    int ch = (h * (crop.y1 - crop.y0)).round();

    x = x.clamp(0, w - 1);
    y = y.clamp(0, h - 1);

    final maxW = (w - x).clamp(1, w);
    final maxH = (h - y).clamp(1, h);

    cw = cw.clamp(1, maxW);
    ch = ch.clamp(1, maxH);

    return img.copyCrop(base, x: x, y: y, width: cw, height: ch);
  }

  img.Image _cropRect(img.Image base, Rect rect) {
    final w = base.width;
    final h = base.height;

    int x = rect.left.round().clamp(0, w - 1);
    int y = rect.top.round().clamp(0, h - 1);

    final maxW = (w - x).clamp(1, w);
    final maxH = (h - y).clamp(1, h);

    int cw = rect.width.round().clamp(1, maxW);
    int ch = rect.height.round().clamp(1, maxH);

    return img.copyCrop(base, x: x, y: y, width: cw, height: ch);
  }

  img.Image _applySharpenLevels(img.Image src, int level) {
    if (level <= 0) return src;
    if (level == 1) return _sharpen3x3(src, strong: false);
    if (level == 2) return _sharpen3x3(src, strong: true);

    // level >= 3: strong مرتين
    final a = _sharpen3x3(src, strong: true);
    return _sharpen3x3(a, strong: true);
  }

  img.Image _sharpen3x3(img.Image src, {required bool strong}) {
    final k = strong
        ? <int>[-1, -1, -1, -1, 9, -1, -1, -1, -1]
        : <int>[0, -1, 0, -1, 5, -1, 0, -1, 0];

    final w = src.width;
    final h = src.height;
    final out = img.Image(width: w, height: h);

    // copy edges
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = src.getPixel(x, y);
        out.setPixelRgba(x, y, p.r, p.g, p.b, p.a);
      }
    }

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        int sum = 0;
        int idx = 0;

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final p = src.getPixel(x + kx, y + ky);
            sum += int.parse((p.r * k[idx++]).toString());
          }
        }

        final v = sum.clamp(0, 255).toInt();
        out.setPixelRgba(x, y, v, v, v, 255);
      }
    }

    return out;
  }

  int _otsuThreshold(img.Image gray) {
    final hist = List<int>.filled(256, 0);
    int total = 0;

    for (final p in gray) {
      hist[int.parse((p.r).toString())]++;
      total++;
    }
    if (total == 0) return 128;

    double sum = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * hist[i];
    }

    double sumB = 0;
    int wB = 0;
    double varMax = -1;
    int threshold = 128;

    for (int t = 0; t < 256; t++) {
      wB += hist[t];
      if (wB == 0) continue;

      final wF = total - wB;
      if (wF == 0) break;

      sumB += t * hist[t];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;

      final diff = mB - mF;
      final varBetween = wB * wF * diff * diff;

      if (varBetween > varMax) {
        varMax = varBetween;
        threshold = t;
      }
    }

    return threshold;
  }

  img.Image _binarize(img.Image gray, {required int threshold}) {
    final out = img.Image.from(gray);
    for (final p in out) {
      final v = p.r;
      final b = (v >= threshold) ? 255 : 0;
      p
        ..r = b
        ..g = b
        ..b = b
        ..a = 255;
    }
    return out;
  }

  img.Image _binarizeFixed(img.Image gray, {required double threshold01}) {
    final thr = (threshold01.clamp(0.0, 1.0) * 255).round();
    return _binarize(gray, threshold: thr);
  }

  Future<File> _writeTempPng(img.Image image, String name) async {
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(img.encodePng(image));
    return file;
  }

  List<String> _uniqueKeepOrder(List<String> input) {
    final seen = <String>{};
    final out = <String>[];
    for (final s in input) {
      final x = s.trim();
      if (x.isEmpty) continue;
      if (seen.add(x)) out.add(x);
    }
    return out;
  }

  // --------------------------------------------------------------------------
  // JSON
  // --------------------------------------------------------------------------

  Map<String, dynamic> _resultToJson(
    MRZResult r,
    List<String> mrzLines, {
    required int attempt,
    required String tag,
  }) {
    String dateOnly(DateTime d) => d.toIso8601String().split('T').first;
    String sexToString(Sex s) => s.toString().split('.').last;

    return {
      'meta': {
        'attempt': attempt,
        'variant': tag,
      },
      'mrzLines': mrzLines,
      'documentType': r.documentType,
      'countryCode': r.countryCode,
      'nationalityCountryCode': r.nationalityCountryCode,
      'documentNumber': r.documentNumber,
      'birthDate': dateOnly(r.birthDate),
      'expiryDate': dateOnly(r.expiryDate),
      'sex': sexToString(r.sex),
      'surnames': r.surnames,
      'givenNames': r.givenNames,
      'personalNumber': r.personalNumber,
      'personalNumber2': r.personalNumber2,
    };
  }
}

// --------------------------------------------------------------------------
// Models
// --------------------------------------------------------------------------

class _ScanOutcome {
  final RecognizedText recognizedText;
  final _ParsedMrz? parsed;

  _ScanOutcome({
    required this.recognizedText,
    required this.parsed,
  });
}

class _ParsedMrz {
  final MRZResult result;
  final List<String> usedLines;
  _ParsedMrz(this.result, this.usedLines);
}

class _PreparedBase {
  final img.Image image;
  final File baseFile;
  _PreparedBase({required this.image, required this.baseFile});
}

class _AttemptSpec {
  final String tag;
  final Object crop; // _CropFrac or _CropRect
  final double rotateDeg;

  final bool bw; // إذا false: gray فقط
  final double threshold; // fixed threshold
  final int contrast;
  final int sharpenLevel;

  // ✅ إضافات (من الملفات المرفقة)
  final bool normalize; // img.normalize
  final bool otsu; // Otsu threshold بدل fixed threshold
  final int? upscaleWidth; // تكبير عرض أقوى للمحاولات الجديدة

  const _AttemptSpec({
    required this.tag,
    required this.crop,
    required this.rotateDeg,
    required this.bw,
    required this.threshold,
    required this.contrast,
    required this.sharpenLevel,
    this.normalize = false,
    this.otsu = false,
    this.upscaleWidth,
  });
}

class _CropFrac {
  final double x0, y0, x1, y1;
  const _CropFrac({
    required this.x0,
    required this.y0,
    required this.x1,
    required this.y1,
  });
}

class _CropRect {
  final Rect rect;
  const _CropRect(this.rect);
}

class _OcrLine {
  final String text;
  final Rect box;
  _OcrLine({required this.text, required this.box});
}

class _OcrLineScore {
  final Rect box;
  final double score;
  _OcrLineScore({required this.box, required this.score});
}
