import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../constants/dimensions.dart';

/// Cria o fundo do Dismissible
Widget buildDismissBackground({
  required Color color,
  required IconData icon,
  required Alignment alignment,
}) {
  return Container(
    color: color,
    alignment: alignment,
    padding: EdgeInsets.only(
      left: alignment == Alignment.centerLeft ? Dimensions.paddingXL : 0,
      right: alignment == Alignment.centerRight ? Dimensions.paddingXL : 0,
    ),
    child: Icon(
      icon,
      color: AppColors.textLight,
      size: Dimensions.iconXL,
    ),
  );
}
