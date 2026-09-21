import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import 'database_service.dart';
import 'wallet_service.dart';

class BookingService {
  static final BookingService instance = BookingService._();
  BookingService._();

  final _db = DatabaseService.instance;
  final _wallet = WalletService.instance;

  /// Generate time slots for a date (9 AM to 8 PM, 30-min intervals)
  Future<List<TimeSlot>> getSlotsForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];

    // Check if slots already exist for this date
    final existing = await _db.query(
      'time_slots',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (existing.isNotEmpty) {
      return existing.map((r) => TimeSlot.fromMap(r)).toList();
    }

    // Generate slots for all barbers
    final barbers = Barber.defaultBarbers;
    final slots = <TimeSlot>[];

    for (final barber in barbers) {
      for (int hour = 9; hour < 20; hour++) {
        for (int min = 0; min < 60; min += 30) {
          final startH = hour.toString().padLeft(2, '0');
          final startM = min.toString().padLeft(2, '0');
          final endMin = (min + 30) % 60;
          final endH = (min + 30 >= 60 ? hour + 1 : hour).toString().padLeft(2, '0');
          final endM = endMin.toString().padLeft(2, '0');

          final slot = TimeSlot(
            id: const Uuid().v4(),
            date: date,
            startTime: '$startH:$startM',
            endTime: '$endH:$endM',
            barberId: barber.id,
            barberName: barber.name,
          );
          slots.add(slot);
          await _db.insert('time_slots', slot.toMap());
        }
      }
    }

    return slots;
  }

  /// Get available (unbooked) slots for a date
  Future<List<TimeSlot>> getAvailableSlots(DateTime date) async {
    final all = await getSlotsForDate(date);
    return all.where((s) => !s.isBooked).toList();
  }

  /// Book a slot and pay via wallet
  Future<({bool success, String message})> bookSlot({
    required String userId,
    required String userName,
    required String serviceId,
    required String serviceName,
    required double servicePrice,
    required TimeSlot slot,
  }) async {
    // Double check slot is still available
    final slotRows = await _db.query(
      'time_slots',
      where: 'id = ? AND isBooked = 0',
      whereArgs: [slot.id],
    );
    if (slotRows.isEmpty) {
      return (success: false, message: 'This slot is no longer available. Please choose another.');
    }

    // Deduct from wallet
    final walletResult = await _wallet.deductForService(userId, servicePrice, serviceName);
    if (!walletResult.success) {
      return (success: false, message: walletResult.message);
    }

    // Create booking
    final bookingId = const Uuid().v4();
    final booking = Booking(
      id: bookingId,
      userId: userId,
      userName: userName,
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      barberId: slot.barberId,
      barberName: slot.barberName,
      slotId: slot.id,
      date: slot.date,
      startTime: slot.startTime,
      endTime: slot.endTime,
    );
    await _db.insert('bookings', booking.toMap());

    // Mark slot as booked
    await _db.update(
      'time_slots',
      {'isBooked': 1, 'bookedByUserId': userId, 'bookingId': bookingId},
      where: 'id = ?',
      whereArgs: [slot.id],
    );

    return (
      success: true,
      message: 'Booking confirmed! $serviceName with ${slot.barberName} at ${slot.startTime}',
    );
  }

  /// Get bookings for a user
  Future<List<Booking>> getUserBookings(String userId) async {
    final rows = await _db.query(
      'bookings',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, startTime DESC',
    );
    return rows.map((r) => Booking.fromMap(r)).toList();
  }

  /// Get all bookings (admin)
  Future<List<Booking>> getAllBookings() async {
    final rows = await _db.query('bookings', orderBy: 'date DESC, startTime DESC');
    return rows.map((r) => Booking.fromMap(r)).toList();
  }

  /// Mark booking as completed
  Future<void> completeBooking(String bookingId) async {
    await _db.update(
      'bookings',
      {'status': BookingStatus.completed.name},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  /// Get barber service counts for today
  Future<List<Map<String, dynamic>>> getBarberLeaderboard({required bool today}) async {
    final dateFilter = today
        ? "AND date(b.date) = date('now')"
        : "AND date(b.date) >= date('now', 'start of month')";

    return await _db.rawQuery('''
      SELECT b.barberId, b.barberName, COUNT(*) as serviceCount,
             SUM(b.servicePrice) as totalEarnings
      FROM bookings b
      WHERE b.status IN ('confirmed', 'completed') $dateFilter
      GROUP BY b.barberId, b.barberName
      ORDER BY serviceCount DESC
    ''');
  }

  /// Get all customers with visit stats (admin)
  Future<List<Map<String, dynamic>>> getCustomerStats() async {
    return await _db.rawQuery('''
      SELECT u.id, u.name, u.phone, u.createdAt,
             COUNT(b.id) as totalVisits,
             MIN(b.date) as firstVisit,
             MAX(b.date) as lastVisit
      FROM users u
      LEFT JOIN bookings b ON u.id = b.userId AND b.status IN ('confirmed', 'completed')
      WHERE u.role = 'customer'
      GROUP BY u.id, u.name, u.phone, u.createdAt
      ORDER BY totalVisits DESC
    ''');
  }
}
