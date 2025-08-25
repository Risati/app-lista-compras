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
      color: Colors.white, // 🔥 Ícones do AppBar sempre brancos
    ),
  ),
  // 🔥 Ícones globais (fora do AppBar)
  iconTheme: const IconThemeData(
    color: primaryColor, // todos os ícones usam essa cor
    size: 26, // opcional: tamanho padrão
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
