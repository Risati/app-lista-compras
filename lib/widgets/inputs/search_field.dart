import 'package:flutter/material.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/text_styles.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isVisible;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Dimensions.animFast,
      width: isVisible ? 220 : 48,
      child: Row(
        children: [
          if (isVisible)
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: true,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                decoration: InputDecoration(
                  hintText: Strings.labelSearch,
                  hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(178),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingS,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
          IconButton(
            icon: Icon(
              isVisible ? Icons.close : Icons.search,
              color: Theme.of(context).appBarTheme.iconTheme?.color ??
                  Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
