import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/my_order_card.dart';
import 'package:vd_customer_app/feature/my_order_screen/provider/my_order_provider.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/invoice_viewer_screen.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/order_detail_screen.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/subscription_detail_screen.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

class MyOrderTabBar extends StatefulWidget {
  const MyOrderTabBar({super.key});

  @override
  State<MyOrderTabBar> createState() => _MyOrderTabBarState();
}

class _MyOrderTabBarState extends State<MyOrderTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyOrderProvider>().loadAllForTab1();
    });

    // Keep lazy-loading behavior on tab change
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final p = context.read<MyOrderProvider>();

      if (_tabController.index == 0) {
        if (!p.allDataLoaded) p.loadAllForTab1();
      }
      if (_tabController.index == 1) {
        if (!p.subscriptionsLoaded) p.fetchSubscriptions();
      }
      if (_tabController.index == 2) {
        if (!p.ordersLoaded) p.fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            preferredSize: const Size.fromHeight(48),
            child: TabBar(
              controller: _tabController,
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
            return TabBarView(
              controller: _tabController,
              children: [
                // Pull-to-refresh wrapper for the All Orders tab
                RefreshIndicator(
                  onRefresh: () async {
                    // call provider method to refresh data
                    await context.read<MyOrderProvider>().loadAllForTab1();
                  },
                  child: provider.isLoadingAll
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : provider.allOrdersUnified.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: Text("No orders found."),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(8.0.r),
                          itemCount: provider.allOrdersUnified.length,
                          itemBuilder: (context, index) {
                            final item = provider.allOrdersUnified[index];

                            return Padding(
                              padding: EdgeInsets.all(8.0.r),
                              child: MyOrderCard(
                                id: '${item.type == "subscription" ? "Subscription ID" : "Order ID"}: ${item.id}',
                                date: item.date,

                                status: item.status,
                                productName: item.productName,
                                imageUrl:
                                    item.signedUrl ??
                                    item.rawImageUrl ??
                                    'assets/images/image.png',
                                detail: item.type == "subscription"
                                    ? "Frequency: ${item.deliveryFrequency}"
                                    : "Quantity: ${item.quantity}",
                                paymentMethod: item.type == "subscription"
                                    ? "Next Delivery: ${item.nextDelivery}"
                                    : "PayPal",
                                invoiceUrl: item.invoiceUrl,
                                invoiceNumber: item.invoiceNumber,
                                currentStatus: item.type == "subscription"
                                    ? item.currentStatus
                                    : null,
                                onViewTap: () {
                                  if (item.type == "subscription") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SubscriptionDetailScreen(
                                              subscriptionId: int.parse(
                                                item.id,
                                              ),
                                            ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderDetailScreen(
                                          orderId: int.parse(item.id),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onInvoiceTap:
                                    (item.invoiceUrl != null &&
                                        item.invoiceNumber != null)
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InvoiceViewerScreen(
                                                  invoiceUrl: item.invoiceUrl!,
                                                  invoiceNumber:
                                                      item.invoiceNumber!,
                                                ),
                                          ),
                                        );
                                      }
                                    : () {
                                        MySnackBar.showSnackBar(
                                          context,
                                          'Invoice not available',
                                        );
                                      },
                              ),
                            );
                          },
                        ),
                ),

                // Pull-to-refresh wrapper for Subscriptions tab
                RefreshIndicator(
                  onRefresh: () async {
                    await context.read<MyOrderProvider>().fetchSubscriptions();
                  },
                  child: provider.isLoading && provider.subscriptions.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : provider.subscriptions.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: Text("No subscription orders found."),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(8.0.r),
                          itemCount: provider.subscriptions.length,
                          itemBuilder: (context, i) {
                            final sub = provider.subscriptions[i];
                            final product = sub.products.isNotEmpty
                                ? sub.products[0]
                                : null;

                            return Padding(
                              padding: EdgeInsets.all(8.0.r),
                              child: MyOrderCard(
                                id: 'Subscription ID: ${sub.id}',
                                date:
                                    "Starts:${sub.startDate.toString().split(' ').first}",
                                productName:
                                    product?.productName ??
                                    "Subscription Product",
                                imageUrl:
                                    product?.signedUrl ??
                                    product?.imageUrl ??
                                    'assets/images/image.png',
                                detail:
                                    "Frequency: ${sub.deliveryFrequencyType}",
                                icon2: Icons.calendar_month,
                                paymentMethod:
                                    "Next Delivery : ${sub.startDate.toString().split(' ').first}",
                                invoiceUrl: sub.invoice?.signedUrl,
                                invoiceNumber: sub.invoice?.invoiceNumber,
                                currentStatus: sub.status,
                                onViewTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SubscriptionDetailScreen(
                                            subscriptionId: sub.id,
                                          ),
                                    ),
                                  );
                                },
                                onInvoiceTap:
                                    (sub.invoice?.signedUrl != null &&
                                        sub.invoice?.invoiceNumber != null)
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InvoiceViewerScreen(
                                                  invoiceUrl:
                                                      sub.invoice!.signedUrl!,
                                                  invoiceNumber: sub
                                                      .invoice!
                                                      .invoiceNumber,
                                                ),
                                          ),
                                        );
                                      }
                                    : () {
                                        MySnackBar.showSnackBar(
                                          context,
                                          'Invoice not available',
                                        );
                                      },
                              ),
                            );
                          },
                        ),
                ),

                // Pull-to-refresh wrapper for One-time Orders tab
                RefreshIndicator(
                  onRefresh: () async {
                    await context.read<MyOrderProvider>().fetchOrders();
                  },
                  child: provider.isLoading && provider.orders.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : provider.orders.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: Text("No one-time orders found."),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(8.0.r),
                          itemCount: provider.orders.length,
                          itemBuilder: (context, i) {
                            final order = provider.orders[i];
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
                                detail:
                                    'Quantity: ${cartDetail?.quantity ?? 1}',
                                paymentMethod: 'PayPal',
                                invoiceUrl: order.invoice?.signedUrl,
                                invoiceNumber: order.invoice?.invoiceNumber,
                                onInvoiceTap:
                                    (order.invoice?.signedUrl != null &&
                                        order.invoice?.invoiceNumber != null)
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InvoiceViewerScreen(
                                                  invoiceUrl:
                                                      order.invoice!.signedUrl!,
                                                  invoiceNumber: order
                                                      .invoice!
                                                      .invoiceNumber,
                                                ),
                                          ),
                                        );
                                      }
                                    : () {
                                        MySnackBar.showSnackBar(
                                          context,
                                          'Invoice not available',
                                        );
                                      },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
