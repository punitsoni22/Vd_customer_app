import 'package:flutter/material.dart';
import 'package:vd_customer_app/constants/products_tiltedbottlelist.dart';
import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/add_subt_button.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';
import 'package:vd_customer_app/widgets/custom_button.dart';
import 'package:vd_customer_app/widgets/gridview_container.dart';
import 'package:vd_customer_app/widgets/image_container.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      appBar: CustomAppBar(title: 'Product Detail', islineNeeded: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ImageContainer(),
              ),
              Text(
                'Alkaline Water',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Divider(
                endIndent: 300,
                color: AllColors.tabBarline,
                thickness: 2,
              ),
              Text(
                'pH 9.5+ for improved hydration',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                'Rs. 400.00',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Divider(),
              Text(
                'Volume',
                style: TextStyle(
                  fontSize: 16,
                  color: AllColors.iconColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonButton(
                    buttonValue: '2 Ltr',
                    backgroundColor: AllColors.lightgreenColor,
                    color: AllColors.lightgreenColor,
                    selfconstraints: const BoxConstraints(minHeight: 40),
                  ),
                  CommonButton(
                    buttonValue: '1 Ltr',
                    backgroundColor: AllColors.lightgreenColor,
                    color: AllColors.lightgreenColor,
                    selfconstraints: const BoxConstraints(minHeight: 40),
                  ),
                  CommonButton(
                    buttonValue: '3 Ltr',
                    backgroundColor: AllColors.lightgreenColor,
                    color: AllColors.lightgreenColor,
                    selfconstraints: const BoxConstraints(minHeight: 40),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Quantity',
                style: TextStyle(
                  fontSize: 16,
                  color: AllColors.iconColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(children: [AddSubtButton()]),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ImageContainer(),
              ),
              Text(
                'About this Product',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '  Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum  ',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'More Popular Products',
                style: TextStyle(
                  fontSize: 19,
                  color: AllColors.olivegreenColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 20,
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return BigGridContainer(
                      product: product,
                      showPrice: false,
                      showActions: false,
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      buttonValue: 'Subscribe',
                      textStyle: TextStyle(color: AllColors.iconColor),
                      color: AllColors.iconColor,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(child: CommonButton(buttonValue: 'Add to Cart')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
