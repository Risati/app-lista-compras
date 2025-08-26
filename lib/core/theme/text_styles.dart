import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/dimensions.dart';

class AppTextStyles {
  static TextStyle titleLarge(BuildContext ctx) => GoogleFonts.poppins(
        fontSize: Dimensions.fontXXL,
        fontWeight: FontWeight.w600,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle titleMedium(BuildContext ctx) => GoogleFonts.poppins(
        fontSize: Dimensions.fontXL,
        fontWeight: FontWeight.w600,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle titleSmall(BuildContext ctx) => GoogleFonts.poppins(
        fontSize: Dimensions.fontL,
        fontWeight: FontWeight.w600,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle bodyLarge(BuildContext ctx) => GoogleFonts.poppins(
        fontSize: Dimensions.fontL,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle bodyMedium(BuildContext ctx) => GoogleFonts.poppins(
        fontSize: Dimensions.fontM,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle bodySmall(BuildContext ctx) => GoogleFonts.poppins(
        fontSize: Dimensions.fontS,
        color: Theme.of(ctx).colorScheme.onSurface.withAlpha(178),
      );

  static TextStyle price(BuildContext ctx) => GoogleFonts.poppins(
        fontSize: Dimensions.fontL,
        fontWeight: FontWeight.w600,
        color: Theme.of(ctx).colorScheme.primary,
      );

  static TextStyle label(BuildContext ctx) => GoogleFonts.poppins(
        fontSize: Dimensions.fontM,
        fontWeight: FontWeight.w500,
        color: Theme.of(ctx).colorScheme.onSurface.withAlpha(178),
      );
}
