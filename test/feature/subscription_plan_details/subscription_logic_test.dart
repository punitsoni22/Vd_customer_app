import 'package:flutter_test/flutter_test.dart';
import 'package:vd_customer_app/feature/subscription_plan_details/utils/subscription_date_helper.dart';

void main() {
  group('SubscriptionDateHelper Tests', () {
    final startDate = DateTime(2023, 1, 1); // Jan 1, 2023

    test('1-week subscription adds 6 days (7 days inclusive)', () {
      final endDate = SubscriptionDateHelper.calculateEndDate(startDate, 'one_week');
      // Jan 1 + 6 days = Jan 7.
      // Days: 1, 2, 3, 4, 5, 6, 7 = 7 days.
      expect(endDate, DateTime(2023, 1, 7));
      expect(SubscriptionDateHelper.isFixedDuration('one_week'), true);
      expect(SubscriptionDateHelper.calculateDays(startDate, endDate!), 7);
    });

    test('1-month subscription adds 29 days (30 days inclusive)', () {
      final endDate = SubscriptionDateHelper.calculateEndDate(startDate, 'one_month');
      // Jan 1 + 29 days = Jan 30.
      expect(endDate, startDate.add(const Duration(days: 29)));
      expect(SubscriptionDateHelper.isFixedDuration('one_month'), true);
      expect(SubscriptionDateHelper.calculateDays(startDate, endDate!), 30);
    });

    test('3-months subscription adds 89 days (90 days inclusive)', () {
      // Test plural form
      var endDate = SubscriptionDateHelper.calculateEndDate(startDate, 'three_months');
      expect(endDate, startDate.add(const Duration(days: 89)));
      expect(SubscriptionDateHelper.isFixedDuration('three_months'), true);
      expect(SubscriptionDateHelper.calculateDays(startDate, endDate!), 90);
      
      // Test singular form
      endDate = SubscriptionDateHelper.calculateEndDate(startDate, 'three_month');
      expect(endDate, startDate.add(const Duration(days: 89)));
      expect(SubscriptionDateHelper.isFixedDuration('three_month'), true);

      // Test numeric form
      endDate = SubscriptionDateHelper.calculateEndDate(startDate, '3_months');
      expect(endDate, startDate.add(const Duration(days: 89)));
      
      // Test numeric singular form
      endDate = SubscriptionDateHelper.calculateEndDate(startDate, '3_month');
      expect(endDate, startDate.add(const Duration(days: 89)));
    });

    test('Until cancel returns null end date', () {
      final endDate = SubscriptionDateHelper.calculateEndDate(startDate, 'until_cancel');
      expect(endDate, null);
      expect(SubscriptionDateHelper.isUntilCancel('until_cancel'), true);
      expect(SubscriptionDateHelper.isFixedDuration('until_cancel'), false);
    });
    
    test('Leap year handling', () {
      final leapStart = DateTime(2024, 2, 28);
      // 1 week from Feb 28, 2024 should be March 5 (inclusive)
      // 28, 29, 1, 2, 3, 4, 5
      final endDate = SubscriptionDateHelper.calculateEndDate(leapStart, 'one_week');
      expect(endDate, DateTime(2024, 3, 5));
    });

    test('Help messages are correct', () {
      expect(
        SubscriptionDateHelper.getHelpMessage('one_week'),
        contains("7 Days"),
      );
      expect(
        SubscriptionDateHelper.getHelpMessage('until_cancel'),
        contains("until you manually cancel it"),
      );
    });
  });
}
