import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primary = Color(0xFFA8D5BA); // Sage Green
  static const Color secondary = Color(0xFFA7C7E7); // Sky Blue
  static const Color accent = Color(0xFFFFF1A8); // Soft Yellow
  static const Color background = Color(0xFFF7F9F8); // Off White
  static const Color text = Color(0xFF374151); // Deep Gray
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 20.0;
  static const double full = 999.0;
}

class AppShadows {
  static final List<BoxShadow> sm = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.15),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: CupertinoColors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static final List<BoxShadow> md = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.2),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: CupertinoColors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static final List<BoxShadow> lg = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.25),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: CupertinoColors.black.withValues(alpha: 0.12),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static final List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.12),
      offset: const Offset(0, 2),
      blurRadius: 10,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: CupertinoColors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 1),
      blurRadius: 4,
    ),
  ];
}

class AppTypography {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFamily: '.SF Pro Display',
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFamily: '.SF Pro Display',
    letterSpacing: -0.5,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    fontFamily: '.SF Pro Text',
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
    fontFamily: '.SF Pro Text',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
    fontFamily: '.SF Pro Text',
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    fontFamily: '.SF Pro Text',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    fontFamily: '.SF Pro Text',
  );
}

class AppTheme {
  static const CupertinoThemeData theme = CupertinoThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.primary,
    textTheme: CupertinoTextThemeData(
      textStyle: AppTypography.body,
      navTitleTextStyle: AppTypography.h3,
      navActionTextStyle: AppTypography.button,
      actionTextStyle: AppTypography.button,
    ),
  );
}
