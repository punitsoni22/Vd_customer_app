import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/validators/date_validator.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/my_order_card.dart';
import 'package:vd_customer_app/feature/my_order_screen/provider/my_order_provider.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/invoice_viewer_screen.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/order_detail_screen.dart';
import 'package:vd_customer_app/feature/my_order_screen/widgets/subscription_detail_screen.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

class MyOrderTabBar extends StatefulWidget {
  final int initialTabIndex;
  const MyOrderTabBar({super.key, this.initialTabIndex = 0});

  @override
  State<MyOrderTabBar> createState() => _MyOrderTabBarState();
}

class _MyOrderTabBarState extends State<MyOrderTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _subscriptionScrollController = ScrollController();
  final ScrollController _orderScrollController = ScrollController();

  double _round2(num v) => (v * 100).roundToDouble() / 100;

  String? _pickFirstNonEmptyString(List<String?> candidates) {
    for (final c in candidates) {
      final v = c?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  String _pickFirstNonEmptyUrl(List<String?> candidates) {
    for (final c in candidates) {
      final v = c?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return 'assets/images/image.png';
  }

  @override
  void initState() {
    super.initState();

    final idx = widget.initialTabIndex.clamp(0, 1);
    _tabController = TabController(length: 2, vsync: this, initialIndex: idx);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<MyOrderProvider>();
      p.fetchSubscriptions();
      p.fetchOrders();
    });

    _subscriptionScrollController.addListener(() {
      if (_subscriptionScrollController.position.pixels >=
          _subscriptionScrollController.position.maxScrollExtent - 200) {
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
          _orderScrollController.position.maxScrollExtent - 200) {
        final provider = context.read<MyOrderProvider>();
        if (!provider.isMoreOrdersLoading &&
            provider.currentOrderPage < provider.totalOrderPages) {
          provider.fetchOrders(page: provider.currentOrderPage + 1);
        }
      }
    });

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
  void didUpdateWidget(covariant MyOrderTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      final idx = widget.initialTabIndex.clamp(0, 1);
      if (_tabController.index != idx) {
        _tabController.index = idx;
      }
    }
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
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AllColors.olivegreenColor,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
                unselectedLabelColor: Colors.grey[400],
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
                indicatorColor: AllColors.olivegreenColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "Subscription"),
                  Tab(text: "One Time Order"),
                ],
              ),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
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
                            final resolvedInvoiceUrl = _pickFirstNonEmptyString(
                              [sub.invoice?.signedUrl, sub.invoice?.invoiceUrl],
                            );
                            final invoiceNumber = sub.invoice?.invoiceNumber
                                .trim();
                            final displayInvoiceNumber =
                                (invoiceNumber != null &&
                                    invoiceNumber.isNotEmpty)
                                ? invoiceNumber
                                : 'SUB-${sub.id}';
                            final canOpenInvoice =
                                resolvedInvoiceUrl != null &&
                                resolvedInvoiceUrl.trim().isNotEmpty &&
                                resolvedInvoiceUrl.startsWith('http');
                            final createdDateText = sub.createdOn != null &&
                                    sub.createdOn!.trim().isNotEmpty
                                ? DateValidator.formatDate(sub.createdOn!)
                                : DateValidator.formatDate(
                                    sub.startDate.toString(),
                                  );
                            final totalAmount = _round2(sub.totalAmount);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: MyOrderCard(
                                id: 'Subscription ID: ${sub.id}',
                                date: "Created: $createdDateText",
                                productName:
                                    sub.subscriptionName ??
                                    product?.productName ??
                                    "Subscription Product",
                                imageUrl: _pickFirstNonEmptyUrl([
                                  product?.signedUrl,
                                  product?.imageUrl,
                                ]),
                                detail:
                                    "Total: ₹${totalAmount.toStringAsFixed(2)}",
                                icon2: Icons.calendar_month,
                                paymentMethod:
                                    "Next Delivery : ${DateValidator.formatDate(sub.startDate.toString())}",
                                invoiceUrl: resolvedInvoiceUrl,
                                invoiceNumber: displayInvoiceNumber,
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
                                onInvoiceTap: canOpenInvoice
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InvoiceViewerScreen(
                                                  invoiceUrl:
                                                      resolvedInvoiceUrl,
                                                  invoiceNumber:
                                                      displayInvoiceNumber,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
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
                            final total = _round2(order.totalAmount);
                            final qty = (cartDetail?.quantity ?? 0) > 0
                                ? cartDetail!.quantity
                                : 1;
                            final statusUpper = order.status
                                .trim()
                                .toUpperCase();
                            final canCancel = ![
                              'CANCELLED',
                              'DELIVERED',
                              'COMPLETED',
                            ].contains(statusUpper);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: MyOrderCard(
                                id: 'Order ID: ${order.orderId}',
                                date: DateValidator.formatDate(
                                  order.orderConfirmedDate,
                                ),
                                status: order.status,
                                productName:
                                    cartDetail?.productName ?? 'Alkaline Water',
                                imageUrl: _pickFirstNonEmptyUrl([
                                  cartDetail?.productImages.signedUrl,
                                  cartDetail?.productImages.imageUrl,
                                ]),
                                detail:
                                    "Quantity: $qty\nSubtotal: ₹${total.toStringAsFixed(2)}",
                                paymentMethod: '',
                                invoiceUrl: order.invoice?.signedUrl,
                                invoiceNumber: order.invoice?.invoiceNumber,
                                onCancelTap: canCancel
                                    ? () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Cancel order?'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'This will cancel your order.',
                                                ),
                                                SizedBox(height: 10.h),
                                                Text(
                                                  'Note: Order cancellation is available only next day before 8 PM.',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed != true) return;
                                        if (!mounted) return;
                                        await this.context
                                            .read<MyOrderProvider>()
                                            .cancelOrder(
                                              this.context,
                                              orderId: order.orderId,
                                            );
                                      }
                                    : null,
                                footerNote:
                                    'Order cancellation is available only next day before 8 PM.',
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
