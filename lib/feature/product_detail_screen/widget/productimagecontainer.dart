import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/product_detail_screen/provider/product_detail_provider.dart';

class ProductImageContainer extends StatefulWidget {
  final double? height;
  final double borderRadius;

  const ProductImageContainer({super.key, this.height, this.borderRadius = 15});

  @override
  State<ProductImageContainer> createState() => _ProductImageContainerState();
}

class _ProductImageContainerState extends State<ProductImageContainer> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        final provider = context.read<ProductDetailProvider>();
        final product = provider.selectedProduct;
        final imageCount = product?.images.length ?? 0;

        if (imageCount > 0) {
          if (nextPage >= imageCount) {
            nextPage = 0;
          }
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();
    final product = provider.selectedProduct;

    final images = product?.images ?? [];
    final hasImages = images.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              child: hasImages
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final image = images[index];
                        final imageUrl = image.signedUrl ?? image.rawImageUrl;

                        return imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/Bigbottle.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/Bigbottle.png',
                                fit: BoxFit.cover,
                              );
                      },
                    )
                  : Image.asset(
                      'assets/images/Bigbottle.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
            if (hasImages && images.length > 1)
              Positioned(
                bottom: 10.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AllColors.buttonColor
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
