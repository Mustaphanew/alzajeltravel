import 'package:flutter/material.dart';
import 'package:alzajeltravel/utils/app_consts.dart';

class Themes {
  /// فصل لوني للوضع الفاتح: خلفية مزرّقة فاتحة، بطاقات بيضاء، نص ثانوي رمادي‑مزرّق
  static const Color _lightSurface = Color(0xFFF2F5FB);
  static const Color _lightOnVar = Color(0xFF5C6578);
  static const Color _lightOutline = Color(0xFFD0D7E6);

  /// فصل لوني للوضع الداكن: كحلي ليلي، بطاقات أعلى قليلاً، نص ثانوي مزرّق فاتح
  static const Color _darkSurface = Color(0xFF0B1430);
  static const Color _darkSurfaceContainer = Color(0xFF0E172E);
  static const Color _darkCard = Color(0xFF141C3A);
  static const Color _darkOnVar = Color(0xFF9BA4C0);
  static const Color _darkOutline = Color(0xFF2F3D66);

  /// قائمة الخطوط الاحتياطية المستخدمة في التطبيق — تضمن ظهور نصوص صحيحة
  /// عبر كل المنصات (Android/iOS/Web/Windows/macOS) إذا تعذّر تحميل Almaria.
  static const List<String> fontFamilyFallback = <String>[
    'Almaria',
    'Almarai',
    'Segoe UI',
    'Roboto',
    'Tahoma',
    'Arial',
    'sans-serif',
  ];

  /// بناء TextTheme موحّد يجبر الخط المستخدم في التطبيق (Almaria) على كل أنماط النصوص،
  /// ويضيف قائمة fontFamilyFallback لتفادي خطوط النظام العشوائية عبر المنصات.
  static TextTheme _buildTextTheme(TextTheme base, Color onSurface) {
    TextStyle? _apply(TextStyle? s, FontWeight weight) => s?.copyWith(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: weight,
          color: onSurface,
        );

    return base.copyWith(
      displayLarge: _apply(base.displayLarge, FontWeight.w700),
      displayMedium: _apply(base.displayMedium, FontWeight.w700),
      displaySmall: _apply(base.displaySmall, FontWeight.w700),
      headlineLarge: _apply(base.headlineLarge, FontWeight.w700),
      headlineMedium: _apply(base.headlineMedium, FontWeight.w700),
      headlineSmall: _apply(base.headlineSmall, FontWeight.w700),
      titleLarge: _apply(base.titleLarge, FontWeight.w500),
      titleMedium: _apply(base.titleMedium, FontWeight.w500),
      titleSmall: _apply(base.titleSmall, FontWeight.w500),
      bodyLarge: _apply(base.bodyLarge, FontWeight.w400),
      bodyMedium: _apply(base.bodyMedium, FontWeight.w400),
      bodySmall: _apply(base.bodySmall, FontWeight.w400),
      labelLarge: _apply(base.labelLarge, FontWeight.w500),
      labelMedium: _apply(base.labelMedium, FontWeight.w500),
      labelSmall: _apply(base.labelSmall, FontWeight.w500),
    );
  }

  static ThemeData lightTheme(BuildContext context) {
    // 1) ColorScheme متناغم للوضع الفاتح (هوية كحلي + ذهبي)
    final ColorScheme cs = ColorScheme(
      brightness: Brightness.light,
      primary: AppConsts.primaryColor,
      onPrimary: Colors.white,
      secondary: AppConsts.secondaryColor,
      onSecondary: Color(0xFF132057),
      tertiary: AppConsts.tertiaryColor.shade600,
      onTertiary: Colors.white,
      primaryContainer: const Color(0xFFE8EDFA),
      secondaryContainer: const Color(0xFFFFF4E0),
      surface: _lightSurface,
      onSurface: const Color(0xFF101828),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFE8EEF7),
      surfaceContainer: const Color(0xFFE8EDF7),
      surfaceContainerHigh: const Color(0xFFF7F9FE),
      surfaceContainerHighest: Colors.white,
      onSurfaceVariant: _lightOnVar,
      outline: _lightOutline,
      outlineVariant: const Color(0xFFE2E8F3),
      error: Color(0xFFC62828),
      onError: Colors.white,
      shadow: Color(0xFF132057),
      scrim: Color(0x99000000),
      inverseSurface: AppConsts.primaryColor,
      onInverseSurface: Colors.white,
      inversePrimary: AppConsts.secondaryColor,
      // نص على خلفيات primary (شريط التطبيق الأزرق وغيره)
      primaryFixed: Colors.white,
      primaryFixedDim: const Color(0xFFE8EDFA),
      onPrimaryFixed: AppConsts.primaryColor,
      onPrimaryFixedVariant: _lightOnVar,
      secondaryFixed: const Color(0xFFFFE8B8),
      secondaryFixedDim: AppConsts.secondaryColor,
      onSecondaryFixed: Color(0xFF132057),
      onSecondaryFixedVariant: Color(0xFF3D2800),
      tertiaryFixed: const Color(0xFFE8EDFA),
      onTertiaryFixed: AppConsts.primaryColor,
      onTertiaryFixedVariant: _lightOnVar,
    );


    // 2) حدود موحّدة
    OutlineInputBorder _outline(Color c, {double width = 1.0}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: width),
      gapPadding: 2,
    );

    // تعبئة الحقول بلون أبيض خفيف
    const Color fieldFill = Colors.white;

    // نستخدم Typography ثابت عبر المنصات (وإلا يختلف الخط الافتراضي على الويب/ويندوز)
    final Typography typography = Typography.material2021(
      platform: TargetPlatform.android,
      black: Typography.blackMountainView,
      white: Typography.whiteMountainView,
    );
    final TextTheme baseTextTheme = typography.black;
    final TextTheme softTextTheme = _buildTextTheme(baseTextTheme, cs.onSurface);
    final TextTheme primaryTextTheme = _buildTextTheme(typography.white, Colors.white);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppConsts.font,
      fontFamilyFallback: fontFamilyFallback,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      typography: typography,

      // نصوص عامة
      textTheme: softTextTheme,
      primaryTextTheme: primaryTextTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.2,
          color: cs.onSurface,
        ),
        toolbarTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: cs.onSurface,
        ),
        iconTheme: IconThemeData(color: cs.primary),
        shape: Border(
          bottom: BorderSide(
            color: AppConsts.secondaryColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        titleSpacing: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.65)),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),


    floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
      if (states.contains(WidgetState.error)) {
        return TextStyle(color: cs.error);
      }
      if (states.contains(WidgetState.focused)) {
        return TextStyle(color: AppConsts.secondaryColor);
      }
      if (states.contains(WidgetState.disabled)) {
        return TextStyle(color: cs.onSurface.withValues(alpha: 0.38));
      }
      return TextStyle(color: AppConsts.secondaryColor);
    }),

        helperStyle: TextStyle(color: cs.onSurfaceVariant),
        errorStyle: TextStyle(color: cs.error),
        // contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 12, top: 12, bottom: 12),

        border: _outline(cs.outline),
        enabledBorder: _outline(cs.outline),
        disabledBorder: _outline(cs.outlineVariant),
        focusedBorder: _outline(AppConsts.secondaryColor, width: 1.4),
        errorBorder: _outline(cs.error),
        focusedErrorBorder: _outline(cs.error, width: 1.4),

        // ألوان الأيقونات حسب الحالة
        prefixIconColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.error)) return cs.error;
            if (states.contains(WidgetState.focused)) return AppConsts.secondaryColor;
            if (states.contains(WidgetState.disabled)) {
              return cs.onSurface.withValues(alpha: 0.38);
            }
            return cs.onSurfaceVariant;
          }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.error)) return cs.error;
          if (states.contains(WidgetState.focused)) return AppConsts.secondaryColor;
          if (states.contains(WidgetState.disabled)) {
            return cs.onSurface.withValues(alpha: 0.38);
          }
          return cs.onSurfaceVariant;
        }),
        alignLabelWithHint: true,
      ),

      // أزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: cs.onPrimary,
          backgroundColor: cs.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary.withValues(alpha: 0.8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppConsts.secondaryColor,
        inactiveTrackColor: cs.outline.withValues(alpha: 0.35),
        thumbColor: AppConsts.secondaryColor,
        overlayColor: AppConsts.secondaryColor.withValues(alpha: 0.2),
        trackHeight: 3.5,
        rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: AppConsts.secondaryColor.withValues(alpha: 0.32),
        disabledColor: cs.outline.withValues(alpha: 0.25),
        labelStyle: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: AppConsts.primaryColor, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.45)),
      ),

      // بطاقات/قوائم/فواصل
      cardTheme: CardThemeData(
        color: cs.surfaceContainerHighest,
        elevation: 0,
        shadowColor: cs.shadow.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        tileColor: cs.surfaceContainerHighest,
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 16),

      // القوائم المنبثقة
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainerHighest,
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onSurface,
        ),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontFamily: AppConsts.font,
            fontFamilyFallback: fontFamilyFallback,
            color: cs.onSurface,
          ),
        ),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Dialog — يفرض الخط على العناوين والمحتوى
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onSurface,
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 1.4,
        ),
      ),

      // SnackBar — يضمن ظهور الرسائل بخط التطبيق
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onInverseSurface,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // BottomSheet — الخط للعناصر النصية داخل الأوراق السفلية
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Dropdown — القوائم المنسدلة
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onSurface,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(cs.surfaceContainerHighest),
        ),
      ),

      // Menu (أوامر القوائم)
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(cs.surfaceContainerHighest),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: AppConsts.font,
              fontFamilyFallback: fontFamilyFallback,
              color: cs.onSurface,
            ),
          ),
        ),
      ),

      // TabBar — عناوين التبويبات
      tabBarTheme: TabBarThemeData(
        labelStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: Colors.white,
          fontSize: 12,
        ),
        decoration: BoxDecoration(
          color: AppConsts.primaryColor.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      // NavigationBar — شريط التنقل السفلي
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontFamily: AppConsts.font,
            fontFamilyFallback: fontFamilyFallback,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),

      // SegmentedButton
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: AppConsts.font,
              fontFamilyFallback: fontFamilyFallback,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),

      // أيقونات عامة
      iconTheme: IconThemeData(color: cs.onSurfaceVariant),
    ).copyWith(
      dividerTheme: DividerThemeData(
        thickness: 1, // سماكة الخط المرئي
        space: 1, // الارتفاع الكلي للـ Divider (بدون حواف زائدة)
      ),
      listTileTheme: ListTileThemeData(tileColor: Colors.transparent),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    // 1) لوحة الألوان للوضع الداكن: كحلي ليلي، بطاقات مرفوعة، نص ثانوي مزرّق، ذهبي للتأكيد
    final ColorScheme cs = ColorScheme(
      brightness: Brightness.dark,
      primary: AppConsts.primaryColor,
      onPrimary: Colors.white,
      secondary: AppConsts.secondaryColor,
      onSecondary: const Color(0xFF132057),
      tertiary: AppConsts.tertiaryColor.shade500,
      onTertiary: Colors.white,
      primaryContainer: const Color(0xFF1E2F64),
      secondaryContainer: const Color(0xFF4A3800),
      surface: _darkSurface,
      onSurface: Colors.white,
      surfaceContainerLowest: const Color(0xFF060A18),
      surfaceContainerLow: _darkSurfaceContainer,
      surfaceContainer: const Color(0xFF0C152E),
      surfaceContainerHigh: _darkCard,
      surfaceContainerHighest: _darkCard,
      onSurfaceVariant: _darkOnVar,
      outline: _darkOutline,
      outlineVariant: const Color(0xFF3D4D75),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      shadow: Colors.black,
      scrim: Color(0x99000000),
      inverseSurface: const Color(0xFFE8ECF8),
      onInverseSurface: AppConsts.primaryColor,
      inversePrimary: AppConsts.secondaryColor,
      primaryFixed: Colors.white,
      primaryFixedDim: const Color(0xFFB8C4E8),
      onPrimaryFixed: AppConsts.primaryColor,
      onPrimaryFixedVariant: _darkOnVar,
      secondaryFixed: const Color(0xFFFFE082),
      secondaryFixedDim: AppConsts.secondaryColor,
      onSecondaryFixed: Color(0xFF132057),
      onSecondaryFixedVariant: Color(0xFF3D2800),
      tertiaryFixed: const Color(0xFFE8EDFA),
      onTertiaryFixed: AppConsts.primaryColor,
      onTertiaryFixedVariant: _darkOnVar,
    );


    // 2) حدود موحدة للنصوص
    OutlineInputBorder _outline(Color c, {double width = 1.0}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: width),
      gapPadding: 2,
    );

    // 3) لون تعبئة الحقول يتلاءم مع بطاقات السمة الداكنة
    final Color fieldFill = const Color(0xFF121A38);

    final Typography typography = Typography.material2021(
      platform: TargetPlatform.android,
      black: Typography.blackMountainView,
      white: Typography.whiteMountainView,
    );
    final TextTheme baseTextTheme = typography.white;
    final TextTheme softTextTheme = _buildTextTheme(baseTextTheme, cs.onSurface);
    final TextTheme primaryTextTheme = _buildTextTheme(typography.white, Colors.white);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppConsts.font,
      fontFamilyFallback: fontFamilyFallback,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      typography: typography,

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppConsts.secondaryColor,
        selectionColor: AppConsts.secondaryColor,
        selectionHandleColor: AppConsts.secondaryColor,
      ),

      // نصوص عامة
      textTheme: softTextTheme,
      primaryTextTheme: primaryTextTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.2,
          color: cs.onSurface,
        ),
        toolbarTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: cs.onSurface,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
        shape: Border(
          bottom: BorderSide(
            color: AppConsts.secondaryColor.withValues(alpha: 0.28),
            width: 1,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill, // خلفية خفيفة للحقول
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.55)),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: cs.secondary), // إبراز اللابل عند التركيز بالذهبي
        helperStyle: TextStyle(color: cs.onSurfaceVariant),
        errorStyle: TextStyle(color: cs.error),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

        // حدود بمستويات واضحة
        border: _outline(cs.outlineVariant),
        enabledBorder: _outline(cs.outlineVariant),
        disabledBorder: _outline(cs.outlineVariant.withValues(alpha: 0.6)),
        focusedBorder: _outline(cs.secondary, width: 1.4),
        errorBorder: _outline(cs.error),
        focusedErrorBorder: _outline(cs.error, width: 1.4),

        // ألوان الأيقونات حسب الحالة
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.error)) return cs.error;
          if (states.contains(WidgetState.focused)) return cs.secondary;
          if (states.contains(WidgetState.disabled)) {
            return cs.onSurface.withValues(alpha: 0.38);
          }
          return cs.onSurfaceVariant;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.error)) return cs.error;
          if (states.contains(WidgetState.focused)) return cs.secondary;
          if (states.contains(WidgetState.disabled)) {
            return cs.onSurface.withValues(alpha: 0.38);
          }
          return cs.onSurfaceVariant;
        }),
        alignLabelWithHint: true,
      ),

      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: cs.onPrimary,
          backgroundColor: cs.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.secondary,
          side: BorderSide(color: cs.secondary.withValues(alpha: 0.95)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppConsts.secondaryColor,
        inactiveTrackColor: cs.outline.withValues(alpha: 0.4),
        thumbColor: AppConsts.secondaryColor,
        overlayColor: AppConsts.secondaryColor.withValues(alpha: 0.22),
        trackHeight: 3.5,
        rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: AppConsts.secondaryColor.withValues(alpha: 0.38),
        disabledColor: cs.outline.withValues(alpha: 0.25),
        labelStyle: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: AppConsts.primaryColor, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: _darkOutline.withValues(alpha: 0.9)),
      ),

      // بطاقة/قائمة/فواصل
      cardTheme: CardThemeData(
        color: cs.surfaceContainerHighest,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppConsts.secondaryColor.withValues(alpha: 0.22)),
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(iconColor: cs.onSurfaceVariant, textColor: cs.onSurface, tileColor: cs.surfaceContainerHighest),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 16),

      // قوائم منبثقة
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainerHighest,
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onSurface,
        ),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontFamily: AppConsts.font,
            fontFamilyFallback: fontFamilyFallback,
            color: cs.onSurface,
          ),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onSurface,
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 1.4,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onInverseSurface,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: cs.onSurface,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(cs.surfaceContainerHighest),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(cs.surfaceContainerHighest),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: AppConsts.font,
              fontFamilyFallback: fontFamilyFallback,
              color: cs.onSurface,
            ),
          ),
        ),
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontFamilyFallback: fontFamilyFallback,
          color: Colors.white,
          fontSize: 12,
        ),
        decoration: BoxDecoration(
          color: AppConsts.primaryColor.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      // NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontFamily: AppConsts.font,
            fontFamilyFallback: fontFamilyFallback,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),

      // SegmentedButton
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: AppConsts.font,
              fontFamilyFallback: fontFamilyFallback,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),

      // أيقونات عامة
      iconTheme: IconThemeData(color: cs.onSurfaceVariant),
    ).copyWith(
      dividerTheme: const DividerThemeData(
        thickness: 1, // سماكة الخط المرئي
        space: 1, // الارتفاع الكلي للـ Divider (بدون حواف زائدة)
      ),
      listTileTheme: ListTileThemeData(tileColor: Colors.transparent),
    );
  }
}
