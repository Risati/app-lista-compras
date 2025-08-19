import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor   = Color(0xFF00ACC1);
const Color secondaryColor = Color(0xFFFF7043);
const Color bgColor        = Color(0xFFF1F8E9);
const Color surfaceColor   = Colors.white;

final ThemeData elegantTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    background: bgColor,
    surface: surfaceColor,
    onBackground: Colors.black87,
  ),
  scaffoldBackgroundColor: bgColor,
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    elevation: 0,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white
    ),
    centerTitle: true,
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: surfaceColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: secondaryColor),
    ),
  ),
  textTheme: GoogleFonts.poppinsTextTheme(),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.zero,
      minimumSize: const Size(48, 48),
    ),
  ),
);