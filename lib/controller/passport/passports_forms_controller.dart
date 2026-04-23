import 'package:alzajeltravel/controller/flight/flight_detail_controller.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/repo/country_repo.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/model/contact_model.dart';
import 'package:alzajeltravel/model/country_model.dart';

import 'package:alzajeltravel/model/passport/passport_model.dart';
import 'package:alzajeltravel/model/passport/traveler_config.dart';
import 'package:alzajeltravel/controller/passport/passport_controller.dart';
import 'package:alzajeltravel/model/passport/traveler_review/seat_model.dart';
import 'package:alzajeltravel/model/passport/traveler_review/traveler_review_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

import 'package:alzajeltravel/view/frame/travelers_review/travelers_review_page.dart';

import 'package:alzajeltravel/utils/widgets/country_picker.dart'; // عدّل المسار لو مختلف

class PassportsFormsController extends GetxController {
  final FlightDetailApiController flightDetailApiController = Get.put(FlightDetailApiController());
  final SearchFlightController searchFlightController = Get.put(SearchFlightController());
  DateTime lastDateInSearch = DateTime.now();
  double totalFlight = 0;
  String currency = '';
  final int adultsCounter;
  final int childrenCounter;
  final int infantsInLapCounter;

  PassportsFormsController({required this.adultsCounter, required this.childrenCounter, required this.infantsInLapCounter});

  /// قائمة المسافرين (رقم + نوع + tag)
  late final List<TravelerConfig> travelers;

  /// حالة التوسّع لكل مسافر (true = مفتوح)
  late final List<bool> expandedFlags;

  /// اللغة الحالية (ar/en) لاختيار اسم الدولة
  final String lang = AppVars.lang ?? 'en';

  @override
  void onInit() {
    super.onInit();

    if (searchFlightController.forms.isNotEmpty && searchFlightController.forms[0].returnDatePickerController.selectedDate != null) {
      lastDateInSearch = searchFlightController.forms[0].returnDatePickerController.selectedDate!;
    } else if (searchFlightController.forms.isNotEmpty && searchFlightController.forms[0].departureDatePickerController.selectedDate != null) {
      lastDateInSearch = searchFlightController.forms[0].departureDatePickerController.selectedDate!;
    }

    print('lastDateInSearch: $lastDateInSearch');
    print('searchFlightController.forms[0].returnDatePickerController.selectedDate: ${searchFlightController.forms[0].returnDatePickerController.selectedDate}');
    print('searchFlightController.forms[0].departureDatePickerController.selectedDate: ${searchFlightController.forms[0].departureDatePickerController.selectedDate}');
    
    travelers = _buildTravelers();

    setContactDataFromProfile();

    // أول مسافر مفتوح والباقي مغلق
    expandedFlags = List<bool>.generate(travelers.length, (index) => index == 0);

    // 🔹 هنا ننشئ PassportController لكل مسافر مرة واحدة
    for (final t in travelers) {
      if (!Get.isRegistered<PassportController>(tag: t.tag)) {
        Get.put<PassportController>(PassportController(), tag: t.tag);
      }
    }
    if (flightDetailApiController.revalidatedDetails.value != null) {
      totalFlight = flightDetailApiController.revalidatedDetails.value!.offer.totalAmount;
      currency = flightDetailApiController.revalidatedDetails.value!.offer.currency;
    }
  }

  List<TravelerConfig> _buildTravelers() {
    final list = <TravelerConfig>[];
    int index = 1;

    for (int i = 0; i < adultsCounter; i++) {
      list.add(TravelerConfig(index: index++, ageGroup: AgeGroup.adult, tag: 'traveler_adult_$i'));
    }

    for (int i = 0; i < childrenCounter; i++) {
      list.add(TravelerConfig(index: index++, ageGroup: AgeGroup.child, tag: 'traveler_child_$i'));
    }

    for (int i = 0; i < infantsInLapCounter; i++) {
      list.add(TravelerConfig(index: index++, ageGroup: AgeGroup.infant, tag: 'traveler_infant_$i'));
    }

    return list;
  }

  void setContactDataFromProfile() {
    final ProfileModel? profile = AppVars.profile;
    if (profile != null) {
      contactTitle = ContactTitle.mr;
      contactFirstNameController.text = profile.name;
      contactLastNameController.text = (profile.name.split(" ").last.isEmpty) ? profile.name : profile.name.split(" ").last;
      contactEmailController.text = profile.email;
      contactCodeController.text = profile.agencyNumber;
      contactPhoneController.text = profile.phone;
      contactDialCountry = CountryRepo.searchByDialcode(dialcode: "967");
      contactNationalityCountry = CountryRepo.searchByAlpha("ye");
    }
  }

  String ageGroupLabel(AgeGroup group) {
    switch (group) {
      case AgeGroup.adult:
        return 'Adult'.tr;
      case AgeGroup.child:
        return 'Child'.tr;
      case AgeGroup.infant:
        return 'Infant'.tr;
    }
  }

  DateTime minDob(AgeGroup group) {
    final now = lastDateInSearch;
    switch (group) {
      case AgeGroup.adult:
        {
          final y = now.year - 120;
          final lastDay = DateTime(y, now.month + 1, 0).day;
          return DateTime(y, now.month, now.day > lastDay ? lastDay : now.day);
        }

      case AgeGroup.child:
        {
          // طفل: عمره أقل من 12 => DOB بعد (now - 12 سنة)
          final y = now.year - 12;
          final lastDay = DateTime(y, now.month + 1, 0).day;
          return DateTime(y, now.month, now.day > lastDay ? lastDay : now.day).add(const Duration(days: 1));
        }

      case AgeGroup.infant:
        {
          // رضيع: عمره أقل من 2 => DOB بعد (now - 2 سنة)
          final y = now.year - 2;
          final lastDay = DateTime(y, now.month + 1, 0).day;
          return DateTime(y, now.month, now.day > lastDay ? lastDay : now.day).add(const Duration(days: 1));
        }
    }
  }

  DateTime maxDob(AgeGroup group) {
    final now = lastDateInSearch;
    switch (group) {
      case AgeGroup.adult:
        {
          // بالغ: 12+ => أحدث DOB = (now - 12 سنة) (يشمل من أكمل 12 اليوم)
          final y = now.year - 12;
          final lastDay = DateTime(y, now.month + 1, 0).day;
          return DateTime(y, now.month, now.day > lastDay ? lastDay : now.day);
        }

      case AgeGroup.child:
        {
          // طفل: 2..11 => أحدث DOB = (now - 2 سنة) (يشمل من أكمل 2 اليوم)
          final y = now.year - 2;
          final lastDay = DateTime(y, now.month + 1, 0).day;
          return DateTime(y, now.month, now.day > lastDay ? lastDay : now.day);
        }

      case AgeGroup.infant:
        // رضيع: 0..<2 => أحدث DOB = اليوم
        return DateTime(now.year, now.month, now.day);
    }
  }

  /// مستدعاة من كل فورم عند تغيير وضع ExpansionTile
  void onTileExpansionChanged(int index, bool isExpanded) {
    if (!isExpanded) {
      // لو المستخدم قفل التايل بنفسه نخليها مقفولة
      expandedFlags[index] = false;
      update();
      return;
    }

    // لو فتح مسافر، نخليه الوحيد المفتوح
    for (int i = 0; i < expandedFlags.length; i++) {
      expandedFlags[i] = (i == index);
    }
    update();
  }

  /// فتح جميع الفورمات
  void expandAll() {
    for (int i = 0; i < expandedFlags.length; i++) {
      expandedFlags[i] = true;
    }
    update();
  }

  /// إغلاق جميع الفورمات
  void collapseAll() {
    for (int i = 0; i < expandedFlags.length; i++) {
      expandedFlags[i] = false;
    }
    update();
  }

  /// التحقق من البيانات لكل المسافرين
  Future<bool> validateAllForms() async {
    bool allValid = true;

    // 1) التحقق من جميع فورمات الباسبورت
    for (final traveler in travelers) {
      final controller = Get.find<PassportController>(tag: traveler.tag);
      final formState = controller.formKey.currentState;
      if (formState == null || !formState.validate()) {
        allValid = false;
      }
    }

    if (!allValid) {
      AppFuns.showSnack('Validation'.tr, 'Please complete all required passport fields'.tr, type: SnackType.warning);
      return false;
    }

    // 2) التحقق من فورم بيانات الاتصال
    final contactOk = validateContactForm();
    if (!contactOk) return false;

    return true;
  }

  /// جمع الموديلات
  List<PassportModel> collectModels() {
    return travelers.map((t) => Get.find<PassportController>(tag: t.tag).model).toList();
  }

  /// دالة الحفظ الكاملة
  /// دالة الحفظ الكاملة
  /// دالة الحفظ الكاملة
  Future<void> saveAll() async {
    AppFuns.hideKeyboard();
    // 1) افتح كل الفورمات مؤقتًا عشان تظهر الأخطاء
    expandAll();
    await Future.delayed(const Duration(milliseconds: 500));

    // إخفاء موثوق للوحة المفاتيح بعد توسيع الفورمات
    // (كانت تظهر لأن أحد الحقول كان autofocus)
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 50));

    // 2) تحقق من صحة كل النماذج
    final ok = await validateAllForms();
    if (!ok) return;

    // 3) جمّع بيانات الجوازات من الفورمات
    final passports = collectModels();

    // 4) أنشئ الحجز على السيرفر
    final bookingResponse = await createBookingServer(passports, contactModel);

    // طباعة debug (صححنا الـ interpolation)
    if (bookingResponse != null) {
      print("bookingResponse passengers: ${bookingResponse['passengers']}");
    }

    // لو حصل خطأ في الاتصال أو الرد ليس كما نتوقع
    if (bookingResponse == null) {
      return;
    }

    // تحقّق من وجود insert_id
    final insertId = bookingResponse['insert_id'];
    if (insertId == null) {
      AppFuns.showSnack('Error'.tr, 'Booking request failed, please try again.'.tr, type: SnackType.error);
      return;
    }


    // ______________________________________________________
    // 5) بناء قائمة TravelerReviewModel من رد السيرفر (passengers)
    final List<dynamic> passengersJson = (bookingResponse['passengers'] as List?) ?? [];

    final List<TravelerReviewModel> travelersReviewList = [];

    // نربط بين PassportModel و عنصر passengers بنفس الترتيب
    final int countPassports = passports.length;
    final int countTravelers = passengersJson.length;

    for (int index = 0; index < countTravelers; index++) {
      final passport = passports[index];

      Map<String, dynamic>? passengerJson;
      if (index < countTravelers && passengersJson[index] is Map<String, dynamic>) {
        passengerJson = passengersJson[index] as Map<String, dynamic>;
      }

      // نقرأ Base_Amount و Tax_Total من JSON، ولو مش موجودة نخليها 0
      final double baseFare = _parseDouble(passengerJson?['Base_Amount']);
      final double taxTotal = _parseDouble(passengerJson?['Tax_Total']);

      print("ageGroup 1: ${passengerJson?['ageGroup']}");
      print("ageGroup 2: ${passengerJson?['type']}");
      print("ageGroup 3: ${passengerJson?['paxType']}");
      print("ageGroup 4: ${passengerJson?['pax_type']}");
      print("issue_country: ${passengerJson?['issue_country']}");

      print("passengerJson?['gender']: ${passengerJson?['gender']}");
      print("passengerJson?['issuingCountry']: ${passengerJson?['issue_country']}");
      print("passengerJson?['nationality']: ${passengerJson?['nationality']}");

      final PassportModel travelerPassport = PassportModel.fromJson({
        "documentNumber": passengerJson?['passport_no'],
        "givenNames": passengerJson?['first_name'],
        "surnames": passengerJson?['last_name'],
        "dateOfBirth": passengerJson?['dob'],
        "sex": passengerJson?['gender'],
        "nationality": passengerJson?['nationality'],
        "issueCountry": passengerJson?['issue_country'],
        "dateOfExpiry": passengerJson?['expiry_date'],
      });

      Seat seat = Seat(name: "A12", fare: 12);

      AgeGroup _ageGroupFromAny(dynamic v) {
        final s = (v ?? '').toString().trim().toLowerCase();
        print('ageGroupFromAny: $s');
        if (s == 'inf' || s == 'infant') return AgeGroup.infant;
        if (s == 'cnn' || s == 'chd' || s == 'child') return AgeGroup.child;
        if (s == 'adt' || s == 'adult') return AgeGroup.adult;
        return AgeGroup.adult;
      }


      travelersReviewList.add(
        TravelerReviewModel(
          passport: travelerPassport,
          baseFare: baseFare,
          taxTotal: taxTotal,
          // لاحقًا لما تضيف اختيار مقعد فعلي، استبدل بـ المقعد الحقيقي
          seat: null,
          ageGroup: _ageGroupFromAny(passengerJson?['pax_type']),
        ),
      );
    }

    // 6) الانتقال إلى صفحة مراجعة المسافرين فقط إذا كان الحجز انشأ بنجاح
    Get.to(() => TravelersReviewPage(travelers: travelersReviewList, insertId: insertId, contact: contactModel));

    // ______________________________________________________
    // 7) إشعار بسيط بعد التجميع (اختياري)
    AppFuns.showSnack(
      'Passports'.tr,
      'Collected @count passports'.trParams({'count': passports.length.toString()}),
      type: SnackType.success,
    );
  }

  double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  /// تنسيق التاريخ إلى YYYY-MM-DD كما في مثال الـ API
  String _formatDate(DateTime? d) {
    if (d == null) return "";
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  /// تحويل AgeGroup إلى كود المسافر في الـ API
  String _passengerType(AgeGroup group) {
    switch (group) {
      case AgeGroup.adult:
        return "ADT";
      case AgeGroup.child:
        return "CHD";
      case AgeGroup.infant:
        return "INF";
    }
  }

  /// عنوان الراكب (MR/MS) بناءً على الجنس، افتراضي MR
  String _passengerTitle(PassportModel p) {
    if (p.sex == Sex.female) {
      return "MS";
    }
    return "MR";
  }

  /// كود دولة الإصدار (عدّل alpha2 حسب CountryModel عندك)
  String _issueCountryCode(PassportModel p) {
    // غيّر 'alpha2' إلى اسم الحقل الصحيح في CountryModel لو يختلف
    return p.issuingCountry?.alpha2 ?? p.issuingCountry?.alpha3 ?? "";
  }
  String _nationalityCode(PassportModel p) {
    // غيّر 'alpha2' إلى اسم الحقل الصحيح في CountryModel لو يختلف
    return p.nationality?.alpha2 ?? p.nationality?.alpha3 ?? "";
  }

  DateTime? parseTktTimeLimit(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return null;

    // يحول "2025-12-31 23:59:59" إلى "2025-12-31T23:59:59" عشان DateTime.parse يكون مضمون
    final normalized = s.contains('T') ? s : s.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }

  Future<Map<String, dynamic>?> createBookingServer(List<PassportModel> passports, ContactModel contact) async {
    // 1) حضّر بيانات الاتصال (contact) كما طلبت بالضبط
    //  final Map<String, dynamic> contact = {
    //     "title": "MR",
    //     "first_name": "MOHAMMED",
    //     "last_name": "TEST",
    //     "email": "test@example.com",
    //     "phone": "775775000",
    //     "country_code": "+967",
    //     "nationality": "YE_Yemen",
    //   };

    // 2) حضّر passengers من List<PassportModel> + travelers (لنستخرج type)
    final List<Map<String, dynamic>> passengers = [];

    for (int i = 0; i < passports.length; i++) {
      final passport = passports[i];
      final travelerConfig = travelers[i]; // نفس الترتيب كما في collectModels()

      final String type = _passengerType(travelerConfig.ageGroup);
      final String title = _passengerTitle(passport);
      final String firstName = (passport.givenNames ?? "").toUpperCase();
      final String lastName = (passport.surnames ?? "").toUpperCase();

      final String dob = _formatDate(passport.dateOfBirth);
      final String passportNo = passport.documentNumber ?? "";
      final String issueCountry = _issueCountryCode(passport);
      final String nationality = _nationalityCode(passport);

      // 🔸 ما عندنا حقل issue_date في PassportModel حاليًا،
      //    لذلك نرسلها فارغة أو تضيف لها لاحقًا عندما تضيف الحقل للموديل.
      final String issueDate = ""; // TODO: اربطها بحقل من الفورم إذا أضفته لاحقًا

      final String expiryDate = _formatDate(passport.dateOfExpiry);

      passengers.add({
        "type": type, // ADT / CHD / INF
        "title": title, // MR / MS
        "first_name": firstName, // ADULT
        "last_name": lastName, // TEST
        "dob": dob, // 1995-01-01
        "passport_no": passportNo, // A100000
        "issue_country": issueCountry, // SA
        "nationality": nationality,
        "issue_date": null, // 2024-01-01 (لاحقاً)
        "expiry_date": expiryDate, // 2029-01-01
        "frequent_travel_number": "", // حاليًا فارغة
      });
    }

    // 3) بناء params النهائي
    final Map<String, dynamic> params = {
      "api_session_id": AppVars.apiSessionId, // من نتائج البحث
      "contact": contact.toApiJson(),
      "passengers": passengers,
    };

    // 4) استدعاء API
    final response = await AppVars.api.post(AppApis.createBookingFlight, params: params);

    if (response == null) {
      AppFuns.showSnack('Error'.tr, 'Could not create booking'.tr, type: SnackType.error);
      return null;
    }

    // نتوقع شكل الرد:
    // {
    //   "status": "success",
    //   "insert_id": 589,
    //   "booking_id": "SKY626574107338541",
    //   "booking_status": "PENDING"
    // }

    if (response is Map<String, dynamic>) {
      final tkt = response['flight']?['TktTimeLimit'];
      final c = flightDetailApiController.revalidatedDetails;
      final current = c.value;
      if (current != null) {
        c.value = current.copyWith(timeLimit: parseTktTimeLimit(tkt));
        print('timeLimit: ${flightDetailApiController.revalidatedDetails.value?.timeLimit}');
      }

      return response;
    }

    return null;

    // لو حاب تتعامل مع الرد (PNR / booking id ...) أضف منطقك هنا
    // debugPrint(response.toString());
  }

  /// فتح الفورم التالي بعد المسافر الحالي
  void goToNextTraveler(int currentIndex) {
    final nextIndex = currentIndex + 1;

    // لو هذا آخر مسافر، لا يوجد "التالي"
    if (nextIndex >= travelers.length) {
      return;
    }

    for (int i = 0; i < expandedFlags.length; i++) {
      expandedFlags[i] = (i == nextIndex); // افتح التالي وأغلق الباقي
    }

    update();
  }

  @override
  void onClose() {
    // حذف جميع PassportController المرتبطين بهذه الشاشة
    for (final t in travelers) {
      if (Get.isRegistered<PassportController>(tag: t.tag)) {
        Get.delete<PassportController>(tag: t.tag);
      }
    }
    contactFirstNameController.dispose();
    contactLastNameController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    super.onClose();
  }

  // ******** Contact info form ********

  final GlobalKey<FormState> contactFormKey = GlobalKey<FormState>();

  final TextEditingController contactFirstNameController = TextEditingController();
  final TextEditingController contactLastNameController = TextEditingController();
  final TextEditingController contactEmailController = TextEditingController();
  final TextEditingController contactCodeController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  CountryModel? contactDialCountry;
  CountryModel? contactNationalityCountry;
  String? get contactDialCode => (contactDialCountry == null) ? null : '+${contactDialCountry!.dialcode}';
  String? get contactNationality =>
      (contactNationalityCountry == null) ? null : '${contactNationalityCountry!.alpha2}_${contactNationalityCountry!.name['en']}';

  // لقب المتصل (MR / MISS / MRS) - عدّل القيمة الافتراضية حسب ما تستخدم في الواجهة
  ContactTitle contactTitle = ContactTitle.mr;

  /// يبني ContactModel من حقول الفورم
  ContactModel get contactModel {
    return ContactModel(
      title: contactTitle,
      firstName: contactFirstNameController.text.trim(),
      lastName: contactLastNameController.text.trim(),
      email: contactEmailController.text.trim(),
      phone: contactPhoneController.text.trim(),
      phoneCountry: contactDialCountry!, // مفترض أنك تحققت منه في validateContactForm
      nationality:
          contactNationalityCountry ?? // لو ما اختر الجنسيّة، نستخدم نفس دولة الجوال مثلاً
          contactDialCountry!,
    );
  }

  Future<void> pickContactDialCountry() async {
    final result = await Get.to<CountryModel>(() => const CountryPicker(showDialCode: true));

    if (result != null) {
      contactDialCountry = result;

      // لو الجنسية لسه ما تحددت، نخليها نفس دولة الاتصال
      contactNationalityCountry ??= result;

      update(); // لتحديث الواجهات التي تستخدم الكنترولر
    }
  }

  Future<void> pickContactNationalityCountry() async {
    final result = await Get.to<CountryModel>(() => const CountryPicker(showDialCode: false));

    if (result != null) {
      contactNationalityCountry = result;
      update(); // لتحديث الواجهات التي تستخدم الكنترولر
    }
  }

  bool validateContactForm() {
    final formState = contactFormKey.currentState;
    if (formState == null || !formState.validate()) {
      AppFuns.showSnack('Validation'.tr, 'Please complete all required contact fields'.tr, type: SnackType.warning);
      return false;
    }

    if (contactDialCountry == null) {
      AppFuns.showSnack('Validation'.tr, 'Please select country dial code'.tr, type: SnackType.warning);
      return false;
    }

    return true;
  }


  List<TravelerConfig> get sortedTravelers {
    final list = [...travelers];

    list.sort((a, b) {
      final aDone = Get.find<PassportController>(tag: a.tag).isFullData;
      final bDone = Get.find<PassportController>(tag: b.tag).isFullData;

      if (aDone == bDone) {
        // حافظ على نفس ترتيبهم الأصلي داخل كل مجموعة
        return a.index.compareTo(b.index);
      }

      // false (غير مكتمل) أولاً، true (مكتمل) أخيراً
      return aDone ? 1 : -1;
    });

    return list;
  }

  /// نستخدمها فقط لعمل rebuild للصفحة كي ينعكس الفرز
  void refreshOrder() => update();

  /// Helpers حتى لا تتلخبط expandedFlags بعد الفرز
  int indexByTag(String tag) => travelers.indexWhere((t) => t.tag == tag);

  bool isExpandedByTag(String tag) {
    final i = indexByTag(tag);
    return i >= 0 ? expandedFlags[i] : false;
  }

  void onTileExpansionChangedByTag(String tag, bool isExpanded) {
    final i = indexByTag(tag);
    if (i == -1) return;
    onTileExpansionChanged(i, isExpanded);
  }

  /// فتح التالي حسب ترتيب العرض الحالي (بعد الفرز)
  String? openNextByTag(String currentTag) {
    final ordered = sortedTravelers;
    final pos = ordered.indexWhere((t) => t.tag == currentTag);
    if (pos == -1 || pos == ordered.length - 1) return null;

    final nextTag = ordered[pos + 1].tag;
    final nextIndex = indexByTag(nextTag);

    for (int i = 0; i < expandedFlags.length; i++) {
      expandedFlags[i] = (i == nextIndex);
    }
    update();
    return nextTag;
  }



//dlksgjflksdgfdmkgmlkfdfmhlfkgmhlkgtfmhlkf

// تتبع آخر حالة isFullData لكل مسافر
final Map<String, bool> _fullCache = {};

/// ترجع:
///  0 = لا تغيير / أو أول مرة نشوف هذا التاج
///  1 = صار مكتمل الآن (false -> true)
/// -1 = صار غير مكتمل الآن (true -> false)
int recordFullState(String tag, bool isFull) {
  final prev = _fullCache[tag];
  if (prev == null) {
    _fullCache[tag] = isFull;
    return 0;
  }
  if (prev == isFull) return 0;

  _fullCache[tag] = isFull;
  return isFull ? 1 : -1;
}

/// افتح أول مسافر غير مكتمل (ويغلق الباقي)
void openFirstIncomplete() {
  TravelerConfig? target;

  // بما أن sortedTravelers يضع الناقص أولاً، أول ناقص هو المطلوب
  for (final t in sortedTravelers) {
    final done = Get.find<PassportController>(tag: t.tag).isFullData;
    if (!done) {
      target = t;
      break;
    }
  }

  if (target == null) {
    // كلهم مكتملين: اقفل الكل (اختياري)
    for (int i = 0; i < expandedFlags.length; i++) {
      expandedFlags[i] = false;
    }
    update();
    return;
  }

  final idx = indexByTag(target.tag);

  for (int i = 0; i < expandedFlags.length; i++) {
    expandedFlags[i] = (i == idx); // واحد فقط مفتوح
  }

  update();
}




}
