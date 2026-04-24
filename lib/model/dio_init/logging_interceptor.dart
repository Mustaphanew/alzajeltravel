import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor احترافي لطباعة تفاصيل الطلبات/الاستجابات/الأخطاء
/// في **debug فقط** (يُلغى تلقائياً في release/profile).
///
/// يتكفّل بـ:
/// - حجب المفاتيح الحسّاسة (كلمات المرور/التوكنات/أرقام البطاقات…).
/// - قياس زمن كل طلب بالميلّي ثانية.
/// - تنسيق JSON وعرضه بشكل مقروء (JsonEncoder.withIndent).
/// - التعامل مع multipart/form-data وعرض أسماء الملفات وأحجامها.
/// - استخدام [debugPrint] بدلاً من [print] لتفادي اقتطاع السجلات الطويلة.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  /// مفاتيح تُحجب قيمتها قبل الطباعة (case-insensitive).
  static const _sensitiveKeys = <String>{
    'password', 'pass', 'pwd',
    'new_password', 'old_password', 'current_password',
    'token', 'access_token', 'refresh_token',
    'api_key', 'secret',
    'card_number', 'cvv', 'cvc',
  };

  static const _prettyEncoder = JsonEncoder.withIndent('  ');
  static const _divider =
      '──────────────────────────────────────────────────────────────────────';
  static const _startTsKey = '_log_interceptor_started_at';

  // ─────────────────────────── Request ───────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.extra[_startTsKey] = DateTime.now();

    if (kDebugMode) {
      final method = options.method.toUpperCase();
      final url = options.uri.toString();

      final buf = StringBuffer()
        ..writeln()
        ..writeln('┌── 📤 REQUEST $_divider')
        ..writeln('│ $method $url')
        ..writeln('│ Headers:')
        ..writeln(_indent(_formatHeaders(options.headers)))
        ..writeln('│ Query: ${_formatAny(options.queryParameters)}')
        ..writeln('│ Body:')
        ..writeln(_indent(_formatAny(options.data)))
        ..write('└$_divider');
      debugPrint(buf.toString());
    }

    handler.next(options);
  }

  // ─────────────────────────── Response ──────────────────────────

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final elapsed = _elapsedMs(response.requestOptions);
      final method = response.requestOptions.method.toUpperCase();
      final url = response.requestOptions.uri.toString();
      final status = response.statusCode;

      final buf = StringBuffer()
        ..writeln()
        ..writeln('┌── ✅ RESPONSE $status  (${elapsed}ms) $_divider')
        ..writeln('│ $method $url')
        ..writeln('│ Body:')
        ..writeln(_indent(_formatAny(response.data)))
        ..write('└$_divider');
      debugPrint(buf.toString());
    }

    handler.next(response);
  }

  // ──────────────────────────── Error ────────────────────────────

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final elapsed = _elapsedMs(err.requestOptions);
      final method = err.requestOptions.method.toUpperCase();
      final url = err.requestOptions.uri.toString();
      final status = err.response?.statusCode;

      final buf = StringBuffer()
        ..writeln()
        ..writeln(
          '┌── ❌ ERROR ${status ?? ''}  (${elapsed}ms) $_divider',
        )
        ..writeln('│ $method $url')
        ..writeln('│ Type      : ${err.type}')
        ..writeln('│ Message   : ${err.message}')
        ..writeln('│ Underlying: ${err.error}')
        ..writeln('│ Response Data:')
        ..writeln(_indent(_formatAny(err.response?.data)))
        ..write('└$_divider');
      debugPrint(buf.toString());
    }

    handler.next(err);
  }

  // ─────────────────────────── Helpers ───────────────────────────

  int _elapsedMs(RequestOptions options) {
    final started = options.extra[_startTsKey];
    if (started is DateTime) {
      return DateTime.now().difference(started).inMilliseconds;
    }
    return 0;
  }

  String _indent(String s) {
    return s.split('\n').map((line) => '│   $line').join('\n');
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    final safe = <String, dynamic>{};
    headers.forEach((k, v) {
      if (k.toLowerCase() == 'authorization' && v is String) {
        safe[k] = _maskAuthorization(v);
      } else {
        safe[k] = v;
      }
    });
    return _formatAny(safe);
  }

  String _maskAuthorization(String value) {
    // نُظهر البادئة (Bearer ) + أول حروف من التوكن فقط.
    if (value.length <= 14) return 'Bearer ***';
    return '${value.substring(0, 14)}***';
  }

  /// يحجب مفاتيح حسّاسة في Maps/Lists المتداخلة بشكل آمن.
  dynamic _redact(dynamic data) {
    if (data is Map) {
      final out = <String, dynamic>{};
      data.forEach((k, v) {
        final key = k?.toString() ?? '';
        if (_sensitiveKeys.contains(key.toLowerCase())) {
          out[key] = '***';
        } else {
          out[key] = _redact(v);
        }
      });
      return out;
    }
    if (data is Iterable) {
      return data.map(_redact).toList();
    }
    return data;
  }

  String _formatAny(dynamic data) {
    if (data == null) return 'null';

    if (data is FormData) {
      return _formatFormData(data);
    }

    if (data is String) {
      // جرّب فك JSON، وإلا أعده كنص عادي.
      final trimmed = data.trim();
      if (trimmed.isEmpty) return '""';
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          return _prettyEncoder.convert(_redact(decoded));
        } catch (_) {
          // ignore
        }
      }
      return data;
    }

    try {
      return _prettyEncoder.convert(_redact(data));
    } catch (_) {
      return data.toString();
    }
  }

  String _formatFormData(FormData form) {
    final buf = StringBuffer()..writeln('multipart/form-data:');
    for (final entry in form.fields) {
      final key = entry.key;
      final val = _sensitiveKeys.contains(key.toLowerCase())
          ? '***'
          : entry.value;
      buf.writeln('  $key: $val');
    }
    for (final entry in form.files) {
      final key = entry.key;
      final file = entry.value;
      buf.writeln(
        '  $key: <file ${file.filename ?? '?'} • ${file.length} bytes>',
      );
    }
    return buf.toString().trimRight();
  }
}
