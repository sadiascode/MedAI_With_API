class MedicineModel {
  final int id;
  final String name;
  final int howManyDay;
  final int stock;
  final int prescriptionId;
  final int quantity;

  const MedicineModel({
    required this.id,
    required this.name,
    required this.howManyDay,
    required this.stock,
    required this.prescriptionId,
    required this.quantity,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    try {
      return MedicineModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        howManyDay: json['how_many_day'] as int? ?? 0,
        stock: json['stock'] as int? ?? 0,
        prescriptionId: json['prescription_id'] as int? ?? 0,
        quantity: json['quantity'] as int? ?? 0,
      );
    } catch (e) {
      print('Error parsing MedicineModel: $e');
      return MedicineModel.empty();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'how_many_day': howManyDay,
      'stock': stock,
      'prescription_id': prescriptionId,
      'quantity': quantity,
    };
  }

  factory MedicineModel.empty() {
    return const MedicineModel(
      id: 0,
      name: '',
      howManyDay: 0,
      stock: 0,
      prescriptionId: 0,
      quantity: 0,
    );
  }

  @override
  String toString() {
    return 'MedicineModel(id: $id, name: $name, howManyDay: $howManyDay, stock: $stock, prescriptionId: $prescriptionId, quantity: $quantity)';
  }
}
