import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/cart_model.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import '../../core/utils/common_widgets/common_add_subt_button.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../../core/utils/common_widgets/common_subscription_container.dart';
import '../home_screen/widgets/home_product_card.dart';
import 'provider/product_detail_provider.dart';

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
          if (provider.selectedProduct != null &&
              provider.selectedProduct!.variants.isNotEmpty) {
            setState(() {
              selectedVariant = provider.selectedProduct!.variants.first;
            });
          }
        });
        final requestData = {
          "filterModel": {},
          "orderBy": "productName",
          "orderDir": "ASC",
          "searchText": "",
          "page": 1,
          "pageSize": 10,
        };
        provider.fetchDetailProducts(requestData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();
    final double bottomBarHeight = 64.h;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Product Detail',
        titleAlignment: BarTitleAlignment.center,
        showBack: true,
        onBack: () {
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          } else {
            GoRouter.of(context).goNamed(AppRoutes.bottomBarScreen);
          }
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: bottomBarHeight,
          padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
          color: Colors.transparent,
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
                  padding: EdgeInsets.all(5.r),
                  backgroundColor: Colors.transparent,
                  selfconstraints: BoxConstraints(minHeight: 50.h),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CommonButton(
                  buttonValue: 'Add to Cart',
                  variant: ButtonVariant.filled,
                  color: AllColors.buttonColor,
                  foregroundColor: Colors.white,
                  selfconstraints: BoxConstraints(minHeight: 50.h),
                  fontSize: 16.sp,
                  isLoading: isAddingToCart,
                  padding: EdgeInsets.all(5.r),
                  onTap: isAddingToCart
                      ? null
                      : () async {
                          final productProvider = context
                              .read<ProductDetailProvider>();
                          final cartProvider = context.read<CartProvider>();
                          final selectedProduct =
                              productProvider.selectedProduct;
                          if (selectedProduct == null ||
                              selectedProduct.variants.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product not available'),
                              ),
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
                            // navigate to bottom bar screen with Cart tab selected
                            context.goNamed(
                              AppRoutes.bottomBarScreen,
                              extra: {'index': 3},
                            );
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        },
                ),
              ),
            ],
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              // add bottom padding equal to the bottom bar height so content
              // is not hidden behind the fixed action bar
              padding: EdgeInsets.only(
                left: 22.w,
                top: 2.h,
                right: 12.w,
                // bottom: bottomBarHeight + 8.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: SubscriptionContainer(),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      provider.selectedProduct?.productName ?? 'Product Name',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      endIndent: 250,
                      color: AllColors.tabBarline,
                      thickness: 2,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      provider.selectedProduct?.description ??
                          'pH 9.5+ for improved hydration',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Rs. ${provider.selectedProduct?.displayPrice ?? '00'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: const Divider(),
                    ),
                    Text(
                      'Volume',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:
                            provider.selectedProduct?.variants.map((variant) {
                              String displayQuantity =
                                  '${variant.quantityInMl} L';
                              final isSelected =
                                  selectedVariant?.id == variant.id;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedVariant = variant;
                                    selectedQuantity = 1;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: 29.0.w,
                                    bottom: 2.h,
                                  ),
                                  child: CommonButton(
                                    radius: 20.r,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                    ),
                                    buttonValue: displayQuantity,
                                    textStyle: TextStyle(
                                      fontSize: 11.sp,
                                      color: isSelected
                                          ? Colors.white
                                          : AllColors.buttonColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    borderColor: AllColors.buttonColor,
                                    backgroundColor: isSelected
                                        ? AllColors.lightgreenColor
                                        : const Color.fromARGB(
                                            255,
                                            248,
                                            253,
                                            255,
                                          ),
                                    selfconstraints: BoxConstraints(
                                      minHeight: 38.h,
                                      maxWidth: 91.w,
                                    ),
                                  ),
                                ),
                              );
                            }).toList() ??
                            [],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CommonAddSubtButton(
                          radius: 15.r,
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

                    Text(
                      'About this Product',
                      style: TextStyle(
                        fontSize: 17.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Lorem Ipsum\u00a0is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text...",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Color.fromARGB(255, 54, 54, 54),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Most Popular Products',
                      style: TextStyle(
                        fontSize: 19.sp,
                        color: AllColors.olivegreenColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    provider.detailProducts.isEmpty
                        ? Center(
                            child: Text(
                              "No products found",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          )
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: provider.detailProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.6,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                            itemBuilder: (context, index) {
                              final product = provider.detailProducts[index];
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
