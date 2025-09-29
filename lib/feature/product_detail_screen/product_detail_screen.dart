import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

import '../../core/utils/common_widgets/common_add_subt_button.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../../core/utils/common_widgets/subscription_container.dart';
import '../home_screen/widgets/home_product_card.dart';
import 'provider/product_detail_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductDetailProvider>();
      final requestData = {
        "filterModel": {},
        "orderBy": "productName",
        "orderDir": "ASC",
        "searchText": "",
        "page": 1,
        "pageSize": 10,
      };
      provider.fetchDetailProducts(requestData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();

    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      appBar: CommonAppBar(title: 'Product Detail'),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Image
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SubscriptionContainer(),
                    ),

                    // Product Name
                    Text(
                      'Alkaline Water',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      endIndent: 300,
                      color: AllColors.tabBarline,
                      thickness: 2,
                    ),
                    Text(
                      'pH 9.5+ for improved hydration',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Rs. 400.00',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 15),
                        Icon(
                          Icons.star,
                          color: const Color.fromARGB(255, 246, 225, 37),
                        ),
                        Text(
                          '4.5 Review',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),

                    Text(
                      'Volume',
                      style: TextStyle(
                        fontSize: 16,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CommonButton(
                          radius: 20,
                          buttonValue: '2 Ltr',
                          backgroundColor: AllColors.lightgreenColor,

                          selfconstraints: const BoxConstraints(minHeight: 40),
                        ),
                        CommonButton(
                          radius: 20,
                          buttonValue: '1 Ltr',
                          backgroundColor: AllColors.lightgreenColor,

                          selfconstraints: const BoxConstraints(minHeight: 40),
                        ),
                        CommonButton(
                          radius: 20,
                          buttonValue: '3 Ltr',
                          backgroundColor: AllColors.lightgreenColor,

                          selfconstraints: const BoxConstraints(minHeight: 40),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [AddSubtButton(radius: 15)]),
                    const SizedBox(height: 22),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: SubscriptionContainer(),
                    ),

                    // About Section
                    Text(
                      'About this Product',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum ",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color.fromARGB(255, 54, 54, 54),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'More Popular Products',
                      style: TextStyle(
                        fontSize: 19,
                        color: AllColors.olivegreenColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    provider.detailProducts.isEmpty
                        ? const Center(
                            child: Text(
                              "No products found",
                              style: TextStyle(fontSize: 16),
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

                    Row(
                      children: [
                        Expanded(
                          child: CommonButton(
                            buttonValue: 'Subscribe',
                            textStyle: TextStyle(color: AllColors.iconColor),

                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: CommonButton(buttonValue: 'Add to Cart'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
