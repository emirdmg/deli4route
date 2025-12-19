class DeliveryStop {
  final String customerName;
  final String? phone;
  final String address;
  final String? note;

  DeliveryStop({
    required this.customerName,
    required this.address,
    this.phone,
    this.note,
  });

  @override
  String toString() {
    return 'DeliveryStop(customerName: $customerName, address: $address)';
  }
}