import 'package:alzajeltravel/controller/login/login_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/view/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController controller;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(LoginController(), permanent: false,);
    AppVars.getStorage.write("first_run", false);
  }

  Future<void> login(BuildContext context) async {
    context.loaderOverlay.show();
    await controller.login(validateForm: (formKey.currentState?.validate() ?? false));
    if(context.mounted) context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GetBuilder<LoginController>(
      builder: (c) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Login'.tr),
            titleSpacing: 15,
            actions: [
              IconButton(
                tooltip: "Settings".tr,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Get.to(() => SettingsPage());
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),

                    Text("Login".tr, style: TextStyle(fontSize: AppConsts.normal * 2, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 8),
                    Text("Access to competitive global airfare content through the New Horizons system.".tr, style: TextStyle(fontSize: AppConsts.normal),),
                    const SizedBox(height: 24), 

                    // Email
                    TextFormField(
                      controller: c.emailController, 
                      focusNode: c.emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: c.validateEmail,
                      decoration: InputDecoration(
                        labelText: 'Email'.tr,
                        hintText: 'Email Hint'.tr,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(c.passwordFocus);
                      },
                    ),

                    const SizedBox(height: 12),

                    // Password
                    TextFormField(
                      controller: c.passwordController,
                      focusNode: c.passwordFocus,
                      obscureText: c.isPasswordHidden,
                      textInputAction: TextInputAction.next,
                      validator: c.validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Password'.tr,
                        hintText: 'Password Hint'.tr,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          onPressed: c.togglePasswordVisibility,
                          icon: Icon(
                            c.isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: 'Toggle Password'.tr,
                        ),
                      ),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(c.agencyFocus);
                      },
                    ),

                    const SizedBox(height: 12),

                    // Agency Number
                    TextFormField(
                      controller: c.agencyNumberController,
                      focusNode: c.agencyFocus,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done, // Done
                      validator: c.validateAgencyNumber,
                      decoration: InputDecoration(
                        labelText: 'Agency Number'.tr,
                        hintText: 'Agency Number Hint'.tr,
                        prefixIcon: const Icon(Icons.numbers_outlined),
                      ),
                      onFieldSubmitted: (_) {
                        // نفس زر تسجيل الدخول
                        login(context);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Login Button
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 58,
                            child: ElevatedButton(
                              onPressed: c.isLoading ? null : () {
                                login(context);
                              },
                              child: c.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text('Login'.tr, style: TextStyle(fontSize: AppConsts.lg),),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if(c.biometricEnabled)
                          if(!kIsWeb)
                            SizedBox(
                              height: 58,
                              child: ElevatedButton(
                                onPressed: () async {
                                  context.loaderOverlay.show(
                                    widgetBuilder: (context) => Center(
                                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.primaryContainer,),
                                    ),
                                  );
                                  await c.loginWithBiometrics();
                                  if(context.mounted) context.loaderOverlay.hide();
                                },
                                child: Icon(Icons.fingerprint_outlined, size: 32,),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
