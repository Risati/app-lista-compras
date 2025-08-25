import 'package:flutter/material.dart';
import '../../core/constants/strings.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final Color? confirmColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText ?? Strings.btnCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: confirmColor != null
              ? TextButton.styleFrom(foregroundColor: confirmColor)
              : null,
          child: Text(confirmText ?? Strings.btnFinish),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
      ),
    );
  }
}
