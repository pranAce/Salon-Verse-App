class AppCurrencyFormatter {
  static String format(num? amount, {String currency = 'NPR'}) {
    if (amount == null) return 'Price unavailable';
    final val = amount.toDouble();
    if (val < 0) return 'Price unavailable';

    final isWhole = val % 1 == 0;
    final formattedNum = isWhole
        ? val.toInt().toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )
        : val.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

    final currCode = currency.toUpperCase() == 'NPR' || currency.isEmpty ? 'Rs.' : currency;
    return '$currCode $formattedNum';
  }
}

class CurrencyFormatter {
  static String formatNPR(num? amount) {
    if (amount == null) return 'Rs. 0';
    return AppCurrencyFormatter.format(amount, currency: 'Rs.');
  }

  static String format(num? amount, {String currency = 'Rs.'}) {
    return AppCurrencyFormatter.format(amount, currency: currency);
  }
}
