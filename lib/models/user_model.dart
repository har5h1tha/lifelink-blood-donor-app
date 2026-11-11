class UserModel {
  final String uid, name, email, bloodGroup, city, phone;
  final bool isAvailable;
  final DateTime? lastDonated;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.bloodGroup,
    required this.city,
    required this.phone,
    this.isAvailable = true,
    this.lastDonated,
  });

  // Safe to donate again 90 days after the last donation
  bool get canDonate =>
      lastDonated == null || DateTime.now().difference(lastDonated!).inDays >= 90;

  UserModel copyWith({
    String? name,
    String? bloodGroup,
    String? city,
    String? phone,
    bool? isAvailable,
    DateTime? lastDonated,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        name: name ?? this.name,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        city: city ?? this.city,
        phone: phone ?? this.phone,
        isAvailable: isAvailable ?? this.isAvailable,
        lastDonated: lastDonated ?? this.lastDonated,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'bloodGroup': bloodGroup,
        'city': city,
        'phone': phone,
        'isAvailable': isAvailable,
        'lastDonated': lastDonated?.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> m, String uid) => UserModel(
        uid: uid,
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        bloodGroup: m['bloodGroup'] ?? '',
        city: m['city'] ?? '',
        phone: m['phone'] ?? '',
        isAvailable: m['isAvailable'] ?? true,
        lastDonated:
            m['lastDonated'] != null ? DateTime.parse(m['lastDonated']) : null,
      );
}
