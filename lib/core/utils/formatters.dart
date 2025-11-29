String formatVolume(dynamic quantityInMl) {
  final s = quantityInMl?.toString() ?? '';
  final n = num.tryParse(s);
  if (n == null) return '$s ml';

  if (n < 1000) {
    if (n % 1 == 0) {
      return '${n.toInt()} ml';
    }
    return '$n ml';
  }
  final liters = n / 1000;
  final formatted = double.parse(liters.toStringAsFixed(2)).toString();
  return '$formatted L';
}
