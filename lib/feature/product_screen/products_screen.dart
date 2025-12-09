import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_empty_state.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    return Scaffold(
      body: Column(
        children: [
          const CommonAppBar(
            title: 'Products',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await provider.getProducts(
                  {
                    "filterModel": {},
                    "orderBy": "productName",
                    "orderDir": "ASC",
                    "searchText": "",
                    "page": 1,
                    "pageSize": 10,
                  },
                  forceRefresh: true,
                );
              },
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (provider.products.isEmpty)
                      ? const CommonEmptyState(title: "No products found")
                      : GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(
                            vertical: 10.h,
                            horizontal: 12.w,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: provider.products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemBuilder: (context, index) =>
                              ProductCard(product: provider.products[index]),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
