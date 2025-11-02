import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import 'provider/product_provider.dart';
import 'widgets/product_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    // initial fetch is handled centrally by BottomBarScreen when this tab
    // is created. Avoid doing network calls here to prevent duplicate calls.
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CommonAppBar(
            title: 'Products',
            titleAlignment: BarTitleAlignment.left,
            showBack: false,
            actions: [
              BarIcon(icon: Icons.search),
              SizedBox(width: 6),
            ],
            showBottomLine: false,
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : (provider.products.isEmpty)
                ? const _EmptyState()
                : GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 22.w,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: provider.products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                    itemBuilder: (context, index) =>
                        ProductCard(product: provider.products[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 80.h),
        Center(
          child: const Text(
            "No products found",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
