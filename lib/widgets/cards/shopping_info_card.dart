import 'package:flutter/material.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/colors.dart';

class ShoppingInfoCard extends StatelessWidget {
  final double total;
  final double spent;
  final int remaining;

  const ShoppingInfoCard({
    super.key,
    required this.total,
    required this.spent,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(Dimensions.paddingM),
      elevation: Dimensions.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingXL),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoColumn(
              context,
              icon: Icons.shopping_cart,
              iconColor: AppColors.primary,
              label: Strings.labelTotal,
              value: Formatters.currency(total),
            ),
            _buildInfoColumn(
              context,
              icon: Icons.check_circle,
              iconColor: AppColors.success,
              label: Strings.labelSpent,
              value: Formatters.currency(spent),
              valueColor: AppColors.success,
            ),
            _buildInfoColumn(
              context,
              icon: Icons.pending_actions,
              iconColor: AppColors.warning,
              label: Strings.labelRemaining,
              value: remaining.toString(),
              valueColor: remaining >= 0 ? AppColors.warning : AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(height: Dimensions.paddingXS),
        Text(label, style: AppTextStyles.label(context)),
        Text(
          value,
          style: AppTextStyles.bodyLarge(context).copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
