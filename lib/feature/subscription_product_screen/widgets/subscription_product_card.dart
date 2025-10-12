import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

import 'package:vd_customer_app/feature/subscription_product_screen/widgets/price_drop_down_bar.dart';

class SubscriptionProductCard extends StatefulWidget {
  final Product? product;
  final double width;
  final double height;
  final void Function(Map<String, dynamic> selection)? onSelect;
  final void Function(int productId, int variantId)? onUnselect;
  final bool isSelected;
  final int currentQuantity;

  const SubscriptionProductCard({
    super.key,
    this.product,
    this.width = 160,
    this.height = 286,
    this.onSelect,
    this.onUnselect,
    this.isSelected = false,
    this.currentQuantity = 0,
  });

  @override
  State<SubscriptionProductCard> createState() => _SubscriptionProductCardState();
}

class _SubscriptionProductCardState extends State<SubscriptionProductCard> {
  int selectedVariantIndex = 0;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    selectedVariantIndex = 0;
    quantity = widget.currentQuantity > 0 ? widget.currentQuantity : 1;
  }

  @override
  void didUpdateWidget(SubscriptionProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentQuantity != oldWidget.currentQuantity && widget.currentQuantity > 0) {
      quantity = widget.currentQuantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imgUrl = (widget.product != null && widget.product!.images.isNotEmpty)
        ? widget.product!.images.first.signedUrl
        : null;
    final String productName = (widget.product != null && widget.product!.productName.isNotEmpty)
        ? widget.product!.productName.toUpperCase()
        : 'N/A';

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: widget.isSelected ? Border.all(color: Colors.teal, width: 2) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 10,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    width: double.infinity,
                    child: (imgUrl != null && imgUrl.isNotEmpty)
                        ? Image.network(
                            imgUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/Bigbottle.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/Bigbottle.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                              color: AllColors.olivegreenColor,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Expanded(
                                child: SubscriptionPriceDropdown(
                                  variants: widget.product?.variants ?? [],
                                  selectedIndex: selectedVariantIndex,
                                  onVariantSelected: (variant, index) {
                                    setState(() {
                                      selectedVariantIndex = index;
                                    });
                                    _notifySelection();
                                  },
                                ),
                              ),
                              SizedBox(width: 5.w),
                              _buildQuantityControls(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _notifySelection() {
    if (widget.onSelect != null && widget.product != null && widget.product!.variants.isNotEmpty) {
      final variant = widget.product!.variants[selectedVariantIndex];
      widget.onSelect!({
        'productId': widget.product!.id,
        'variantId': variant.id,
        'quantity': quantity,
      });
    }
  }

  Widget _buildQuantityControls() {
    if (!widget.isSelected) {
      // Show add button when not selected
      return GestureDetector(
        onTap: () {
          setState(() {
            quantity = 1;
          });
          _notifySelection();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            color: Colors.white,
            border: Border.all(
              color: AllColors.olivegreenColor,
            ),
          ),
          width: 32.w,
          height: 32.h,
          child: Icon(
            Icons.add,
            size: 16.sp,
            color: AllColors.olivegreenColor,
          ),
        ),
      );
    } else {
      // Show quantity controls when selected
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (quantity > 1) {
                setState(() {
                  quantity--;
                });
                _notifySelection();
              } else {
                // Remove item when quantity becomes 0
                if (widget.onUnselect != null && widget.product != null && widget.product!.variants.isNotEmpty) {
                  final variant = widget.product!.variants[selectedVariantIndex];
                  widget.onUnselect!(widget.product!.id, variant.id);
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red),
              ),
              width: 24.w,
              height: 24.h,
              child: Icon(
                Icons.remove,
                size: 12.sp,
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              color: Colors.teal.withOpacity(0.1),
              border: Border.all(color: Colors.teal),
            ),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () {
              setState(() {
                quantity++;
              });
              _notifySelection();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: Colors.teal.withOpacity(0.1),
                border: Border.all(color: Colors.teal),
              ),
              width: 24.w,
              height: 24.h,
              child: Icon(
                Icons.add,
                size: 12.sp,
                color: Colors.teal,
              ),
            ),
          ),
        ],
      );
    }
  }
}
