import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/constants/products_tiltedbottlelist.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_gridview_cards.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_listview_cards.dart';
import 'package:vd_customer_app/feature/product_list_screen/provider/product_screen_provider.dart';
import 'package:vd_customer_app/navigation_bar.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      final requestData = {
        "filterModel": {},
        "orderBy": "productName",
        "orderDir": "ASC",
        "searchText": "",
        "page": 1,
        "pageSize": 10,
      };
      provider.getProducts(requestData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      bottomNavigationBar: CommonBottomAppbar(),
      appBar: CustomAppBar(
        alignment: Alignment.centerLeft,
        title: 'Products',
        actions: [
          Icon(Icons.search_sharp, color: AllColors.buttonColor, size: 32),
        ],
        islineNeeded: false,
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          final imageUrl = product.images.isNotEmpty
                              ? (product.images.first.signedUrl ??
                                    'assets/SmallBottlePlaceholder.png')
                              : 'assets/SmallBottlePlaceholder.png';

                          final smallBottle = SmallBottle(
                            bottlename: product.productName,
                            bottleimage: imageUrl,
                          );

                          return SmallBottleCards(smallBottle: smallBottle);
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 10,
                      ),
                      child: provider.products.isEmpty
                          ? const Center(
                              child: Text(
                                "No products found",
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: provider.products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.59,
                                    crossAxisSpacing: 19,
                                    mainAxisSpacing: 17,
                                  ),
                              itemBuilder: (context, index) {
                                final product = provider.products[index];
                                return BigGridContainer(product: product);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
