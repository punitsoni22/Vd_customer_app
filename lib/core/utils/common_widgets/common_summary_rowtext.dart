import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  final double? fontSize;

  const Summary({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize ?? 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: fontSize ?? 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
