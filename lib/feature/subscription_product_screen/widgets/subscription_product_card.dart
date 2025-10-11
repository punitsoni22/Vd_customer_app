import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/widgets/price_drop_down_bar.dart';

class SubscriptionProductCard extends StatelessWidget {
  final Product? product;
  final double width;
  final double height;
  const SubscriptionProductCard({
    super.key,
    this.product,
    this.width = 160,
    this.height = 286,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                  color: Colors.teal.withValues(alpha: 0.10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.asset(
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
                            'AQUAFLOW 20L PURIFIED WATER',
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
                              Expanded(child: SubscriptionPriceDropdown()),
                              SizedBox(width: 5.w),
                              Container(
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
                                  size: 12.sp,
                                  color: AllColors.olivegreenColor,
                                ),
                              ),
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
}
