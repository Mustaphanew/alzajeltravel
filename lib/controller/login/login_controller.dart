import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/routes.dart';
import 'package:alzajeltravel/utils/widgets/custom_snack_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../services/biometric/biometric_service.dart';

class LoginController extends GetxController {
  // ✅ Keys (keep them consistent across app)
  static const String _kAccessToken = 'access_token';
  static const String _kBiometricEnabled = 'Biometric Enabled';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final BiometricService _biometric = BiometricService();

  final emailController = TextEditingController(
    text: AppVars.getStorage.read('profile') != null ? AppVars.getStorage.read('profile')['email'] : '',
  );
  final passwordController = TextEditingController();
  final agencyNumberController = TextEditingController(
    text: AppVars.getStorage.read('profile') != null ? AppVars.getStorage.read('profile')['agencyNumber'] : '',
  );

  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final agencyFocus = FocusNode();

  bool isPasswordHidden = true;
  bool isLoading = false;

  bool biometricEnabled = false;

  bool get showBiometrics => !kIsWeb;

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    checkBiometricEnabled();
  }

  Future<void> checkBiometricEnabled() async {
    biometricEnabled = (await _storage.read(key: _kBiometricEnabled)) == 'true';
    update();
  }

  String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email Required'.tr;

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(v)) return 'Invalid Email'.tr;

    return null;
  }

  String? validatePassword(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Password Required'.tr;

    if (v.length < 6) return 'Password Must Be At Least 6 Characters'.tr;

    return null;
  }

  String? validateAgencyNumber(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Agency Number Required'.tr;

    if (!RegExp(r'^\d+$').hasMatch(v)) {
      return 'Agency Number Must Be Digits Only'.tr;
    }

    if (v.length < 3 || v.length > 10) {
      return 'Agency Number Length Is Invalid'.tr;
    }

    return null;
  }

  Future<void> login(BuildContext context, {required bool validateForm}) async {
    AppFuns.hideKeyboard();
    if (!validateForm) return;

    isLoading = true;
    update();

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final agencyNumber = agencyNumberController.text.trim();

      final response = await AppVars.api.post(
        AppApis.login,
        params: {"username": email, "password": password, "company_code": agencyNumber},
        asJson: true,
      );

      if (response == null) {
        if (context.mounted) {
          CustomSnackBar.error(context, 'Response Is Null'.tr);
        }
        return;
      }

      if (response is! Map<String, dynamic>) {
        if (context.mounted) {
          CustomSnackBar.error(context, 'Unexpected Response Type'.tr);
        }
        return;
      }

      if (response['status']?.toString() != 'success') {
        if (context.mounted) {
          CustomSnackBar.error(context, 'Login Failed'.tr);
        }
        return;
      }
      print("response['_kAccessToken'] ${response[_kAccessToken]}");
      final accessToken = response[_kAccessToken]?.toString();
      if (accessToken == null || accessToken.isEmpty) {
        if (context.mounted) {
          CustomSnackBar.error(context, 'Missing Token'.tr);
        }
        return;
      }

      final agent = (response['agent'] is Map<String, dynamic>) ? (response['agent'] as Map<String, dynamic>) : <String, dynamic>{};
      print("scopes: 1 ${response['scopes']}");


      final List<String> permissions = (response['scopes'] as List? ?? const [])
          .map((e) => e.toString())
          .toList();


      print("scopes: 2 $permissions");

      if ((agent['email']?.toString() ?? '').isEmpty) {
        if (context.mounted) {
          CustomSnackBar.error(context, 'Agent Email Is Null'.tr);
        }
        return;
      }

      // ✅ Save token (NOT password)
      await _storage.write(key: _kAccessToken, value: accessToken);

      // Optional: save for hints / auto fill
      AppVars.getStorage.write('email', email);
      AppVars.getStorage.write('agencyNumber', agencyNumber);

      // Optional: enable biometrics after first successful login (you can move this to settings)
      await _storage.write(key: _kBiometricEnabled, value: 'true');
      biometricEnabled = true;

      AppVars.apiSessionId = response['api_session_id']?.toString();

      Get.snackbar('Success'.tr, 'Login Successful'.tr);

      goToProfile(
        agent, 
        agencyNumber: agencyNumber,
        permissions: permissions,
      );
    } catch (_) {
      if (context.mounted) {
        CustomSnackBar.error(context, 'Login Failed'.tr);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> loginWithBiometrics(BuildContext context) async {
    AppFuns.hideKeyboard();
    if (kIsWeb) {
      if (context.mounted) {
        CustomSnackBar.error(context, 'Biometrics Not Supported On Web'.tr);
      }
      return;
    }

    final enabled = await _storage.read(key: _kBiometricEnabled);
    if (enabled != 'true') {
      if(context.mounted) CustomSnackBar.error(context, 'Login First Then Enable Biometrics'.tr);
      return;
    }

    final canUse = await _biometric.canUseBiometrics();
    if (!canUse) {
      if(context.mounted) CustomSnackBar.error(context, 'Biometrics Not Available On This Device'.tr);
      return;
    }

    try {
      final ok = await _biometric.authenticate();
      if (!ok) return;

      // ✅ مؤقتًا: بمجرد نجاح البصمة ادخل مباشرة
      Get.offAllNamed(Routes.frame.path);
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.userCanceled) return;

      if (e.code == LocalAuthExceptionCode.noBiometricsEnrolled) {
        if(context.mounted) CustomSnackBar.error(context, 'No Biometrics Enrolled'.tr);
        return;
      }

      if (e.code == LocalAuthExceptionCode.noBiometricHardware) {
        if(context.mounted) CustomSnackBar.error(context, 'Biometrics Not Available On This Device'.tr);
        return;
      }

      if(context.mounted) CustomSnackBar.error(context, 'Biometric Login Failed'.tr);
    } catch (_) {
      if(context.mounted) CustomSnackBar.error(context, 'Biometric Login Failed'.tr);
    }
  }

  // Future<bool> _validateTokenWithServer() async {
  //   // ✅ اختر endpoint محمي عندك يرجع 200 إذا التوكن صحيح
  //   // إذا ما عندك me endpoint، استبدله بأي endpoint protected موجود.
  //   final res = await AppVars.api.get(AppApis.me);
  //   return res != null;
  // }

  void goToProfile(
    Map<String, dynamic> agent, {
      required String agencyNumber,
      required List<String> permissions,
    }) {
      print("permissions: $permissions");
    final Map<String, dynamic> profileMap = {
      "id": agent['id'],
      "companyRegistrationNumber": "3343432282",
      "name": agent['agency_name'],
      "email": agent['email'],
      "agencyNumber": agent['company_code'] ?? agencyNumber,
      "phone": agent['mobile'],
      "country": agent['country'] ?? 'YE',
      "address": agent['address'] ?? 'Sanaa',
      "website": "https://www.example.com",
      "branchCode": agent['branch_code'] ?? '_',
      "status": "approved",
      "remainingBalance": agent['balance'],
      "usedBalance": 0,
      "totalBalance": 0,
      "permissions": permissions,
    };

    AppVars.getStorage.write('profile', profileMap);
    Get.offAllNamed(Routes.frame.path);
  }

  // @override
  // void onClose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   agencyNumberController.dispose();

  //   emailFocus.dispose();
  //   passwordFocus.dispose();
  //   agencyFocus.dispose();
  //   super.onClose();
  // }
}
