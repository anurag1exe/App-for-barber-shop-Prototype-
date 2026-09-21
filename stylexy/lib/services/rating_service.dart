import 'package:uuid/uuid.dart';
import '../models/rating.dart';
import 'database_service.dart';

class RatingService {
  static final RatingService instance = RatingService._();
  RatingService._();

  final _db = DatabaseService.instance;

  /// Submit a rating for a booking
  Future<({bool success, String message})> submitRating({
    required String bookingId,
    required String userId,
    required String userName,
    required String barberId,
    required String barberName,
    required String serviceId,
    required String serviceName,
    required double stars,
    String? comment,
  }) async {
    if (stars < 1 || stars > 5) {
      return (success: false, message: 'Rating must be between 1 and 5 stars');
    }

    // Check if already rated
    final existing = await _db.query(
      'ratings',
      where: 'bookingId = ?',
      whereArgs: [bookingId],
    );
    if (existing.isNotEmpty) {
      return (success: false, message: 'You have already rated this visit');
    }

    final rating = Rating(
      id: const Uuid().v4(),
      bookingId: bookingId,
      userId: userId,
      userName: userName,
      barberId: barberId,
      barberName: barberName,
      serviceId: serviceId,
      serviceName: serviceName,
      stars: stars,
      comment: comment?.trim().isNotEmpty == true ? comment!.trim() : null,
    );

    await _db.insert('ratings', rating.toMap());

    // Mark booking as rated
    await _db.update(
      'bookings',
      {'isRated': 1},
      where: 'id = ?',
      whereArgs: [bookingId],
    );

    return (success: true, message: 'Thank you for your rating!');
  }

  /// Get average rating for a barber
  Future<double> getBarberAverageRating(String barberId) async {
    final rows = await _db.rawQuery(
      'SELECT AVG(stars) as avg FROM ratings WHERE barberId = ?',
      [barberId],
    );
    return (rows.first['avg'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get full rating summary for a barber
  Future<BarberRatingSummary> getBarberRatingSummary(String barberId, String barberName) async {
    final avgRows = await _db.rawQuery(
      'SELECT AVG(stars) as avg, COUNT(*) as total FROM ratings WHERE barberId = ?',
      [barberId],
    );

    final starCountRows = await _db.rawQuery(
      'SELECT CAST(stars AS INTEGER) as star, COUNT(*) as cnt FROM ratings WHERE barberId = ? GROUP BY CAST(stars AS INTEGER)',
      [barberId],
    );

    final recentRows = await _db.query(
      'ratings',
      where: 'barberId = ?',
      whereArgs: [barberId],
      orderBy: 'createdAt DESC',
      limit: 10,
    );

    final starCounts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final row in starCountRows) {
      starCounts[row['star'] as int] = row['cnt'] as int;
    }

    return BarberRatingSummary(
      barberId: barberId,
      barberName: barberName,
      averageRating: (avgRows.first['avg'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (avgRows.first['total'] as int?) ?? 0,
      starCounts: starCounts,
      recentRatings: recentRows.map((r) => Rating.fromMap(r)).toList(),
    );
  }

  /// Get all barber rating summaries (admin)
  Future<List<BarberRatingSummary>> getAllBarberRatingSummaries() async {
    final summaries = <BarberRatingSummary>[];
    final barbers = [
      {'id': 'barber_1', 'name': 'Rahul'},
      {'id': 'barber_2', 'name': 'Vikram'},
      {'id': 'barber_3', 'name': 'Amit'},
    ];
    for (final barber in barbers) {
      summaries.add(await getBarberRatingSummary(barber['id']!, barber['name']!));
    }
    return summaries;
  }
}
