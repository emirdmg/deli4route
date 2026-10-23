class DeliveryStop {
  final String id;
  final int originalNumber;
  final String customerName;
  final String? phone;
  final String address;
  final String? note;
  final double? latitude;
  final double? longitude;
  final bool completed;

  const DeliveryStop({
    required this.id,
    required this.originalNumber,
    required this.customerName,
    required this.address,
    this.phone,
    this.note,
    this.latitude,
    this.longitude,
    this.completed = false,
  });

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      latitude!.abs() <= 90 &&
      longitude!.abs() <= 180;

  DeliveryStop copyWith({
    double? latitude,
    double? longitude,
    bool? completed,
  }) => DeliveryStop(
    id: id,
    originalNumber: originalNumber,
    customerName: customerName,
    address: address,
    phone: phone,
    note: note,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalNumber': originalNumber,
    'customerName': customerName,
    'address': address,
    'phone': phone,
    'note': note,
    'latitude': latitude,
    'longitude': longitude,
    'completed': completed,
  };

  factory DeliveryStop.fromJson(Map<String, dynamic> json) => DeliveryStop(
    id: json['id'] as String,
    originalNumber: json['originalNumber'] as int,
    customerName: json['customerName'] as String,
    address: json['address'] as String,
    phone: json['phone'] as String?,
    note: json['note'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    completed: json['completed'] as bool? ?? false,
  );
}
