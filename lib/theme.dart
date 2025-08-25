import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF1A73E8); // azul petróleo
const Color secondaryColor = Color(0xFFFF6F61); // coral suave
const Color bgColor = Color(0xFFF5F5F5); // cinza claro
const Color surfaceColor = Color(0xFFFFFFFF); // branco suave

final ThemeData elegantTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: surfaceColor,
    onSurface: Colors.black87,
  ),
  scaffoldBackgroundColor: bgColor,
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    elevation: 0,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    centerTitle: true,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  ),
  iconTheme: const IconThemeData(
    color: primaryColor,
    size: 26,
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: surfaceColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: primaryColor.withAlpha(128)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: secondaryColor),
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

// Tema escuro elegante
final ThemeData elegantDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: Color(0xFF222831), // cinza escuro
    onSurface: Colors.white70,
  ),
  scaffoldBackgroundColor: const Color(0xFF181A20), // fundo escuro
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    elevation: 0,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    centerTitle: true,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  ),
  iconTheme: const IconThemeData(
    color: secondaryColor,
    size: 26,
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: const Color(0xFF222831),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: secondaryColor.withAlpha(128)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primaryColor),
    ),
  ),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.zero,
      minimumSize: const Size(48, 48),
    ),
  ),
);
