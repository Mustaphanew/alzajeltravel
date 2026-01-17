import 'package:alzajeltravel/model/api.dart';
import 'package:alzajeltravel/model/dio_init/auth_storage.dart';
import 'package:alzajeltravel/utils/routes.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

void initDio() {
  final alreadyAdded = dio.interceptors.any((i) => i is InterceptorsWrapper);
  if (alreadyAdded) return;

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // استثناء login مثلاً (اختياري)
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
          // تقدر توجه المستخدم للـ login هنا عبر GetX routes
          Get.offAllNamed(Routes.login.path);
        }
        handler.next(err);
      },
    ),
  );
}
