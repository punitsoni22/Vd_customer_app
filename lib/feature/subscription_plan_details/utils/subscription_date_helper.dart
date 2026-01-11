
class SubscriptionDateHelper {
  static DateTime? calculateEndDate(DateTime startDate, String subscriptionType) {
    final type = subscriptionType.toLowerCase();
    
    if (type.contains('week') || type.contains('7_days')) {
      // 7 days inclusive: start + 6 days
      return startDate.add(const Duration(days: 6));
    } else if (type.contains('one_month') || type.contains('1_month') || type == 'monthly') {
      // 30 days inclusive: start + 29 days
      return startDate.add(const Duration(days: 29));
    } else if (type.contains('three_month') || type.contains('3_month') || type == 'quarterly') {
      // 90 days inclusive: start + 89 days
      return startDate.add(const Duration(days: 89));
    } else if (type.contains('until') || type.contains('cancel')) {
      return null;
    }
    return null;
  }

  static bool isFixedDuration(String subscriptionType) {
    final type = subscriptionType.toLowerCase();
    return (type.contains('week') || type.contains('7_days')) ||
           (type.contains('one_month') || type.contains('1_month') || type == 'monthly') ||
           (type.contains('three_month') || type.contains('3_month') || type == 'quarterly');
  }
  
  static bool isUntilCancel(String subscriptionType) {
    final type = subscriptionType.toLowerCase();
    return type.contains('until') || type.contains('cancel');
  }

  static String? getHelpMessage(String subscriptionType) {
    final type = subscriptionType.toLowerCase();
    
    if (type.contains('week') || type.contains('7_days')) {
      return "Subscription duration: 7 Days (including start & end date)";
    } else if (type.contains('one_month') || type.contains('1_month') || type == 'monthly') {
      return "Subscription duration: 30 Days (including start & end date)";
    } else if (type.contains('three_month') || type.contains('3_month') || type == 'quarterly') {
      return "Subscription duration: 90 Days (including start & end date)";
    } else if (type.contains('until') || type.contains('cancel')) {
      return "This subscription continues until you manually cancel it";
    }
    return null;
  }
  
  static int? calculateDays(DateTime startDate, DateTime endDate) {
    // Add 1 to make it inclusive
    return endDate.difference(startDate).inDays + 1;
  }
}
