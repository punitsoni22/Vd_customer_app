import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/utils/formatters.dart';
import '../../../../core/utils/common_widgets/common_price_display.dart';

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
  void didUpdateWidget(covariant SubscriptionPriceDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.variants.isNotEmpty ? widget.selectedIndex : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AllColors.olivegreenColor;

    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: primary.withOpacity(0.6), width: 0.9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<int>(
          value: selectedIndex,
          isExpanded: true,

          // text style inside button
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),

          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: primary,
              size: 18.sp,
            ),
          ),

          dropdownStyleData: DropdownStyleData(
            // null width -> match button width (simpler)
            width: null,
            offset: const Offset(0, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            elevation: 0,
            maxHeight: 200.h,
          ),

          menuItemStyleData: MenuItemStyleData(
            height: 34.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
          ),

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
            final priceRaw = double.tryParse(variant.price ?? '');
            final priceText = priceRaw != null
                ? priceRaw.toStringAsFixed(0)
                : variant.price;

            return DropdownMenuItem<int>(
              value: idx,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatVolume(quantity).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  CommonPriceDisplay(
                    price: priceText,
                    originalPrice: variant.originalPrice != null
                        ? (double.tryParse(variant.originalPrice!) ?? 0)
                            .toInt()
                            .toString()
                        : null,
                    priceStyle: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                    originalPriceStyle: TextStyle(
                      fontSize: 10.sp,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
