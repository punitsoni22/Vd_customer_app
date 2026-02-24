class DateValidator {
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    // Regex for DD/MM/YYYY format
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(value)) {
      return 'Enter date in DD/MM/YYYY format';
    }

    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (year < 1900 || year > 2100) {
        return 'Enter a valid year between 1900 and 2100';
      }

      if (month < 1 || month > 12) {
        return 'Month must be between 01 and 12';
      }

      final daysInMonth = _getDaysInMonth(month, year);
      if (day < 1 || day > daysInMonth) {
        return 'Enter a valid day for the selected month';
      }

      return null; // Valid date
    } catch (e) {
      return 'Invalid date format';
    }
  }

  static int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29; // Leap year
      }
      return 28; // Non-leap year
    }
    if ([4, 6, 9, 11].contains(month)) {
      return 30;
    }
    return 31;
  }

  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      DateTime parsedDate;
      if (dateString.contains('T')) {
        parsedDate = DateTime.parse(dateString);
      } else {
        // Handle potential YYYY-MM-DD format directly if not ISO
        try {
          parsedDate = DateTime.parse(dateString);
        } catch (_) {
          // If parse fails, return original
          return dateString;
        }
      }
      
      final day = parsedDate.day.toString().padLeft(2, '0');
      final month = parsedDate.month.toString().padLeft(2, '0');
      final year = parsedDate.year;
      
      return '$day/$month/$year';
    } catch (e) {
      return dateString;
    }
  }
}
