import 'package:alzajeltravel/controller/login/login_controller.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets/custom_snack_bar.dart';
import 'package:alzajeltravel/view/frame/search_flight_widgets/date_picker/date_picker_single_widget2.dart';
import 'package:alzajeltravel/view/settings/settings.dart';
import 'package:alzajeltravel/utils/glassmorphism/glassmorphism.dart';
import 'package:alzajeltravel/view/tmp/my_lottie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pwa_install/pwa_install.dart';
import '../../utils/glassmorphism/particles_fly.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  late final LoginController controller;
  final formKey = GlobalKey<FormState>();

  SearchFlightController searchFlightController = Get.put(SearchFlightController());

  ScrollController scrollController = ScrollController();

  double _lastBottomInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(LoginController(), permanent: false);
    AppVars.getStorage.write("first_run", false);

    // قيمة ابتدائية (لو الصفحة فتحت والكيبورد ظاهر)
    _lastBottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;

  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bottomInset = MediaQuery.of(context).viewInsets.bottom;

      final keyboardJustOpened = bottomInset > _lastBottomInset && bottomInset > 0;
      final keyboardJustClosed = bottomInset == 0 && _lastBottomInset > 0;

      _lastBottomInset = bottomInset;

      print("didChangeMetrics bottomInset: $bottomInset keyboardJustOpened: $keyboardJustOpened");

      if (keyboardJustOpened && scrollController.hasClients) {
        // نفذ بعد شوي عشان أنيميشن الكيبورد يكمل ويصير maxScrollExtent صحيح
        Future.delayed(const Duration(milliseconds: 0), () {
          if (!mounted || !scrollController.hasClients) return;
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }


    @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> login(BuildContext context) async {
    context.loaderOverlay.show();
    await controller.login(
      context,
      validateForm: (formKey.currentState?.validate() ?? false),
    );
    if (context.mounted) context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);

    final iconFieldColor = MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.error)) return cs.error;
      if (states.contains(MaterialState.focused)) return cs.secondary;
      if (states.contains(MaterialState.disabled)) return cs.onSurface.withOpacity(0.38);
      return cs.onPrimary.withOpacity(0.85);
    });

    OutlineInputBorder _border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: 1),
        );

    InputDecoration deco({
      required String hint,
      required Widget prefix,
      Widget? suffix,
    }) {
      return InputDecoration(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintText: hint.tr,
        hintStyle: TextStyle(color: cs.onPrimary.withOpacity(0.6)),
        prefixIcon: prefix,
        prefixIconColor: iconFieldColor,
        suffixIcon: suffix,
        suffixIconColor: iconFieldColor,
        enabledBorder: _border(cs.onPrimary.withOpacity(0.32)),
        focusedBorder: _border(cs.secondary.withOpacity(0.95)),
        errorBorder: _border(cs.error.withOpacity(0.95)),
        focusedErrorBorder: _border(cs.error.withOpacity(0.95)),
      );
    }

    return GetBuilder<LoginController>(
      builder: (c) {
        final kb = MediaQuery.of(context).viewInsets.bottom;
        return Scaffold(
          resizeToAvoidBottomInset: false, // ✅ يمنع رفع التصميم
          backgroundColor: cs.primary,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // الخلفية (Particles)
              Positioned.fill(
                child: ParticlesFly(
                  height: size.height,
                  width: size.width,
                  connectDots: true,
                  numberOfParticles: 100,
                  speedOfParticles: 1,
                  maxParticleSize: 3.0,
                  particleColor: Colors.white,
                  lineColor: const Color(0xffe7b245),
                  lineStrokeWidth: 1,
                  onTapAnimation: true,
                ),
              ),

              // الكرت (Glass)
              SafeArea(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 22,
                    right: 22,
                    bottom: 34 + kb, // ✅ مساحة إضافية عند ظهور الكيبورد
                  ),
                  child: Form(
                    key: formKey,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: GlassContainer(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 34),
                      
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AppConsts.logo3,
                                    // height: 48,
                                    // width: 48,
                                  ),
                                  const SizedBox(width: 16),
                                  SvgPicture.asset(
                                    AppConsts.brand,
                                    // height: 48,
                                    // width: 128,
                                  ),
                                ],
                              ),
                      
                              const SizedBox(height: 44),
                      
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Agent Login".tr,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      foregroundColor: cs.onPrimary,
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide(
                                        color: cs.secondary.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    onPressed: () async {
                                      print("AppVars.appThemeMode: ${AppVars.appThemeMode}");
                                      context.loaderOverlay.show();
                                      await Future.delayed(const Duration(seconds: 5));
                                      if(context.mounted) context.loaderOverlay.hide();
                                      // Get.to(() => const MyLottie());
                                      // Get.to(() => const SettingsPage());
                                    }, 
                                    child: Text("Settings".tr),
                                  ),
                                ],
                              ),
                              Text(
                                "Get competitive global airfares via New Horizon.".tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: cs.onPrimary,
                                ),
                              ),
                      
                              const SizedBox(height: 24),
                      
                              // Email
                              TextFormField(
                                controller: c.emailController,
                                focusNode: c.emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: c.validateEmail,
                                cursorColor: cs.secondary,
                                style: TextStyle(color: cs.onPrimary),
                                decoration: deco(
                                  hint: 'Email Hint',
                                  prefix: const Icon(Icons.email_outlined),
                                ),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(c.passwordFocus);
                                },
                              ),
                      
                              const SizedBox(height: 24),

                              // Password
                              StatefulBuilder(
                                builder: (context, innerSetState) {
                                  return TextFormField(
                                    controller: c.passwordController,
                                    focusNode: c.passwordFocus,
                                    obscureText: c.isPasswordHidden,
                                    textInputAction: TextInputAction.next,
                                    validator: c.validatePassword,
                                    cursorColor: cs.secondary,
                                    style: TextStyle(color: cs.onPrimary),
                                    decoration: deco(
                                      hint: 'Password Hint',
                                      prefix: const Icon(Icons.lock_outlined),
                                      suffix: suffixIconPassword(context, c),
                                    ),
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(c.agencyFocus);
                                    },
                                    onChanged: (value) {
                                      innerSetState(() {});
                                    },
                                    onEditingComplete: () {
                                      print("onEditingComplete");
                                    },
                                  );
                                },
                              ), 
                      
                              const SizedBox(height: 24),
                      
                              // Agency Number
                              TextFormField(
                                controller: c.agencyNumberController,
                                focusNode: c.agencyFocus,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                validator: c.validateAgencyNumber,
                                cursorColor: cs.secondary,
                                style: TextStyle(color: cs.onPrimary),
                                decoration: deco(
                                  hint: 'Agency Number Hint',
                                  prefix: const Icon(Icons.numbers_outlined),
                                ),
                                onFieldSubmitted: (_) => login(context),
                              ),
                      
                              const SizedBox(height: 32),
                      
                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFf6b122),
                                    foregroundColor: cs.onSecondary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: c.isLoading
                                      ? null
                                      : () async {
                                          await login(context);
                                          if (PWAInstall().installPromptEnabled) {
                                            PWAInstall().promptInstall_();
                                          }
                                        },
                                  child: c.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Text(
                                          "Login".tr,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                ),
                              ),
                      
                              // بصمة (اختياري) تحت الزر بدون ما تكسر التصميم
                              // if (c.biometricEnabled && !kIsWeb) ...[
                              //   const SizedBox(height: 12),
                              //   Center(
                              //     child: IconButton(
                              //       iconSize: 34,
                              //       color: cs.onPrimary.withOpacity(0.9),
                              //       onPressed: () async {
                              //         context.loaderOverlay.show(
                              //           widgetBuilder: (_) => Center(
                              //             child: CircularProgressIndicator(
                              //               strokeWidth: 2,
                              //               color: cs.primaryContainer,
                              //             ),
                              //           ),
                              //         );
                              //         await c.loginWithBiometrics(context);
                              //         if (context.mounted) context.loaderOverlay.hide();
                              //       },
                              //       icon: const Icon(Icons.fingerprint_outlined),
                              //     ),
                              //   ),
                              // ],
                      
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget suffixIconPassword(BuildContext context, LoginController c) {
    final cs = Theme.of(context).colorScheme;
    if (c.biometricEnabled && !kIsWeb && c.passwordController.text == "") {
      return IconButton( 
        color: cs.onPrimary.withOpacity(0.9),
        iconSize: 28,
        onPressed: () async {
          context.loaderOverlay.show(
            widgetBuilder: (_) => Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primaryContainer,
              ),
            ),
          );
          await c.loginWithBiometrics(context);
          if (context.mounted) context.loaderOverlay.hide();
        },
        icon: const Icon(Icons.fingerprint_outlined),
      );
    }
    return IconButton(
      icon: Icon(
        c.isPasswordHidden ? Icons.visibility_off : Icons.visibility,
        color: cs.onPrimary,
      ),
      onPressed: c.togglePasswordVisibility,
    );
  }

}
