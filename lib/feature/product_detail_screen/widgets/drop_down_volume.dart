import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class DropdownVolume extends StatelessWidget {
  final List<Variant> variants;
  final Variant? selectedVariant;
  final ValueChanged<Variant> onVariantSelected;

  const DropdownVolume({
    super.key,
    required this.variants,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AllColors.tabBarline),
        borderRadius: BorderRadius.circular(8),
      ),

      child: SizedBox(
        width: double.infinity,
        child: DropdownButton<Variant>(
          value: selectedVariant,
          isExpanded: true,
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down),
          items: variants.map((variant) {
            return DropdownMenuItem<Variant>(
              value: variant,
              child: Text('${variant.quantityInMl} L'),
            );
          }).toList(),
          onChanged: (variant) {
            if (variant != null) {
              onVariantSelected(variant);
            }
          },
        ),
      ),
    );
  }
}
