import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/widgets/price_drop_down_bar.dart';

class SubscriptionProductCard extends StatefulWidget {
  final Product? product;
  final double width;
  final void Function(Map<String, dynamic> selection)? onSelect;
  final void Function(int productId, int variantId)? onUnselect;
  final bool isSelected;
  final int currentQuantity;

  const SubscriptionProductCard({
    super.key,
    this.product,
    this.width = 160,
    this.onSelect,
    this.onUnselect,
    this.isSelected = false,
    this.currentQuantity = 0,
  });

  @override
  State<SubscriptionProductCard> createState() =>
      _SubscriptionProductCardState();
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
  void didUpdateWidget(covariant SubscriptionProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentQuantity != oldWidget.currentQuantity &&
        widget.currentQuantity > 0) {
      quantity = widget.currentQuantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AllColors.olivegreenColor;

    final String? imgUrl =
    (widget.product != null && widget.product!.images.isNotEmpty)
        ? widget.product!.images.first.signedUrl
        : null;
    final String productName =
    (widget.product != null && widget.product!.productName.isNotEmpty)
        ? widget.product!.productName.toUpperCase()
        : 'N/A';

    final isSelected = widget.isSelected && quantity > 0;

    final card = Container(
      decoration: BoxDecoration(
        color: isSelected ? primary.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? primary : Colors.grey.withValues(alpha: 0.25),
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                color: primary.withValues(alpha: 0.08),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
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
            flex: 6,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SubscriptionPriceDropdown(
                        variants: widget.product?.variants ?? [],
                        selectedIndex: selectedVariantIndex,
                        onVariantSelected: (variant, index) {
                          setState(() {
                            selectedVariantIndex = index;
                          });
                          _notifySelection();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      if (isSelected)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12.sp,
                                color: primary,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Added',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      _buildQuantityControls(primary, isSelected),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: widget.width,
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() {
              quantity = 1;
            });
            _notifySelection();
          }
        },
        child: card,
      ),
    );
  }

  void _notifySelection() {
    if (widget.onSelect != null &&
        widget.product != null &&
        widget.product!.variants.isNotEmpty) {
      final variant = widget.product!.variants[selectedVariantIndex];
      widget.onSelect!.call({
        'productId': widget.product!.id,
        'variantId': variant.id,
        'quantity': quantity,
      });
    }
  }

  Widget _buildQuantityControls(Color primary, bool isSelected) {
    // NOT SELECTED → simple filled "Add" button
    if (!isSelected) {
      return Expanded(
        child: SizedBox(
          height: 26.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size(0, 26.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            onPressed: () {
              setState(() {
                quantity = 1;
              });
              _notifySelection();
            },
            child: Text(
              'Add',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      height: 26.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (quantity > 1) {
                setState(() {
                  quantity--;
                });
                _notifySelection();
              } else {
                if (widget.onUnselect != null &&
                    widget.product != null &&
                    widget.product!.variants.isNotEmpty) {
                  final variant =
                  widget.product!.variants[selectedVariantIndex];
                  widget.onUnselect!(widget.product!.id, variant.id);
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: Icon(
                Icons.remove,
                size: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            quantity.toString(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6.w),
          InkWell(
            onTap: () {
              setState(() {
                quantity++;
              });
              _notifySelection();
            },
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: Icon(
                Icons.add,
                size: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
