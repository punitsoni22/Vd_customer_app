import 'package:flutter_test/flutter_test.dart';
import 'package:vd_customer_app/core/utils/validators/date_validator.dart';

void main() {
  group('DateValidator Tests', () {
    test('Empty date returns error', () {
      expect(DateValidator.validateDate(''), 'Date is required');
      expect(DateValidator.validateDate(null), 'Date is required');
    });

    test('Invalid format returns error', () {
      expect(DateValidator.validateDate('2024-02-29'), 'Enter date in DD/MM/YYYY format');
      expect(DateValidator.validateDate('29-02-2024'), 'Enter date in DD/MM/YYYY format');
      expect(DateValidator.validateDate('2/2/2024'), 'Enter date in DD/MM/YYYY format'); // needs leading zeros
    });

    test('Valid leap year date returns null', () {
      expect(DateValidator.validateDate('29/02/2024'), null);
    });

    test('Invalid leap year date returns error', () {
      expect(DateValidator.validateDate('29/02/2023'), 'Enter a valid day for the selected month');
    });

    test('Invalid month returns error', () {
      expect(DateValidator.validateDate('15/13/2024'), 'Month must be between 01 and 12');
      expect(DateValidator.validateDate('15/00/2024'), 'Month must be between 01 and 12');
    });

    test('Invalid day returns error', () {
      expect(DateValidator.validateDate('32/01/2024'), 'Enter a valid day for the selected month');
      expect(DateValidator.validateDate('00/01/2024'), 'Enter a valid day for the selected month');
    });

    test('Invalid day for specific month (April) returns error', () {
      expect(DateValidator.validateDate('31/04/2024'), 'Enter a valid day for the selected month');
    });

    test('Valid day for specific month (April) returns null', () {
      expect(DateValidator.validateDate('30/04/2024'), null);
    });

    test('Year out of range returns error', () {
      expect(DateValidator.validateDate('01/01/1899'), 'Enter a valid year between 1900 and 2100');
      expect(DateValidator.validateDate('01/01/2101'), 'Enter a valid year between 1900 and 2100');
    });
  });

  group('DateFormatter Tests', () {
    test('formatDate returns empty string for null/empty input', () {
      expect(DateValidator.formatDate(null), '');
      expect(DateValidator.formatDate(''), '');
    });

    test('formatDate formats ISO string correctly', () {
      expect(DateValidator.formatDate('2024-02-27T13:27:00.000'), '27/02/2024');
    });

    test('formatDate formats YYYY-MM-DD string correctly', () {
      expect(DateValidator.formatDate('2024-02-27'), '27/02/2024');
    });

    test('formatDate returns original string if parsing fails', () {
      expect(DateValidator.formatDate('invalid-date'), 'invalid-date');
    });

    test('formatDate pads day and month with zeros', () {
      expect(DateValidator.formatDate('2024-01-05'), '05/01/2024');
    });
  });
}
