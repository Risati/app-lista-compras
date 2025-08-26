import 'package:flutter/material.dart';

class AppColors {
  // Cores principais
  static const primary = Color(0xFF1A73E8); // azul petróleo
  static const secondary = Color(0xFFFF6F61); // coral suave
  static const background = Color(0xFFF5F5F5); // cinza claro
  static const surface = Color(0xFFFFFFFF); // branco suave

  // Cores do tema escuro
  static const darkBackground = Color(0xFF181A20); // fundo escuro
  static const darkSurface = Color(0xFF222831); // cinza escuro

  // Cores de status
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF2196F3);

  // Cores de texto
  static const textPrimary = Colors.black87;
  static const textSecondary = Colors.black54;
  static const textLight = Colors.white;
  static const textLightSecondary = Colors.white70;

  // Variações de cores principais com opacidade
  static Color primaryWithOpacity(double opacity) =>
      primary.withAlpha((opacity * 255).round());
  static Color secondaryWithOpacity(double opacity) =>
      secondary.withAlpha((opacity * 255).round());
}
