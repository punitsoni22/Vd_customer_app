import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

import 'package:vd_customer_app/core/models/product_model.dart';

class SubscriptionPriceDropdown extends StatefulWidget {
  final List<Variant> variants;
  final void Function(Variant variant, int index)? onVariantSelected;
  final int selectedIndex;
  const SubscriptionPriceDropdown({
    super.key,
    required this.variants,
    this.onVariantSelected,
    this.selectedIndex = 0,
  });

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
      height: 35.h,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AllColors.olivegreenColor, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<int>(
          value: selectedIndex,
          isExpanded: true,

          iconStyleData: IconStyleData(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.teal),
          ),

          dropdownStyleData: DropdownStyleData(
            offset: const Offset(0, 5),
            width: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1),
            ),
            elevation: 4,
            maxHeight: 180,
          ),

          style: TextStyle(color: Colors.grey.shade700, fontSize: 16.sp),

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
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text:
                          "₹${double.tryParse(price)?.toStringAsFixed(0) ?? price}",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
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
