import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

import '../../core/models/product_model.dart';
import '../../core/utils/common_widgets/common_add_subt_button.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../home_screen/widgets/home_product_card.dart';
import 'provider/product_detail_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductDetailProvider>();

      provider.fetchSpecificProduct(widget.productId);
      provider.fetchDetailProducts({
        "filterModel": {},
        "orderBy": "productName",
        "orderDir": "ASC",
        "searchText": "",
        "page": 1,
        "pageSize": 10,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();
    final detail = provider.specificProduct;

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: CommonButton(
                buttonValue: 'Add to Cart',
                variant: ButtonVariant.outlined,
                color: AllColors.iconColor,
                borderColor: AllColors.iconColor,
                foregroundColor: AllColors.iconColor,
                backgroundColor: Colors.transparent,
                onTap: () {},
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CommonButton(
                buttonValue: 'Buy Now',
                variant: ButtonVariant.filled,
                color: AllColors.buttonColor,
                foregroundColor: Colors.white,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
      body: provider.isDetailLoading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : detail == null
          ? const Center(child: Text('Product not found'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonAppBar(
                  title: 'Product Detail',
                  showBottomLine: true,
                  showBack: true,
                  titleAlignment: BarTitleAlignment.center,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ImageSlider(images: detail.images),
                        SizedBox(height: 8.h),
                        Text(
                          detail.productName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(
                          endIndent: 200,
                          color: AllColors.tabBarline,
                          thickness: 2,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text(
                              provider.selectedPriceLabel,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            const Icon(Icons.star, color: Color(0xFFF6E125)),
                            Text(
                              '4.5 Review',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        SizedBox(height: 8.h),
                        Text(
                          'Volume',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AllColors.iconColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 20,
                          runSpacing: 10,
                          children: List.generate(detail.variants.length, (i) {
                            final v = detail.variants[i];
                            final isSelected =
                                i == provider.selectedVariantIndex;
                            final label = _mlToLabel(int.parse(v.quantityInMl));

                            return SizedBox(
                              width: 80.w,
                              child: CommonButton(
                                buttonValue: label,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 4.h,
                                ),
                                variant: ButtonVariant.outlined,
                                backgroundColor: isSelected
                                    ? AllColors.lightgreenColor
                                    : Colors.white,
                                borderColor: isSelected
                                    ? AllColors.lightgreenColor
                                    : AllColors.tabBarline,
                                color: isSelected
                                    ? AllColors.lightgreenColor
                                    : AllColors.tabBarline,
                                foregroundColor: isSelected
                                    ? Colors.white
                                    : AllColors.tabBarline,
                                textStyle: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                onTap: () => provider.selectVariantByIndex(i),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AllColors.iconColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        AddSubtButton(radius: 12.r),
                        SizedBox(height: 14.h),
                        Text(
                          'About this Product',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          detail.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Most Popular Products',
                          style: TextStyle(
                            color: AllColors.olivegreenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        provider.detailProducts.isEmpty
                            ? Center(
                                child: Text(
                                  "No products found",
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(bottom: 20.h),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.detailProducts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.72,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                    ),
                                itemBuilder: (context, index) {
                                  final product =
                                      provider.detailProducts[index];
                                  return HomeProductCard(product: product);
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _mlToLabel(int ml) {
    if (ml % 1000 == 0) {
      final l = (ml / 1000).toStringAsFixed(0);
      return '$l Ltr';
    }
    return '$ml ml';
  }
}

class _ImageSlider extends StatefulWidget {
  final List<ProductImage> images;

  const _ImageSlider({required this.images});

  @override
  State<_ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<_ImageSlider> {
  final _controller = PageController();
  int _index = 0;
  Timer? _timer;

  List<String> get _urls {
    return widget.images
        .map((img) {
          final u = img.signedUrl ?? img.rawImageUrl;
          return u;
        })
        .where((u) => u.isNotEmpty)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  void _startAuto() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _urls.isEmpty) return;
      _index = (_index + 1) % _urls.length;
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    if (urls.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/Bigbottle.png',
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTapDown: (_) => _timer?.cancel(),
              onTapUp: (_) => _startAuto(),
              onTapCancel: () => _startAuto(),
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: urls.length,
                itemBuilder: (_, i) {
                  final u = urls[i];
                  return Image.network(
                    u,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/Bigbottle.png',
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(urls.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: active ? 16 : 6,
              decoration: BoxDecoration(
                color: active ? AllColors.buttonColor : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
