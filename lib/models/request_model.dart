class RequestModel {
  final String id, patientName, bloodGroup, hospital, city, urgency, contactPhone;
  final String status; // 'open' or 'fulfilled'
  final String createdBy; // uid of the user who posted it
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.patientName,
    required this.bloodGroup,
    required this.hospital,
    required this.city,
    required this.urgency,
    required this.contactPhone,
    this.status = 'open',
    required this.createdBy,
    required this.createdAt,
  });

  RequestModel copyWith({String? status}) => RequestModel(
        id: id,
        patientName: patientName,
        bloodGroup: bloodGroup,
        hospital: hospital,
        city: city,
        urgency: urgency,
        contactPhone: contactPhone,
        status: status ?? this.status,
        createdBy: createdBy,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'patientName': patientName,
        'bloodGroup': bloodGroup,
        'hospital': hospital,
        'city': city,
        'urgency': urgency,
        'contactPhone': contactPhone,
        'status': status,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RequestModel.fromMap(Map<String, dynamic> m, String id) => RequestModel(
        id: id,
        patientName: m['patientName'] ?? '',
        bloodGroup: m['bloodGroup'] ?? '',
        hospital: m['hospital'] ?? '',
        city: m['city'] ?? '',
        urgency: m['urgency'] ?? 'Normal',
        contactPhone: m['contactPhone'] ?? '',
        status: m['status'] ?? 'open',
        createdBy: m['createdBy'] ?? '',
        createdAt: DateTime.parse(m['createdAt']),
      );
}
