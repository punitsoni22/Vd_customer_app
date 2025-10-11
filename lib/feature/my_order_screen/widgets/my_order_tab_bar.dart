import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/my_order_card.dart';
import 'package:vd_customer_app/feature/my_order_screen/provider/my_order_provider.dart';

class MyOrderTabBar extends StatefulWidget {
  const MyOrderTabBar({super.key});

  @override
  State<MyOrderTabBar> createState() => _MyOrderTabBarState();
}

class _MyOrderTabBarState extends State<MyOrderTabBar> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MyOrderProvider>();
      provider.fetchOrders();
    });
  }

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
              tabs: const [
                Tab(text: "All Order"),
                Tab(text: "Subscription"),
                Tab(text: "One Time Order"),
              ],
            ),
          ),
        ),
        body: Consumer<MyOrderProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.orders.isEmpty) {
              return const Center(child: Text("No orders found."));
            }

            final orders = provider.orders;

            return TabBarView(
              children: List.generate(3, (tabIndex) {
                return ListView.builder(
                  padding: EdgeInsets.all(8.0.r),
                  itemCount: orders.length,
                  itemBuilder: (context, i) {
                    final order = orders[i];
                    final cartDetail = order.cart.cartDetails.isNotEmpty
                        ? order.cart.cartDetails[0]
                        : null;

                    return Padding(
                      padding: EdgeInsets.all(8.0.r),
                      child: MyOrderCard(
                        id: 'Order ID: ${order.orderId}',
                        date: order.orderConfirmedDate.split('T').first,
                        status: order.status,
                        productName:
                            cartDetail?.productName ?? 'Alkaline Water',
                        imageUrl:
                            cartDetail?.productImages.signedUrl ??
                            cartDetail?.productImages.imageUrl ??
                            'assets/images/image.png',
                        detail: 'Quantity: ${cartDetail?.quantity ?? 1}',
                        paymentMethod: 'PayPal',
                      ),
                    );
                  },
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
