import 'package:alzajeltravel/model/api.dart';
import 'package:dio/dio.dart';

void initDio() {
  // ✅ هذا أهم شيء للكوكيز مع API على دومين مختلف
  dio.options.extra['withCredentials'] = true;

  // (اختياري) تأكد كذلك في كل request:
  // Options(extra: {'withCredentials': true})

  // Logger اختياري
  final alreadyAddedLogger = dio.interceptors.any((i) => i is InterceptorsWrapper);
  if (!alreadyAddedLogger) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (err, handler) {
          handler.next(err);
        },
      ),
    );
  }
}
