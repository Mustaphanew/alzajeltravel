import 'package:flutter/material.dart';
import 'package:alzajeltravel/utils/app_consts.dart';

class Themes {
  static ThemeData lightTheme(BuildContext context) {
    // 1) ColorScheme متناغم للوضع الفاتح
    final ColorScheme cs = ColorScheme(
      brightness: Brightness.light,
      primary: AppConsts.primaryColor, // #132057
      onPrimary: Colors.white, // نص أبيض فوق الكحلي
      secondary: AppConsts.secondaryColor, // ذهبي لإبراز الحالات
      onSecondary: const Color(0xFF1A1300), // نص داكن فوق الذهبي
      tertiary: AppConsts.tertiaryColor.shade500,
      onTertiary: Colors.white,
      primaryContainer: AppConsts.primaryColor,
      secondaryContainer: AppConsts.secondaryColor,
      surface: const Color(0xFFF6F7FB), // سطح عام فاتح (خلفية شاشات)
      onSurface: const Color(0xFF101318),
      surfaceContainer: Colors.white,
      surfaceContainerHighest: Colors.white,
      surfaceVariant: const Color(0xFFFFFFFF), // بطاقات/حقول بلون أبيض
      onSurfaceVariant: const Color(0xFF2D3142), // نص ثانوي رمادي داكن
      outline: AppConsts.tertiaryColor.shade400, // حدود خفيفة
      outlineVariant: AppConsts.tertiaryColor.shade300,
      error: Colors.pink[800]!,
      onError: Colors.white,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: const Color(0xFF111520),
      onInverseSurface: Colors.white,
      inversePrimary: AppConsts.secondaryColor,
      primaryFixed: Colors.black,
      secondaryFixed: Colors.green[800],
    );

    // 2) حدود موحّدة
    OutlineInputBorder _outline(Color c, {double width = 1.0}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: width),
      gapPadding: 2,
    );

    // تعبئة الحقول بلون أبيض خفيف
    const Color fieldFill = Colors.white;

    final base = Theme.of(context).textTheme;
    final softTextTheme = base
        .copyWith(
          // عناوين
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w500),

          // نصوص
          bodyLarge: base.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
          bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
          bodySmall: base.bodySmall?.copyWith(fontWeight: FontWeight.w400),

          // تسميات/أزرار
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        )
        .apply(fontFamily: AppConsts.font, bodyColor: cs.onSurface, displayColor: cs.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppConsts.font,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,

      // نصوص عامة
      textTheme: softTextTheme,

      // AppBar بلون السطح مع نص داكن (أنيق في الوضع الفاتح)
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: AppConsts.font, fontWeight: FontWeight.w500, fontSize: 17, color: cs.onSurface),
        iconTheme: IconThemeData(color: cs.onSurface),

        // 👇 الحد السفلي (فاصل رفيع)
        shape: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withOpacity(1), // رمادي شفاف
            width: 0.7, // خط رفيع
          ),
        ),

        titleSpacing: 0,

        // (اختياري) إلغاء تأثير التينت في M3 لو لاحظت تغيّر لون الخلفية
        surfaceTintColor: Colors.transparent,
      ),

      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.65)),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: cs.secondary), // إبراز بالذهبي
        helperStyle: TextStyle(color: cs.onSurfaceVariant),
        errorStyle: TextStyle(color: cs.error),
        // contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 12, top: 12, bottom: 12),

        border: _outline(cs.outline),
        enabledBorder: _outline(cs.outline),
        disabledBorder: _outline(cs.outlineVariant),
        focusedBorder: _outline(cs.secondary, width: 1.4),
        errorBorder: _outline(cs.error),
        focusedErrorBorder: _outline(cs.error, width: 1.4),

        // ألوان الأيقونات حسب الحالة
        prefixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.error)) return cs.error;
          if (states.contains(MaterialState.focused)) return cs.secondary;
          if (states.contains(MaterialState.disabled)) {
            return cs.onSurface.withOpacity(0.38);
          }
          return cs.onSurfaceVariant;
        }),
        suffixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.error)) return cs.error;
          if (states.contains(MaterialState.focused)) return cs.secondary;
          if (states.contains(MaterialState.disabled)) {
            return cs.onSurface.withOpacity(0.38);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary.withOpacity(0.8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // بطاقات/قوائم/فواصل
      cardTheme: CardThemeData(
        color: cs.surfaceVariant,
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(iconColor: cs.onSurfaceVariant, textColor: cs.onSurface, tileColor: cs.surfaceVariant),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 16),

      // القوائم المنبثقة
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceVariant,
        textStyle: TextStyle(color: cs.onSurface),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    // 1) لوحة الألوان الأساسية للوضع الداكن
    final ColorScheme cs = ColorScheme(
      brightness: Brightness.dark,
      primary: AppConsts.primaryColor,
      onPrimary: Colors.white,
      secondary: AppConsts.secondaryColor,
      primaryContainer: AppConsts.secondaryColor,
      secondaryContainer: AppConsts.primaryColor,
      onSecondary: const Color(0xFF1A1300), // نص داكن فوق الذهبي
      tertiary: AppConsts.tertiaryColor.shade400, // رمادي وسيط
      onTertiary: Colors.black,
      surface: const Color(0xFF0F1533), // خلفية أساسية (أغمق من الـ primary)
      onSurface: Colors.white,
      background: const Color(0xFF0B112B), // خلفية عامة
      onBackground: Colors.white,
      surfaceContainerHighest: const Color(0xFF171B34), // بطاقات/حقول
      surfaceContainer: Colors.black,
      onSurfaceVariant: const Color(0xCCFFFFFF), // أبيض بعتامة 80%
      outline: AppConsts.tertiaryColor.shade700, // حدود غير ظاهرة بقوة
      outlineVariant: AppConsts.tertiaryColor.shade800,
      error: Colors.pink[800]!,
      onError: Colors.black,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: const Color(0xFFEDEFF9),
      onInverseSurface: const Color(0xFF0E1226),
      inversePrimary: AppConsts.secondaryColor,
      primaryFixed: Colors.white,
      secondaryFixed: Colors.green[800],
    );

    // 2) حدود موحدة للنصوص
    OutlineInputBorder _outline(Color c, {double width = 1.0}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: width),
      gapPadding: 2,
    );

    // 3) لون تعبئة خفيف للحقول (سطح أدكن قليلًا من surface)
    final Color fieldFill = const Color(0xFF151A34);

    final base = Theme.of(context).textTheme;
    final softTextTheme = base
        .copyWith(
          // عناوين
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w500),

          // نصوص
          bodyLarge: base.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
          bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
          bodySmall: base.bodySmall?.copyWith(fontWeight: FontWeight.w400),

          // تسميات/أزرار
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        )
        .apply(fontFamily: AppConsts.font, bodyColor: cs.onSurface, displayColor: cs.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppConsts.font,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppConsts.secondaryColor,
        selectionColor: AppConsts.secondaryColor,
        selectionHandleColor: AppConsts.secondaryColor,
      ),

      // نصوص عامة
      textTheme: softTextTheme,

      // AppBar هادئ على surface (بدون استخدام primary كخلفية حتى لا تكون قاتمة جدًا)
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: AppConsts.font, fontWeight: FontWeight.w500, fontSize: 17, color: cs.onSurface),
        iconTheme: IconThemeData(color: cs.onSurface),

        // ↓ فاصل سفلي رفيع وشفاف قليلاً
        shape: Border(
          bottom: BorderSide(
            color: cs.outline.withOpacity(0.5), // رمادي داكن شبه شفاف
            width: 0.5,
          ),
        ),

        // لتجنّب تلوين إضافي في M3
        surfaceTintColor: Colors.transparent,
      ),
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill, // خلفية خفيفة للحقول
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.5)),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: cs.secondary), // إبراز اللابل عند التركيز بالذهبي
        helperStyle: TextStyle(color: cs.onSurfaceVariant),
        errorStyle: TextStyle(color: cs.error),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

        // حدود بمستويات واضحة
        border: _outline(cs.outlineVariant),
        enabledBorder: _outline(cs.outlineVariant),
        disabledBorder: _outline(cs.outlineVariant.withOpacity(0.6)),
        focusedBorder: _outline(cs.secondary, width: 1.4),
        errorBorder: _outline(cs.error),
        focusedErrorBorder: _outline(cs.error, width: 1.4),

        // ألوان الأيقونات حسب الحالة
        prefixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.error)) return cs.error;
          if (states.contains(MaterialState.focused)) return cs.secondary;
          if (states.contains(MaterialState.disabled)) {
            return cs.onSurface.withOpacity(0.38);
          }
          return cs.onSurfaceVariant;
        }),
        suffixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.error)) return cs.error;
          if (states.contains(MaterialState.focused)) return cs.secondary;
          if (states.contains(MaterialState.disabled)) {
            return cs.onSurface.withOpacity(0.38);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          side: BorderSide(color: cs.secondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // بطاقة/قائمة/فواصل
      cardTheme: CardThemeData(
        color: cs.surfaceContainerHighest,
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(iconColor: cs.onSurfaceVariant, textColor: cs.onSurface, tileColor: cs.surfaceContainerHighest),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 16),

      // قوائم منبثقة
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainerHighest,
        textStyle: TextStyle(color: cs.onSurface),
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
