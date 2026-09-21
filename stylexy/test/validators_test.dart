import 'package:flutter_test/flutter_test.dart';
import 'package:stylexy/utils/validators.dart';

void main() {
  group('Validators.phone', () {
    test('valid phone passes', () {
      expect(Validators.phone('9876543210'), isNull);
      expect(Validators.phone('6123456789'), isNull);
    });

    test('empty phone fails', () {
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone(null), isNotNull);
    });

    test('short phone fails', () {
      expect(Validators.phone('987654'), isNotNull);
    });

    test('invalid starting digit fails', () {
      expect(Validators.phone('1234567890'), isNotNull);
      expect(Validators.phone('5234567890'), isNotNull);
    });
  });

  group('Validators.name', () {
    test('valid name passes', () {
      expect(Validators.name('Rahul'), isNull);
      expect(Validators.name('Rahul Kumar'), isNull);
    });

    test('empty name fails', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name(null), isNotNull);
    });

    test('single char fails', () {
      expect(Validators.name('A'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('valid password passes', () {
      expect(Validators.password('abc123'), isNull);
      expect(Validators.password('strongpassword'), isNull);
    });

    test('short password fails', () {
      expect(Validators.password('abc'), isNotNull);
    });

    test('empty password fails', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password(null), isNotNull);
    });
  });

  group('Validators.amount', () {
    test('valid amount passes', () {
      expect(Validators.amount('100'), isNull);
      expect(Validators.amount('200'), isNull);
      expect(Validators.amount('50000'), isNull);
    });

    test('zero amount fails', () {
      expect(Validators.amount('0'), isNotNull);
    });

    test('negative amount fails', () {
      expect(Validators.amount('-50'), isNotNull);
    });

    test('too large amount fails', () {
      expect(Validators.amount('60000'), isNotNull);
    });

    test('non-numeric fails', () {
      expect(Validators.amount('abc'), isNotNull);
    });
  });

  group('Validators.referralCode', () {
    test('valid code passes', () {
      expect(Validators.referralCode('ABCD1234'), isNull);
    });

    test('short code fails', () {
      expect(Validators.referralCode('AB'), isNotNull);
    });

    test('empty code fails', () {
      expect(Validators.referralCode(''), isNotNull);
      expect(Validators.referralCode(null), isNotNull);
    });
  });
}
