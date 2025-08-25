import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static final _date = DateFormat('dd/MM/yyyy');
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  // Formatação de moeda
  static String currency(double value) => _currency.format(value);

  // Formatação de data
  static String date(DateTime date) => _date.format(date);
  static String dateTime(DateTime date) => _dateTime.format(date);

  // Formatação de quantidade
  static String quantity(int value) => value.toString();

  // Formatação de porcentagem
  static String percentage(double value) => '${value.toStringAsFixed(1)}%';
}
