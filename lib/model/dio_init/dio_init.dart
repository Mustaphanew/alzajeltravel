import 'package:alzajeltravel/model/api.dart';
import 'package:alzajeltravel/model/dio_init/auth_storage.dart';
import 'package:alzajeltravel/model/dio_init/logging_interceptor.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/routes.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// تهيئة Dio مرة واحدة: إضافة Auth + إعادة التوجيه عند 401 + Logging مفصّل
/// في debug فقط. آمن ضد الاستدعاء المتكرر (idempotent).
///
/// يجب استدعاؤها **بعد** `BaseUrlConfig.init()` في `main()` لأن
/// `baseUrl` يُقرأ ديناميكياً من [AppApis.apiBaseUrl].
void initDio() {
  // نُحدّث baseUrl دائماً لالتقاط أي تغيير في Remote Config/FLAVOR.
  dio.options.baseUrl = AppApis.apiBaseUrl;

  final hasLogger = dio.interceptors.any((i) => i is LoggingInterceptor);
  if (hasLogger) return;

  // 1) Auth interceptor: يضيف Authorization ويعالج 401.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final isLogin = options.path.contains('/flight/agent-login');

        if (!isLogin && !options.headers.containsKey('Authorization')) {
          final token = await AuthStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          await AuthStorage.clearToken();
          Get.offAllNamed(Routes.login.path);
        }
        handler.next(err);
      },
    ),
  );

  // 2) Logging interceptor: يُضاف بعد Auth لتظهر هيدر Authorization
  //    (بعد حجبها) داخل السجل.
  dio.interceptors.add(LoggingInterceptor());
}
