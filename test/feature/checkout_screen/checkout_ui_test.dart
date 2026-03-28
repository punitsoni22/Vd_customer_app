import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/checkout_screen/checkout_screen.dart';
import 'package:vd_customer_app/feature/checkout_screen/provider/checkout_provider.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/provider/subscription_provider.dart';

import 'package:vd_customer_app/core/models/address.model.dart';

// Mock Providers
class MockCheckoutProvider extends ChangeNotifier implements CheckoutProvider {
  @override
  int get currentStep => 1;
  @override
  bool get isLoading => false;
  @override
  List<AddressModel> get addresses => []; // Mock address list if needed
  
  @override
  AddressModel? get selectedAddress => null;

  @override
  double get couponDiscount => 0.0;

  @override
  double? get lastOrderTotalAmount => null;

  @override
  double? get lastOrderDiscountAmount => null;

  @override
  bool get isCheckingDelivery => false;

  @override
  List<Map<String, dynamic>> get coupons => [];

  @override
  Future<void> fetchAddresses() async {}
  
  @override
  Future<void> fetchCoupons(double subtotal) async {}

  @override
  void setStep(int step) {}

  @override
  void startOnlinePayment({
    required Map<String, dynamic> paymentData,
    required Map<String, dynamic> orderData,
    required CartProvider cartProvider,
    required BuildContext context,
  }) {}
  
  // Add other required overrides with dummy implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  double get subtotal => 100.0;
  @override
  Future<void> fetchLatestCart(BuildContext context) async {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSubscriptionProvider extends ChangeNotifier implements SubscriptionProvider {
    @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('CheckoutScreen builds correctly', (WidgetTester tester) async {
    // Wrap in ScreenUtilInit and MultiProvider
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CheckoutProvider>(create: (_) => MockCheckoutProvider()),
          ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
          ChangeNotifierProvider<SubscriptionProvider>(create: (_) => MockSubscriptionProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: CheckoutScreen(),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();

    // Verify basic structure
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Step 1 of 2'), findsOneWidget);
  });
}
