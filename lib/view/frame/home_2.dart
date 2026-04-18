import 'package:alzajeltravel/controller/bookings_report/trip_detail/booking_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/flight_detail.dart';
import 'package:alzajeltravel/controller/bookings_report/trip_detail/travelers_detail.dart';
import 'package:alzajeltravel/model/bookings_report/bookings_report_model.dart';
import 'package:alzajeltravel/model/contact_model.dart';
import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/utils/widgets/custom_dialog.dart';
import 'package:alzajeltravel/utils/widgets/custom_snack_bar.dart';
import 'package:alzajeltravel/view/frame/issuing/issuing_page.dart';
import 'package:alzajeltravel/view/profile/profile_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key, required this.persistentTabController});

  final PersistentTabController persistentTabController;

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  ProfileModel? profileModel;
  BookingsReportData? latestBookings;
  LatestBookingsController latestBookingsController = Get.put(LatestBookingsController());

  /// تُبنى عند كل `build` حتى تُترجَم `.tr` حسب اللغة الحالية.
  /// (إذا حُفظت في initState تبقى اللغة القديمة بعد التبديل.)
  List<Map> _buildServices() {
    return [
      {
        'svg': 'flight',
        'title': 'Flightss'.tr,
        'onTap': () {
          widget.persistentTabController.jumpToTab(1);
        },
      },
      {
        'svg': 'hotel',
        'title': 'HOTELS'.tr,
        'onTap': () async {
          await CustomDialog.warning(
            context,
            title: "This service is not currently available".tr,
            desc: null,
          );
        },
      },
      {
        'svg': 'car',
        'title': 'Cars'.tr,
        'onTap': () async {
          await CustomDialog.warning(
            context,
            title: "This service is not currently available".tr,
            desc: null,
          );
        },
      },
      {
        'svg': 'train',
        'title': 'Train'.tr,
        'onTap': () async {
          await CustomDialog.warning(
            context,
            title: "This service is not currently available".tr,
            desc: null,
          );
        },
      },
      {
        'svg': 'package',
        'title': 'Packages'.tr,
        'onTap': () async {
          await CustomDialog.warning(
            context,
            title: "This service is not currently available".tr,
            desc: null,
          );
        },
      },
      {
        'svg': 'visa',
        'title': 'Visa'.tr,
        'onTap': () async {
          await CustomDialog.warning(
            context,
            title: "This service is not currently available".tr,
            desc: null,
          );
        },
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    profileModel = GetStorage().read('profile') != null
        ? ProfileModel.fromJson(GetStorage().read('profile'))
        : null;
  }



  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final services = _buildServices();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alzajel Travel'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppConsts.xlg,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppConsts.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: AppConsts.xlg,
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          // نستخدم context الخاص بـ _Home2State لأنّ Scaffold الذي يحمل الـ Drawer
          // موجود في الواجهة الأعلى (frame.dart). Builder الداخلي كان يُرجع Scaffold
          // الداخلي بلا drawer فيعطّل الزرّ.
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded, color: AppConsts.secondaryColor, size: 26),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: IconButton(
              onPressed: () async {
                await CustomDialog.warning(
                  context,
                  title: "This service is not currently available",
                  desc: null,
                );
              },
              icon: SvgPicture.asset(AppConsts.logo3, width: 34),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: AppFuns.refreshHomePage,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: BalanceCard(data: profileModel!, context: context),
              ),

              // ═════ Carousel — بإطار مدوّر ناعم ═════
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 110,
                      autoPlay: true,
                      viewportFraction: 1,
                    ),
                    items: List.generate(6, (index) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppConsts.primaryColor.withValues(alpha: 0.10),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                "assets/tmp/1.jpg",
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),

              // ═════ Services section ═════
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppConsts.secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Services'.tr,
                      style: TextStyle(
                        fontSize: AppConsts.xlg,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ServiceCard(
                    svgName: service['svg'],
                    title: service['title'],
                    onTap: service['onTap'],
                  );
                },
              ),
              const SizedBox(height: 20),
              ...[
                // ═════ Section header with gold accent ═════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppConsts.secondaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Latest operations".tr,
                        style: TextStyle(
                          fontSize: AppConsts.xlg,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          widget.persistentTabController.jumpToTab(2);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppConsts.secondaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: AppConsts.normal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: Text("Show more".tr),
                        label: Icon(
                          AppVars.lang == 'ar' ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                GetBuilder<LatestBookingsController>(
                  builder: (controller) {
                    if (controller.loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(color: AppConsts.secondaryColor),
                        ),
                      );
                    } else if (controller.error != null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            "${controller.error}",
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                      );
                    }

                    final visibleItems = controller.latestBookings!.items
                        .where((e) => e.flightStatus != BookingStatus.pending)
                        .toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: visibleItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = visibleItems[index];
                        return _LatestBookingTile(
                          item: item,
                          onTap: () => _openBookingDetail(context, item),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 4),
              ],
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Helpers for latest bookings on Home
// ═══════════════════════════════════════════════════════════════════════

Future<void> _openBookingDetail(BuildContext context, BookingReportItem item) async {
  context.loaderOverlay.show();
  try {
    final insertId = item.tripApi.split("/").last;
    final response = await AppVars.api.get(AppApis.tripDetail + insertId);

    final pnr = response['flight']['UniqueID'] ?? "N/A".tr;
    final booking = BookingDetail.bookingDetail(response['booking']);
    final flight = FlightDetail.flightDetail(response['flight']);
    final travelers = TravelersDetail.travelersDetail(response['flight'], response['passengers']);

    final contact = ContactModel.fromApiJson({
      'title': "MR",
      'first_name': booking.customerId.split("@").first,
      'last_name': "_",
      'email': booking.customerId,
      'phone': booking.mobileNo,
      'country_code': booking.countryCode,
      'nationality': "ye",
    });

    if (context.mounted) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: IssuingPage(
          offerDetail: flight,
          travelers: travelers,
          contact: contact,
          pnr: pnr,
          booking: booking,
          fromPage: "home",
        ),
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }
  } catch (e) {
    debugPrint("error: $e");
  }
  if (context.mounted) context.loaderOverlay.hide();
}

({Color color, IconData icon}) _statusVisuals(BookingStatus s) {
  if (s == BookingStatus.confirmed) {
    return (color: const Color(0xFF2E7D32), icon: Icons.check_circle_rounded);
  }
  if (s == BookingStatus.preBooking || s == BookingStatus.pending) {
    return (color: const Color(0xFFF59E0B), icon: Icons.schedule_rounded);
  }
  if (s == BookingStatus.canceled || s == BookingStatus.expiry) {
    return (color: const Color(0xFFC62828), icon: Icons.cancel_rounded);
  }
  if (s == BookingStatus.voided || s == BookingStatus.voide) {
    return (color: const Color(0xFF8E24AA), icon: Icons.block_rounded);
  }
  return (color: const Color(0xFF78909C), icon: Icons.help_outline_rounded);
}

class _LatestBookingTile extends StatelessWidget {
  final BookingReportItem item;
  final VoidCallback onTap;
  const _LatestBookingTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRtl = AppVars.lang == 'ar';
    final planeTurns = isRtl ? 3 : 1;

    final status = _statusVisuals(item.flightStatus);
    final relativeTime = AppFuns.replaceArabicNumbers(
      Jiffy.parseFromDateTime(item.createdAt).fromNow(),
    );

    // يعرض الوقت فقط لو كان حقيقيًّا (API ترجع التاريخ بدون وقت أحيانًا
    // فيظهر كـ 00:00 — نتجنّب عرض هذا الوقت الوهمي).
    final td = item.travelDate;
    final hasRealFlightTime = td.hour != 0 || td.minute != 0 || td.second != 0;
    final travelDateFormatted = AppFuns.replaceArabicNumbers(
      DateFormat(
        hasRealFlightTime ? 'dd MMM yyyy · hh:mm a' : 'dd MMM yyyy',
        AppVars.lang,
      ).format(td),
    );

    // وقت إنشاء الحجز: قيمة حقيقية دائمًا — نعرضها كنصّ تفصيلي (HH:mm)
    // بجانب الصياغة النسبيّة (an hour ago).
    final createdAtTime = AppFuns.replaceArabicNumbers(
      DateFormat('hh:mm a', AppVars.lang).format(item.createdAt),
    );

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppConsts.secondaryColor.withValues(alpha: 0.10),
        highlightColor: AppConsts.secondaryColor.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═════ ❶ Route (full width) ═════
              _RouteLine(
                originName: item.origin.name[AppVars.lang] ?? '',
                originCode: item.origin.code,
                destName: item.destination.name[AppVars.lang] ?? '',
                destCode: item.destination.code,
                planeTurns: planeTurns,
                cs: cs,
              ),

              const SizedBox(height: 12),

              // فاصل ناعم
              Divider(height: 1, thickness: 1, color: cs.outlineVariant.withValues(alpha: 0.35)),

              const SizedBox(height: 10),

              // ═════ ❷ Status + Price (السعر مرتفع على سطر مستقلّ، خطّ أكبر) ═════
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.14),
                      border: Border.all(color: status.color.withValues(alpha: 0.55), width: 1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(status.icon, size: 13, color: status.color),
                        const SizedBox(width: 4),
                        Text(
                          item.flightStatus.name.tr,
                          style: TextStyle(
                            color: status.color,
                            fontSize: AppConsts.sm,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // السعر — حجم أكبر، وزن عريض، لون ذهبي مُميَّز
                  Text(
                    AppFuns.priceWithCoin(item.totalAmount, item.currency),
                    style: const TextStyle(
                      color: AppConsts.secondaryColor,
                      fontSize: AppConsts.xlg,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ═════ ❸ Travel date (بداية الصف) ═════
              Row(
                children: [
                  Icon(Icons.event_rounded, size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      travelDateFormatted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppConsts.sm,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ═════ ❹ Created-at — مُحاذى لطرف البطاقة (يعمل في RTL و LTR) ═════
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded, size: 12, color: cs.onSurfaceVariant.withValues(alpha: 0.75)),
                    const SizedBox(width: 4),
                    Text(
                      '$createdAtTime · $relativeTime',
                      style: TextStyle(
                        fontSize: AppConsts.xsm,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  final String originName, originCode, destName, destCode;
  final int planeTurns;
  final ColorScheme cs;

  const _RouteLine({
    required this.originName,
    required this.originCode,
    required this.destName,
    required this.destCode,
    required this.planeTurns,
    required this.cs,
  });

  Widget _dot() => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppConsts.secondaryColor,
          boxShadow: [
            BoxShadow(color: AppConsts.secondaryColor.withValues(alpha: 0.5), blurRadius: 4),
          ],
        ),
      );

  Widget _line({required bool fromStart}) {
    final colors = fromStart
        ? [
            AppConsts.secondaryColor.withValues(alpha: 0.75),
            AppConsts.secondaryColor.withValues(alpha: 0.0),
          ]
        : [
            AppConsts.secondaryColor.withValues(alpha: 0.0),
            AppConsts.secondaryColor.withValues(alpha: 0.75),
          ];
    return Container(
      height: 1,
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: AppConsts.normal,
      color: cs.onSurface,
    );
    final codeStyle = TextStyle(
      fontSize: 10,
      color: cs.onSurfaceVariant,
      letterSpacing: 1,
    );

    Widget city(String name, String code, CrossAxisAlignment align, TextAlign textAlign) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 110),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: align,
          children: [
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: textAlign, style: nameStyle),
            Text(code, textAlign: textAlign, style: codeStyle),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        city(originName, originCode, CrossAxisAlignment.start, TextAlign.start),
        const SizedBox(width: 6),
        _dot(),
        Expanded(child: _line(fromStart: true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: RotatedBox(
            quarterTurns: planeTurns,
            child: const Icon(
              Icons.flight_rounded,
              size: 18,
              color: AppConsts.secondaryColor,
            ),
          ),
        ),
        Expanded(child: _line(fromStart: false)),
        _dot(),
        const SizedBox(width: 6),
        city(destName, destCode, CrossAxisAlignment.end, TextAlign.end),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String svgName;
  final String title;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.svgName, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folder = isDark ? 'dark' : 'light';
    final svgPath = 'assets/svg/$folder/$svgName.svg';

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: AppConsts.secondaryColor.withValues(alpha: 0.15),
        highlightColor: AppConsts.secondaryColor.withValues(alpha: 0.06),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
            // تدرّج خفيف يبرز الأيقونة
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConsts.secondaryColor.withValues(alpha: isDark ? 0.06 : 0.04),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // دائرة ذهبية شفّافة خلف الأيقونة (glow حديث)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppConsts.secondaryColor.withValues(alpha: isDark ? 0.18 : 0.14),
                      AppConsts.secondaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(svgPath, width: 34, height: 34),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: AppConsts.normal,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class LatestBookingsController extends GetxController {
  BookingsReportData? latestBookings;
  bool loading = false;
  String? error;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      loading = true;
      latestBookings = null;
      error = null;

      update();

      print("Fetching latest bookings...");
      final response = await AppVars.api.post(
        AppApis.bookingsReport,
        params: {
          "api_session_id": AppVars.apiSessionId,
          "status": BookingStatus.all.apiValue,
          "date_from": null,
          "date_to": null,
          "full_details": 0,
          "limit": 30,
          "offset": 0,
        },
        asJson: true,
      );

      if ((response['status'] ?? '').toString() != 'success') {
        throw Exception((response['message'] ?? 'Request failed'.tr).toString());
      }

      final dataJson = (response['data'] ?? {}) as Map<String, dynamic>;
      print("Latest bookings data: ${dataJson['items']}"); 
      latestBookings = BookingsReportData.fromJson(dataJson);

      update();


    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }



}
