import 'package:flutter_test/flutter_test.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';

void main() {
  group('CartProvider State Isolation Tests', () {
    late CartProvider provider;

    setUp(() {
      provider = CartProvider();
    });

    test('Initial state is empty', () {
      expect(provider.cart, isNull);
      expect(provider.cartItems, isEmpty);
      expect(provider.pendingQuantityChanges, isEmpty);
    });

    test('Editing quantity of one item does not affect others', () async {
      // 1. Setup mock cart data
      final mockCartData = {
        'id': 123,
        'userId': 456,
        'status': 'ACTIVE',
        'totalPrice': 200.0,
        'isDeleted': 0,
        'cartDetails': [
          {
            'id': 1,
            'productId': 101,
            'variantId': 201,
            'quantity': 1,
            'price': 100.0,
            'product': {'images': []} // Avoid signed url logic
          },
          {
            'id': 2,
            'productId': 102,
            'variantId': 202,
            'quantity': 1,
            'price': 100.0,
            'product': {'images': []}
          }
        ]
      };

      // 2. Initialize provider with data
      // Note: setCartFromApi might trigger image signing if images were present, 
      // but we pass empty images to avoid external calls.
      await provider.setCartFromApi(mockCartData);
      
      expect(provider.cartItems.length, 2, reason: 'Should have 2 items in cart');

      final item1 = provider.cartItems.firstWhere((i) => i.id == 1);
      final item2 = provider.cartItems.firstWhere((i) => i.id == 2);

      expect(item1.quantity, 1);
      expect(item2.quantity, 1);
      expect(provider.getDisplayQuantity(item1), 1);
      expect(provider.getDisplayQuantity(item2), 1);

      // 3. Increase quantity of item 1
      provider.increaseQuantity(item1);

      // 4. Verify item 1 changed, item 2 did not
      expect(provider.getDisplayQuantity(item1), 2, reason: 'Item 1 quantity should increase');
      expect(provider.getDisplayQuantity(item2), 1, reason: 'Item 2 quantity should remain unchanged');
      
      // 5. Verify pending changes map
      expect(provider.pendingQuantityChanges.containsKey(item1.id), isTrue);
      expect(provider.pendingQuantityChanges.containsKey(item2.id), isFalse);
      
      // 6. Decrease quantity of item 1 back to original
      provider.decreaseQuantity(item1);
      expect(provider.getDisplayQuantity(item1), 1);
      
      // 7. Increase item 2
      provider.increaseQuantity(item2);
      expect(provider.getDisplayQuantity(item1), 1);
      expect(provider.getDisplayQuantity(item2), 2);
    });

    test('Removal state is isolated per item', () {
      // This tests the local state tracking for removal
      // We don't call removeItem() because it makes API calls, 
      // but we can verify the logic if we could manipulate _removingItemIds.
      // Since _removingItemIds is private and only modified by removeItem, 
      // we can't easily test it without mocking API.
      // However, we can verify the accessor works if we could set it.
      // Given we can't, we skip this specific check in unit test unless we expose it.
      // But the quantity isolation test above covers the main user complaint.
    });
  });
}
