import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets/custom_snack_bar.dart';
import 'package:alzajeltravel/view/profile/change_password.dart';
import 'package:alzajeltravel/view/profile/permissions_page.dart';
import 'package:alzajeltravel/view/profile/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/profile/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  final ProfileModel data;
  const ProfilePage({super.key, required this.data});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController(initialData: widget.data));
  }

  @override
  void dispose() {
    // لو عندك أكثر من ProfilePage ممكن تستخدم tag بدل put العادي
    // هنا ما نحذف controller يدويًا لأن GetX يدير lifecycle غالبًا
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GetBuilder<ProfileController>(
      builder: (c) {

        return Scaffold(
          appBar: AppBar(title: Text('Profile Account'.tr), titleSpacing: 15),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  //  const SizedBox(height: 20),
                  // ProfileBalanceCharts(profile: widget.data),
                  Divider(height: 0, thickness: 2),

                  const SizedBox(height: 20),

                  // Form(
                  //   key: c.formKey,
                  //   child: ExpansionTile(
                  //     initiallyExpanded: true,
                  //     tilePadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  //     title: Text("Profile".tr),
                  //     // subtitle: Text("close and reopen all open command prompts", style: TextStyle(color: Colors.grey[600])),
                  //     childrenPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  //     children: [
                  //       const SizedBox(height: 12),
                  //       // TextFormField(
                  //       //   controller: c.companyRegistrationNumberController,
                  //       //   decoration: InputDecoration(
                  //       //     labelText: 'Company Registration Number'.tr,
                  //       //     hintText: 'Enter Company Registration Number'.tr,
                  //       //   ),
                  //       //   validator: (v) => c.validateRequired(v, 'Company Registration Number Required'),
                  //       //   textInputAction: TextInputAction.next,
                  //       // ),
                  //       // const SizedBox(height: 12),
                  //       TextFormField(
                  //         readOnly: true,
                  //         controller: c.nameController,
                  //         decoration: InputDecoration(labelText: 'Name'.tr, hintText: 'Enter Name'.tr),
                  //         validator: (v) => c.validateRequired(v, 'Name Required'),
                  //         textInputAction: TextInputAction.next,
                  //       ),
                  //       const SizedBox(height: 12),
                  //       TextFormField(
                  //         readOnly: true,
                  //         controller: c.emailController,
                  //         keyboardType: TextInputType.emailAddress,
                  //         decoration: InputDecoration(labelText: 'Email'.tr, hintText: 'Enter Email'.tr),
                  //         validator: c.validateEmail,
                  //         textInputAction: TextInputAction.next,
                  //       ),
                  //       const SizedBox(height: 12),
                  //       TextFormField(
                  //         readOnly: true,
                  //         controller: c.agencyNumberController,
                  //         keyboardType: TextInputType.number,
                  //         decoration: InputDecoration(labelText: 'Agency Number'.tr, hintText: 'Enter Agency Number'.tr),
                  //         validator: (v) => c.validateRequired(v, 'Agency Number Required'),
                  //         textInputAction: TextInputAction.next,
                  //       ),
                  //       const SizedBox(height: 12),
                  //       TextFormField(
                  //         readOnly: true,
                  //         controller: c.phoneController,
                  //         keyboardType: TextInputType.phone,
                  //         decoration: InputDecoration(labelText: 'Phone'.tr, hintText: 'Enter Phone'.tr),
                  //         validator: (v) => c.validateRequired(v, 'Phone Required'),
                  //         textInputAction: TextInputAction.next,
                  //       ),
                  //       const SizedBox(height: 12),
                  //       // Country (readOnly + open picker)
                  //       // TextFormField(
                  //       //   controller: c.countryController,
                  //       //   readOnly: true,
                  //       //   decoration: InputDecoration(
                  //       //     labelText: 'Country'.tr,
                  //       //     hintText: 'Select Country'.tr,
                  //       //     suffixIcon: const Icon(Icons.arrow_drop_down),
                  //       //   ),
                  //       //   onTap: c.pickCountry,
                  //       //   validator: (v) => c.validateRequired(v, 'Country Required'),
                  //       // ),
                  //       // const SizedBox(height: 12),
                  //       // TextFormField(
                  //       //   controller: c.addressController,
                  //       //   decoration: InputDecoration(labelText: 'Address'.tr, hintText: 'Enter Address'.tr),
                  //       //   textInputAction: TextInputAction.next,
                  //       // ),
                  //       // const SizedBox(height: 12),
                  //       // TextFormField(
                  //       //   controller: c.websiteController,
                  //       //   keyboardType: TextInputType.url,
                  //       //   decoration: InputDecoration(labelText: 'Website'.tr, hintText: 'Enter Website'.tr),
                  //       //   textInputAction: TextInputAction.next,
                  //       // ),
                  //       // const SizedBox(height: 12),
                  //       // branch code
                  //       // TextFormField(
                  //       //   controller: c.branchCodeController,
                  //       //   decoration: InputDecoration(labelText: 'Branch Code'.tr, hintText: 'Enter Branch Code'.tr),
                  //       //   readOnly: true,
                  //       //   textInputAction: TextInputAction.next,
                  //       // ),
                  //       const SizedBox(height: 12),
                  //       // Status (readOnly)
                  //       TextFormField(
                  //         controller: c.statusController,
                  //         readOnly: true,
                  //         decoration: InputDecoration(labelText: 'Status'.tr, hintText: 'Status'.tr),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ProfileHeaderCard(
                      name: c.nameController.text,
                      email: c.emailController.text,
                      agencyNumber: c.agencyNumberController.text,
                      statusText: c.statusController.text,
                      isApproved: true,
                      avatarText: AppFuns.getAvatarText(c.nameController.text),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: BalanceCard(data: widget.data, context: context),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12), 
                    child: PermissionsPage(),
                  ),

                  const SizedBox(height: 16),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12), child: ChangePassword()),
                
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key, required this.data, required this.context});

  final ProfileModel data;
  final BuildContext context;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool isHidden = true;

  double get _balance {
    return double.tryParse(widget.data.remainingBalance?.toString() ?? '') ?? 0.0;
  }

  String get _formattedBalance {
    return AppFuns.priceWithCoin(_balance, "USD");
  }

  Future<void> _copyBalance() async {
    await Clipboard.setData(ClipboardData(text: _formattedBalance));
    if (mounted) CustomSnackBar.success(context, "Copied".tr, subtitle: "Copied to clipboard".tr);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConsts.primaryColor,
            Color(0xFF1E2F7A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppConsts.primaryColor.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // دائرة ذهبية زخرفية شفّافة في الزاوية (glow حديث)
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConsts.secondaryColor.withValues(alpha: 0.18),
                    AppConsts.secondaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConsts.secondaryColor.withValues(alpha: 0.08),
                    AppConsts.secondaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // المحتوى
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // شريط ذهبي صغير أفقي
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppConsts.secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remaining Balance'.tr,
                      style: const TextStyle(
                        fontSize: AppConsts.normal,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _copyBalance,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.copy_rounded,
                          color: Colors.white.withValues(alpha: 0.75),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: child,
                        ),
                        child: isHidden
                            ? Text(
                                '• • • • • • • •',
                                key: const ValueKey('hidden'),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: AppConsts.secondaryColor,
                                ),
                              )
                            : SelectableText(
                                _formattedBalance,
                                key: const ValueKey('value'),
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppConsts.secondaryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => isHidden = !isHidden),
                      icon: Icon(
                        isHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip: isHidden ? 'Show'.tr : 'Hide'.tr,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
