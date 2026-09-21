import 'package:flutter_test/flutter_test.dart';
import 'package:stylexy/models/wallet.dart';
import 'package:stylexy/models/service.dart';
import 'package:stylexy/models/booking.dart';
import 'package:stylexy/models/user.dart';
import 'package:stylexy/models/rating.dart';

void main() {
  group('WalletTransaction', () {
    test('fromMap and toMap roundtrip', () {
      final txn = WalletTransaction(
        id: 'test-1',
        userId: 'user-1',
        type: TransactionType.recharge,
        amount: 200,
        description: 'Test recharge',
      );

      final map = txn.toMap();
      final restored = WalletTransaction.fromMap(map);

      expect(restored.id, txn.id);
      expect(restored.userId, txn.userId);
      expect(restored.type, TransactionType.recharge);
      expect(restored.amount, 200);
      expect(restored.isCredit, true);
    });

    test('service deduction is not a credit', () {
      final txn = WalletTransaction(
        id: 'test-2',
        userId: 'user-1',
        type: TransactionType.serviceDeduction,
        amount: 100,
        description: 'Haircut payment',
      );

      expect(txn.isCredit, false);
      expect(txn.typeDisplay, 'Service Payment');
    });

    test('bonus is a credit', () {
      final txn = WalletTransaction(
        id: 'test-3',
        userId: 'user-1',
        type: TransactionType.bonus,
        amount: 50,
        description: 'Bonus',
      );

      expect(txn.isCredit, true);
      expect(txn.typeDisplay, 'Bonus');
    });

    test('referral credit is a credit', () {
      final txn = WalletTransaction(
        id: 'test-4',
        userId: 'user-1',
        type: TransactionType.referralCredit,
        amount: 100,
        description: 'Referral',
      );

      expect(txn.isCredit, true);
      expect(txn.typeDisplay, 'Referral Credit');
    });
  });

  group('BarberService', () {
    test('allServices has correct count', () {
      expect(BarberService.allServices.length, 3);
    });

    test('haircut price is 100', () {
      final haircut = BarberService.allServices.firstWhere((s) => s.id == 'haircut');
      expect(haircut.price, 100);
      expect(haircut.priceDisplay, '₹100');
    });

    test('beard trim price is 70', () {
      final beard = BarberService.allServices.firstWhere((s) => s.id == 'beard_trim');
      expect(beard.price, 70);
    });

    test('massage facial combo price is 199', () {
      final combo = BarberService.allServices.firstWhere((s) => s.id == 'massage_facial');
      expect(combo.price, 199);
    });
  });

  group('AppUser', () {
    test('fromMap and toMap roundtrip', () {
      final user = AppUser(
        id: 'user-1',
        name: 'Test User',
        phone: '9876543210',
        referralCode: 'TEST1234',
        passwordHash: 'hash123',
      );

      final map = user.toMap();
      final restored = AppUser.fromMap(map);

      expect(restored.id, user.id);
      expect(restored.name, 'Test User');
      expect(restored.phone, '9876543210');
      expect(restored.referralCode, 'TEST1234');
      expect(restored.isAdmin, false);
      expect(restored.hasUsedReferral, false);
    });

    test('admin user has isAdmin true', () {
      final admin = AppUser(
        id: 'admin-1',
        name: 'Admin',
        phone: '9999999999',
        role: 'admin',
        referralCode: 'ADMIN000',
        passwordHash: 'hash123',
      );

      expect(admin.isAdmin, true);
    });

    test('copyWith preserves unchanged fields', () {
      final user = AppUser(
        id: 'user-1',
        name: 'Original',
        phone: '9876543210',
        referralCode: 'CODE1234',
        passwordHash: 'hash',
      );

      final updated = user.copyWith(name: 'Updated');
      expect(updated.name, 'Updated');
      expect(updated.phone, '9876543210');
      expect(updated.id, 'user-1');
      expect(updated.referralCode, 'CODE1234');
    });
  });

  group('Booking', () {
    test('fromMap and toMap roundtrip', () {
      final booking = Booking(
        id: 'booking-1',
        userId: 'user-1',
        userName: 'Test',
        serviceId: 'haircut',
        serviceName: 'Haircut',
        servicePrice: 100,
        barberId: 'barber_1',
        barberName: 'Rahul',
        slotId: 'slot-1',
        date: DateTime(2026, 9, 12),
        startTime: '10:00',
        endTime: '10:30',
      );

      final map = booking.toMap();
      final restored = Booking.fromMap(map);

      expect(restored.id, 'booking-1');
      expect(restored.serviceName, 'Haircut');
      expect(restored.servicePrice, 100);
      expect(restored.barberName, 'Rahul');
      expect(restored.status, BookingStatus.confirmed);
      expect(restored.isRated, false);
    });

    test('copyWith updates status', () {
      final booking = Booking(
        id: 'b1',
        userId: 'u1',
        userName: 'T',
        serviceId: 'haircut',
        serviceName: 'Haircut',
        servicePrice: 100,
        barberId: 'b1',
        barberName: 'R',
        slotId: 's1',
        date: DateTime(2026, 9, 12),
        startTime: '10:00',
        endTime: '10:30',
      );

      final completed = booking.copyWith(status: BookingStatus.completed, isRated: true);
      expect(completed.status, BookingStatus.completed);
      expect(completed.isRated, true);
    });
  });

  group('TimeSlot', () {
    test('displayTime format', () {
      final slot = TimeSlot(
        id: 'slot-1',
        date: DateTime(2026, 9, 12),
        startTime: '10:00',
        endTime: '10:30',
        barberId: 'barber_1',
        barberName: 'Rahul',
      );

      expect(slot.displayTime, '10:00 – 10:30');
      expect(slot.isBooked, false);
    });
  });

  group('Rating', () {
    test('fromMap and toMap roundtrip', () {
      final rating = Rating(
        id: 'r1',
        bookingId: 'b1',
        userId: 'u1',
        userName: 'Test',
        barberId: 'barber_1',
        barberName: 'Rahul',
        serviceId: 'haircut',
        serviceName: 'Haircut',
        stars: 4.0,
        comment: 'Great haircut!',
      );

      final map = rating.toMap();
      final restored = Rating.fromMap(map);

      expect(restored.stars, 4.0);
      expect(restored.comment, 'Great haircut!');
      expect(restored.barberName, 'Rahul');
    });
  });

  group('Barber', () {
    test('defaultBarbers has 3 barbers', () {
      expect(Barber.defaultBarbers.length, 3);
    });
  });
}
