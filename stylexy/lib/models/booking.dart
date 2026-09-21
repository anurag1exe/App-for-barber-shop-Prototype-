enum BookingStatus {
  confirmed,
  completed,
  cancelled,
}

class Barber {
  final String id;
  final String name;
  final String? photoPath;

  const Barber({
    required this.id,
    required this.name,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'photoPath': photoPath};
  }

  factory Barber.fromMap(Map<String, dynamic> map) {
    return Barber(
      id: map['id'] as String,
      name: map['name'] as String,
      photoPath: map['photoPath'] as String?,
    );
  }

  static const List<Barber> defaultBarbers = [
    Barber(id: 'barber_1', name: 'Rahul'),
    Barber(id: 'barber_2', name: 'Vikram'),
    Barber(id: 'barber_3', name: 'Amit'),
  ];
}

class TimeSlot {
  final String id;
  final DateTime date;
  final String startTime; // "10:00"
  final String endTime;   // "10:30"
  final String barberId;
  final String barberName;
  final bool isBooked;
  final String? bookedByUserId;
  final String? bookingId;

  TimeSlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.barberId,
    required this.barberName,
    this.isBooked = false,
    this.bookedByUserId,
    this.bookingId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'barberId': barberId,
      'barberName': barberName,
      'isBooked': isBooked ? 1 : 0,
      'bookedByUserId': bookedByUserId,
      'bookingId': bookingId,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      barberId: map['barberId'] as String,
      barberName: map['barberName'] as String,
      isBooked: (map['isBooked'] as int? ?? 0) == 1,
      bookedByUserId: map['bookedByUserId'] as String?,
      bookingId: map['bookingId'] as String?,
    );
  }

  String get displayTime => '$startTime – $endTime';
}

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String barberId;
  final String barberName;
  final String slotId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final BookingStatus status;
  final bool isRated;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.barberId,
    required this.barberName,
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = BookingStatus.confirmed,
    this.isRated = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'barberId': barberId,
      'barberName': barberName,
      'slotId': slotId,
      'date': date.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'status': status.name,
      'isRated': isRated ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      serviceId: map['serviceId'] as String,
      serviceName: map['serviceName'] as String,
      servicePrice: (map['servicePrice'] as num).toDouble(),
      barberId: map['barberId'] as String,
      barberName: map['barberName'] as String,
      slotId: map['slotId'] as String,
      date: DateTime.parse(map['date'] as String),
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      isRated: (map['isRated'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Booking copyWith({BookingStatus? status, bool? isRated}) {
    return Booking(
      id: id,
      userId: userId,
      userName: userName,
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      barberId: barberId,
      barberName: barberName,
      slotId: slotId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      isRated: isRated ?? this.isRated,
      createdAt: createdAt,
    );
  }
}
