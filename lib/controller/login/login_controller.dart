import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets/custom_snack_bar.dart';
import 'package:alzajeltravel/view/frame.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/biometric/biometric_service.dart'; 
import 'package:local_auth/local_auth.dart';

class LoginController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final _biometric = BiometricService();

  final emailController = TextEditingController(text: AppVars.getStorage.read('profile') != null ? AppVars.getStorage.read('profile')['email'] : '');
  final passwordController = TextEditingController();
  final agencyNumberController = TextEditingController(
    text: AppVars.getStorage.read('profile') != null ? AppVars.getStorage.read('profile')['agencyNumber'] : '',
  );

  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final agencyFocus = FocusNode();

  bool isPasswordHidden = true;
  bool isLoading = false;

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  bool biometricEnabled = false;

  @override
  void onInit() {
    super.onInit();
    checkBiometricEnabled();
  }

  Future<void> checkBiometricEnabled() async {
    biometricEnabled = await _storage.read(key: 'Biometric Enabled') == 'true';
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

    if (!RegExp(r'^\d+$').hasMatch(v)) return 'Agency Number Must Be Digits Only'.tr;

    if (v.length < 3 || v.length > 10) return 'Agency Number Length Is Invalid'.tr;

    return null;
  }

  Future<void> login(BuildContext context, {required bool validateForm}) async {
    // إغلاق الكيبورد
    FocusManager.instance.primaryFocus?.unfocus();

    if (!validateForm) return;

    isLoading = true;
    update();

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final agencyNumber = agencyNumberController.text.trim();

      // TODO: Connect Dio API here
      await Future.delayed(const Duration(milliseconds: 1000));

      // after success login from API
      // await AppVars.api.get('/'); // يجيب ci_session غالباً
      final response = await AppVars.api.post( 
        AppApis.login,
        params: {"username": email, "password": password, "company_code": agencyNumber.toString()},
        asJson: true,
      );
      print("response login: $response");
      if (response != null) {
        if (response is Map<String, dynamic>) {
          final Map<String, dynamic> agent = response['agent'];
          if (agent['email'] != null) {
            await _storage.write(key: 'Auth Token', value: password);
            await _storage.write(key: 'Biometric Enabled', value: 'true');
            Get.snackbar('Success'.tr, 'Login Successful'.tr);
            goToProfile(agent, agencyNumber: agencyNumber);
          } else {
            Get.snackbar('Error'.tr, 'agent email is null'.tr);
          }
        } else {
          Get.snackbar('Error'.tr, 'response type is not map'.tr);
        }
      } else {
        // Get.snackbar('Error'.tr, 'response is null'.tr);
        if(context.mounted) CustomSnackBar.error(context, 'response is null'.tr);
      }
      // end after success login from API
    } catch (e) {
      Get.snackbar('Error'.tr, 'Login Failed'.tr);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> loginWithBiometrics() async {
    final enabled = await _storage.read(key: 'Biometric Enabled');
    if (enabled != 'true') {
      Get.snackbar('Info'.tr, 'Login First Then Enable Biometrics'.tr);
      return;
    }

    final canUse = await _biometric.canUseBiometrics();
    if (!canUse) {
      Get.snackbar('Error'.tr, 'Biometrics Not Available On This Device'.tr);
      return;
    }

    try {
      final ok = await _biometric.authenticate();
      if (!ok) return; // احتياط (لو رجعت false بدون Exception)

      final token = await _storage.read(key: 'Auth Token');
      if (token == null || token.isEmpty) {
        Get.snackbar('Error'.tr, 'No Saved Login Found'.tr);
        return;
      }

      // هنا تعتبره "Logged in" بالتوكن
      // TODO: اعمل request تحقق بالتوكن أو انتقل للصفحة الرئيسية مباشرة

      final email = AppVars.getStorage.read('email');
      final password = token;
      final agencyNumber = AppVars.getStorage.read('agencyNumber');
      // after success login from API
      final response = await AppVars.api.post(
        AppApis.login,
        params: {'username': email, 'password': password, 'company_code': agencyNumber},
      );
      if (response != null) {
        if (response is Map<String, dynamic>) {
          final agent = response['agent'];
          if (agent['email'] != null) {
            await _storage.write(key: 'Auth Token', value: password);
            await _storage.write(key: 'Biometric Enabled', value: 'true');
            Get.snackbar('Success'.tr, 'Login Successful'.tr);
            goToProfile(agent, agencyNumber: agencyNumber);
          } else {
            Get.snackbar('Error'.tr, 'agent email is null'.tr);
          }
        } else {
          Get.snackbar('Error'.tr, 'response type is not map'.tr);
        }
      } else {
        Get.snackbar('Error'.tr, 'response is null'.tr);
      }
      // end after success login from API
    } on LocalAuthException catch (e) {
      // المستخدم ضغط Cancel -> هذا طبيعي، تجاهله
      if (e.code == LocalAuthExceptionCode.userCanceled) return;

      // لو ما فيه بيانات بيومترية مسجلة على الجهاز
      if (e.code == LocalAuthExceptionCode.noBiometricsEnrolled) {
        Get.snackbar('Info'.tr, 'No Biometrics Enrolled'.tr);
        return;
      }

      // لو الجهاز ما يدعم البيومتريك
      if (e.code == LocalAuthExceptionCode.noBiometricHardware) {
        Get.snackbar('Error'.tr, 'Biometrics Not Available On This Device'.tr);
        return;
      }

      // أي حالة أخرى
      Get.snackbar('Error'.tr, 'Biometric Login Failed'.tr);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Biometric Login Failed'.tr);
    }
  }

  void goToProfile(Map<String, dynamic> agent, {required String agencyNumber}) {
    // مثال: هذا هو الـ Map القادم من السيرفر (بدّله بالـ response الحقيقي)
    final Map<String, dynamic> profileMap = {
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
    };
    AppVars.getStorage.write('profile', profileMap);
    Get.offAll(() => Frame());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    agencyNumberController.dispose();

    emailFocus.dispose();
    passwordFocus.dispose();
    agencyFocus.dispose();
    super.onClose();
  }
}
