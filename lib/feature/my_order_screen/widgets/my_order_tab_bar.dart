import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/my_order_card.dart';
import 'package:vd_customer_app/feature/profile_screen/widgets/profile_orders_container.dart';

class MyOrderTabBar extends StatelessWidget {
  const MyOrderTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: TabBar(
              labelColor: AllColors.lightgreenColor,
              unselectedLabelColor: Colors.grey[300],

              indicatorColor: AllColors.tabBarline,
              tabs: [
                Tab(text: "All Order"),
                Tab(text: "Subscription"),
                Tab(text: "One Time Order"),
              ],
            ),
          ),
        ),

        body: TabBarView(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0.r),
              child: const MyOrderCard(
                id: 'Order ID: CRD78901',
                date: '2024-11-20',
                status: 'Pause',
                imageUrl: 'assets/images/image.png',
                productName: 'Alkaline Water',
                detail: 'Quantity: 1',
                paymentMethod: 'PayPal',
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0.r),
              child: const MyOrderCard(
                id: 'CRD78901',
                date: '2024-11-20',
                status: 'Delivered',
                imageUrl: 'assets/images/image.png',
                productName: 'Alkaline Water',
                detail: 'Quantity: 1',
                paymentMethod: 'PayPal',
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0.r),
              child: const MyOrderCard(
                id: 'CRD78901',
                date: '2024-11-20',
                status: 'Active',
                imageUrl: 'assets/images/image.png',
                productName: 'Alkaline Water',
                detail: 'Quantity: 1',
                paymentMethod: 'PayPal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllOrderCards extends StatelessWidget {
  const AllOrderCards({super.key});

  @override
  Widget build(BuildContext context) {
    return MyOrderCard(
      id: '',
      date: '',
      status: '',
      imageUrl: '',
      productName: '',
      detail: '',
      paymentMethod: '',
    );
  }
}
