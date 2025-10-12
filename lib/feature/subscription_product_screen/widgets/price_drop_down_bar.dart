import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';


import 'package:vd_customer_app/core/models/product_model.dart';

class SubscriptionPriceDropdown extends StatefulWidget {
  final List<Variant> variants;
  final void Function(Variant variant, int index)? onVariantSelected;
  final int selectedIndex;
  const SubscriptionPriceDropdown({Key? key, required this.variants, this.onVariantSelected, this.selectedIndex = 0}) : super(key: key);

  @override
  State<SubscriptionPriceDropdown> createState() =>
      _SubscriptionPriceDropdownState();
}

class _SubscriptionPriceDropdownState extends State<SubscriptionPriceDropdown> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.variants.isNotEmpty ? widget.selectedIndex : null;
  }

  @override
  void didUpdateWidget(SubscriptionPriceDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.variants.isNotEmpty ? widget.selectedIndex : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AllColors.olivegreenColor, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedIndex,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.teal),
          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          onChanged: (int? newIndex) {
            setState(() {
              selectedIndex = newIndex;
            });
            if (newIndex != null && widget.onVariantSelected != null) {
              final variant = widget.variants[newIndex];
              widget.onVariantSelected!(variant, newIndex);
            }
          },
          items: widget.variants.asMap().entries.map((entry) {
            final idx = entry.key;
            final variant = entry.value;
            final quantity = variant.quantityInMl;
            final price = variant.price;
            return DropdownMenuItem<int>(
              value: idx,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${quantity}ml at ",
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                    TextSpan(
                      text: "₹${double.tryParse(price)?.toStringAsFixed(0) ?? price}",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
