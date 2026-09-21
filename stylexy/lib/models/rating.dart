class Rating {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String barberId;
  final String barberName;
  final String serviceId;
  final String serviceName;
  final double stars;
  final String? comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.barberId,
    required this.barberName,
    required this.serviceId,
    required this.serviceName,
    required this.stars,
    this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'barberId': barberId,
      'barberName': barberName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'stars': stars,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] as String,
      bookingId: map['bookingId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      barberId: map['barberId'] as String,
      barberName: map['barberName'] as String,
      serviceId: map['serviceId'] as String,
      serviceName: map['serviceName'] as String,
      stars: (map['stars'] as num).toDouble(),
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class BarberRatingSummary {
  final String barberId;
  final String barberName;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> starCounts; // {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}
  final List<Rating> recentRatings;

  BarberRatingSummary({
    required this.barberId,
    required this.barberName,
    required this.averageRating,
    required this.totalRatings,
    required this.starCounts,
    required this.recentRatings,
  });
}
