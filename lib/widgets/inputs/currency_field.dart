import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final ValueChanged<double>? onChanged;

  const CurrencyField({
    super.key,
    required this.controller,
    this.labelText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [_CurrencyInputFormatter()],
      decoration: InputDecoration(
        labelText: labelText,
      ),
      onChanged: (value) {
        if (onChanged != null) {
          final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
          final amount = digits.isEmpty ? 0.0 : int.parse(digits) / 100.0;
          onChanged!(amount);
        }
      },
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  final _formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    final value = int.parse(digits);
    final formatted = _formatter.format(value / 100);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
