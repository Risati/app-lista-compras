import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import '../constants/dimensions.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: Dimensions.fontXXL,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: AppColors.textLight,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primary,
          size: Dimensions.iconL,
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingM,
            vertical: Dimensions.paddingS,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusS),
            borderSide: BorderSide(color: AppColors.primaryWithOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusS),
            borderSide: const BorderSide(color: AppColors.secondary),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusS),
            ),
            padding: EdgeInsets.zero,
            minimumSize: const Size(
              Dimensions.buttonMinWidth,
              Dimensions.buttonHeight,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors
              .primary, // ou null para deixar o FAB usar colorScheme.primary
          foregroundColor: AppColors.textLight, // texto/ícone do FAB
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.darkSurface,
          onSurface: AppColors.textLight,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: Dimensions.fontXXL,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: AppColors.textLight,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.secondary,
          size: Dimensions.iconL,
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: AppColors.darkSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingM,
            vertical: Dimensions.paddingS,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusS),
            borderSide: BorderSide(color: AppColors.secondaryWithOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusS),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusS),
            ),
            padding: EdgeInsets.zero,
            minimumSize: const Size(
              Dimensions.buttonMinWidth,
              Dimensions.buttonHeight,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
        ),
      );
}
