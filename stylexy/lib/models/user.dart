class AppUser {
  final String id;
  final String name;
  final String phone;
  final String? photoPath;
  final String role; // 'customer' or 'admin'
  final String referralCode;
  final bool hasUsedReferral;
  final String? appliedReferralCode;
  final String passwordHash;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.photoPath,
    this.role = 'customer',
    required this.referralCode,
    this.hasUsedReferral = false,
    this.appliedReferralCode,
    required this.passwordHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photoPath': photoPath,
      'role': role,
      'referralCode': referralCode,
      'hasUsedReferral': hasUsedReferral ? 1 : 0,
      'appliedReferralCode': appliedReferralCode,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      photoPath: map['photoPath'] as String?,
      role: map['role'] as String? ?? 'customer',
      referralCode: map['referralCode'] as String,
      hasUsedReferral: (map['hasUsedReferral'] as int? ?? 0) == 1,
      appliedReferralCode: map['appliedReferralCode'] as String?,
      passwordHash: map['passwordHash'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? photoPath,
    String? role,
    bool? hasUsedReferral,
    String? appliedReferralCode,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
      role: role ?? this.role,
      referralCode: referralCode,
      hasUsedReferral: hasUsedReferral ?? this.hasUsedReferral,
      appliedReferralCode: appliedReferralCode ?? this.appliedReferralCode,
      passwordHash: passwordHash,
      createdAt: createdAt,
    );
  }
}
