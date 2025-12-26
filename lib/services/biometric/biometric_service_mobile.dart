import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canUseBiometrics() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();
    return canCheck && isSupported;
  }

  Future<bool> authenticate() async {
    return _auth.authenticate(
      localizedReason: 'Use Biometrics To Login'.tr,
      biometricOnly: true,
      persistAcrossBackgrounding: true,
      sensitiveTransaction: true,
      authMessages: <AuthMessages>[
        AndroidAuthMessages(
          signInTitle: 'Alzajel Travel'.tr,
          signInHint: GetStorage().read('email')?.toString(),
          cancelButton: 'Cancel button'.tr,
        ),
        IOSAuthMessages(
          cancelButton: 'Cancel button'.tr,
          localizedFallbackTitle: "Use Device Passcode".tr,
        ),
      ],
    );
  }
}
