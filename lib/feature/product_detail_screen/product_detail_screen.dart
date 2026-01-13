import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/models/cart_model.dart';
import '../../core/models/product_model.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/common_widgets/common_price_display.dart';
import '../../core/utils/common_widgets/common_add_subt_button.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/formatters.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../../widget/snack_bar.dart';
import '../cart_screen/provider/cart_provider.dart';
import '../home_screen/widgets/home_product_card.dart';
import '../home_screen/provider/home_provider.dart';
import 'provider/product_detail_provider.dart';
import 'widget/productimagecontainer.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedQuantity = 1;
  Variant? selectedVariant;
  bool isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = GoRouterState.of(context).extra as Map?;
      final productId = data?['productId'];
      if (productId != null) {
        final provider = context.read<ProductDetailProvider>();
        provider.fetchSpecificProduct(productId).then((_) {
          final product = provider.selectedProduct;
          if (product != null && product.variants.isNotEmpty) {
            setState(() {
              selectedVariant = product.variants.first;
            });
          }
        });
      }
    });
  }

  final TextEditingController _pincodeController = TextEditingController();

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();
    final homeProvider = context.watch<HomeProvider>();
    final product = provider.selectedProduct;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Product Detail',
        titleAlignment: BarTitleAlignment.center,
        showBack: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoutes.bottomBarScreen);
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: CommonButton(
                buttonValue: 'Subscribe',
                borderColor: AllColors.tabBarline,
                textStyle: TextStyle(
                  color: AllColors.iconColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: Colors.transparent,
                onTap: () {
                  final productProvider = context.read<ProductDetailProvider>();
                  final selectedProduct = productProvider.selectedProduct;

                  if (selectedProduct == null ||
                      selectedProduct.variants.isEmpty) {
                    MySnackBar.showSnackBar(
                      context,
                      'No product selected for subscription',
                    );
                    return;
                  }

                  final variant =
                      selectedVariant ?? selectedProduct.variants.first;

                  final preSelectedProduct = {
                    'productId': selectedProduct.id,
                    'variantId': variant.id,
                    'quantity': selectedQuantity,
                    'productName': selectedProduct.productName,
                    'price': variant.price,
                    'quantityInMl': variant.quantityInMl,
                    'images': selectedProduct.images
                        .map((img) => img.signedUrl ?? '')
                        .where((url) => url.isNotEmpty)
                        .toList(),
                  };

                  context.pushNamed(
                    AppRoutes.subscriptionProductScreen,
                    extra: {
                      'preSelectedProducts': [preSelectedProduct],
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CommonButton(
                buttonValue: 'Add to Cart',
                variant: ButtonVariant.filled,
                color: AllColors.buttonColor,
                foregroundColor: Colors.white,
                fontSize: 16.sp,
                isLoading: isAddingToCart,
                onTap: isAddingToCart
                    ? null
                    : () async {
                        final productProvider = context
                            .read<ProductDetailProvider>();
                        final cartProvider = context.read<CartProvider>();
                        final selectedProduct = productProvider.selectedProduct;

                        if (selectedProduct == null ||
                            selectedProduct.variants.isEmpty) {
                          MySnackBar.showSnackBar(
                            context,
                            'No product selected to add to cart',
                          );
                          return;
                        }

                        final variant =
                            selectedVariant ?? selectedProduct.variants.first;

                        final cartDetail = CartDetail(
                          id: 0,
                          productId: selectedProduct.id,
                          variantId: variant.id,
                          quantity: selectedQuantity,
                          price: double.tryParse(variant.price) ?? 0,
                          product: CartProduct(
                            id: selectedProduct.id,
                            productName: selectedProduct.productName,
                            images: selectedProduct.images
                                .map((e) => e.signedUrl ?? '')
                                .toList(),
                          ),
                        );

                        setState(() {
                          isAddingToCart = true;
                        });

                        final result = await cartProvider.addItem(
                          cartDetail,
                          context: context,
                        );
                        setState(() {
                          isAddingToCart = false;
                        });

                        final success = result['success'] == true;
                        final message =
                            result['message'] ??
                            (success
                                ? 'Added to cart successfully'
                                : 'Failed to add to cart');
                        if (success) {
                          context.goNamed(
                            AppRoutes.bottomBarScreen,
                            extra: {'index': 3},
                          );
                        }

                        MySnackBar.showSnackBar(context, message);
                      },
              ),
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
          ? Center(
              child: Text(
                'Product not found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade700),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProductImageContainer(),
                    SizedBox(height: 14.h),
                    Text(
                      product.productName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 60.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: AllColors.tabBarline,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (product.variants.isNotEmpty)
                          Builder(builder: (context) {
                            final variant =
                                selectedVariant ?? product.variants.first;
                            final price = double.tryParse(variant.price) ?? 0;
                            final originalPriceVal =
                                double.tryParse(variant.originalPrice ?? '0') ??
                                    0;

                            final showOriginalPrice = originalPriceVal > 0 &&
                                variant.originalPrice != null &&
                                variant.originalPrice!.isNotEmpty;

                            return CommonPriceDisplay(
                              price: price % 1 == 0
                                  ? price.toInt().toString()
                                  : price.toString(),
                              originalPrice: showOriginalPrice
                                  ? (originalPriceVal % 1 == 0
                                      ? originalPriceVal.toInt().toString()
                                      : originalPriceVal.toString())
                                  : null,
                              priceStyle: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AllColors.buttonColor,
                              ),
                              originalPriceStyle: TextStyle(
                                fontSize: 14.sp,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            );
                          })
                        else
                          Text(
                            'N/A',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AllColors.buttonColor,
                            ),
                          ),
                      ],
                    ),
                    Divider(height: 24.h),
                    Text(
                      'Volume',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: product.variants.map((variant) {
                          final displayQuantity = formatVolume(
                            variant.quantityInMl,
                          );
                          final isSelected = selectedVariant?.id == variant.id;

                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVariant = variant;
                                  selectedQuantity = 1;
                                });
                              },
                              child: CommonButton(
                                radius: 20.r,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                buttonValue: displayQuantity,
                                textStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: isSelected
                                      ? Colors.white
                                      : AllColors.buttonColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                borderColor: AllColors.buttonColor,
                                backgroundColor: isSelected
                                    ? AllColors.lightgreenColor
                                    : const Color(0xFFF8FDFF),
                                selfconstraints: BoxConstraints(
                                  minHeight: 34.h,
                                  minWidth: 70.w,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        CommonAddSubtButton(
                          radius: 16.r,
                          selfconstraints: BoxConstraints(
                            minHeight: 38.h,
                            minWidth: 120.w,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          initialQuantity: selectedQuantity,
                          onQuantityChanged: (newQuantity) {
                            setState(() {
                              selectedQuantity = newQuantity;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    
                    // Pincode Check Section
                    Text(
                      'Check Delivery',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48.h,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: AllColors.iconColor,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: TextField(
                                    controller: _pincodeController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                      hintText: 'Enter Pincode',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14.sp,
                                      ),
                                      border: InputBorder.none,
                                      counterText: '',
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    onChanged: (value) {
                                      if (value.length != 6) {
                                        provider.clearDeliveryStatus();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        CommonButton(
                          buttonValue: 'Check',
                          isLoading: provider.isCheckingDelivery,
                          backgroundColor: AllColors.buttonColor,
                          selfconstraints: BoxConstraints(
                            minWidth: 80.w,
                            minHeight: 48.h,
                          ),
                          onTap: () {
                            if (_pincodeController.text.length != 6) {
                              MySnackBar.showSnackBar(
                                context,
                                'Please enter a valid 6-digit pincode',
                              );
                              return;
                            }
                            FocusScope.of(context).unfocus();
                            provider.checkDeliveryPincode(
                              _pincodeController.text,
                              product.id,
                            );
                          },
                        ),
                      ],
                    ),
                    if (provider.isDeliverable != null) ...[
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: provider.isDeliverable!
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: provider.isDeliverable!
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              provider.isDeliverable!
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: provider.isDeliverable!
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                provider.deliveryMessage ?? '',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: provider.isDeliverable!
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 22.h),

                    if ((product.description).isNotEmpty) ...[
                      Text(
                        'About this Product',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF363636),
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                    Text(
                      'Most Popular Products',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AllColors.olivegreenColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    homeProvider.homeProducts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Text(
                                "No products found",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: homeProvider.homeProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                            itemBuilder: (context, index) {
                              final product = homeProvider.homeProducts[index];
                              return HomeProductCard(product: product);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
