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
  final ScrollController _subscriptionScrollController = ScrollController();
  final ScrollController _orderScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<MyOrderProvider>();
      if (!p.subscriptionsLoaded) p.fetchSubscriptions();
    });

    _subscriptionScrollController.addListener(() {
      if (_subscriptionScrollController.position.pixels >=
          _subscriptionScrollController.position.maxScrollExtent) {
        final provider = context.read<MyOrderProvider>();
        if (!provider.isMoreSubscriptionsLoading &&
            provider.currentSubscriptionPage <
                provider.totalSubscriptionPages) {
          provider.fetchSubscriptions(
            page: provider.currentSubscriptionPage + 1,
          );
        }
      }
    });

    _orderScrollController.addListener(() {
      if (_orderScrollController.position.pixels >=
          _orderScrollController.position.maxScrollExtent) {
        final provider = context.read<MyOrderProvider>();
        if (!provider.isMoreOrdersLoading &&
            provider.currentOrderPage < provider.totalOrderPages) {
          provider.fetchOrders(page: provider.currentOrderPage + 1);
        }
      }
    });

    // Keep lazy-loading behavior on tab change
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final p = context.read<MyOrderProvider>();

      if (_tabController.index == 0) {
        if (!p.subscriptionsLoaded) p.fetchSubscriptions();
      }
      if (_tabController.index == 1) {
        if (!p.ordersLoaded) p.fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subscriptionScrollController.dispose();
    _orderScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                          controller: _subscriptionScrollController,
                          padding: EdgeInsets.all(8.0.r),
                          itemCount:
                              provider.subscriptions.length +
                              (provider.isMoreSubscriptionsLoading ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == provider.subscriptions.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
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
                          controller: _orderScrollController,
                          padding: EdgeInsets.all(8.0.r),
                          itemCount:
                              provider.orders.length +
                              (provider.isMoreOrdersLoading ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == provider.orders.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
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
                                paymentMethod: '',
                                invoiceUrl: order.invoice?.signedUrl,
                                invoiceNumber: order.invoice?.invoiceNumber,
                                onViewTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailScreen(
                                        orderId: order.orderId,
                                      ),
                                    ),
                                  );
                                },
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
