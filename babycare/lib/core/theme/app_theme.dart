import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primary = Color(0xFFD81B60); // Rose Pink
  static const Color primaryDark = Color(0xFFAD1457); // Deep Rose
  static const Color secondary = Color(0xFFF06292); // Soft Pink
  static const Color accent = Color(0xFFFFD54F); // Gold
  static const Color background = Color(0xFFFFF8FA); // Blush White
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color text = Color(0xFF1A1A2E); // Deep Navy
  static const Color textLight = Color(0xFF78758A); // Muted Lavender
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color success = Color(0xFF2E7D32); // Green
  static const Color primarySurface = Color(0xFFFCE4EC); // Pink Tint
  static const Color divider = Color(0xFFEEE8EC); // Soft Divider
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double full = 999.0;
}

class AppShadows {
  static final List<BoxShadow> sm = [
    BoxShadow(
      color: AppColors.text.withValues(alpha: 0.03),
      offset: const Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static final List<BoxShadow> md = [
    BoxShadow(
      color: AppColors.text.withValues(alpha: 0.06),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];

  static final List<BoxShadow> lg = [
    BoxShadow(
      color: AppColors.text.withValues(alpha: 0.08),
      offset: const Offset(0, 12),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  static final List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.text.withValues(alpha: 0.04),
      offset: const Offset(0, 2),
      blurRadius: 12,
      spreadRadius: -1,
    ),
  ];
}

class AppTypography {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    fontFamily: '.SF Pro Rounded',
    letterSpacing: -0.8,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFamily: '.SF Pro Rounded',
    letterSpacing: -0.5,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    fontFamily: '.SF Pro Rounded',
    letterSpacing: -0.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
    fontFamily: '.SF Pro Text',
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
    fontFamily: '.SF Pro Text',
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    fontFamily: '.SF Pro Rounded',
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: '.SF Pro Rounded',
    letterSpacing: 0.2,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    fontFamily: '.SF Pro Text',
  );
}

class AppTheme {
  static const CupertinoThemeData theme = CupertinoThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.surface,
    textTheme: CupertinoTextThemeData(
      textStyle: AppTypography.body,
      navTitleTextStyle: AppTypography.h3,
      navActionTextStyle: AppTypography.button,
      actionTextStyle: AppTypography.button,
    ),
  );
}
