
class PharmacyModel {
  final String pharmacy_name;
  final String Pharmacy_Address;
  final String website_link;

  const PharmacyModel({
    required this.pharmacy_name,
    required this.Pharmacy_Address,
    required this.website_link,
  });

  //Creates PharmacyModel from JSON response
  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    try {
      return PharmacyModel(
        pharmacy_name: json['pharmacy_name'] as String? ?? '',
        Pharmacy_Address: json['Pharmacy_Address'] as String? ?? '',
        website_link: json['website_link'] as String? ?? '',
      );
    } catch (e) {
      print('Error parsing PharmacyModel: $e');
      return PharmacyModel.empty();
    }
  }

  // Converts PharmacyModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'pharmacy_name': pharmacy_name,
      'Pharmacy_Address': Pharmacy_Address,
      'website_link': website_link,
    };
  }

  // Creates empty PharmacyModel for fallback
  factory PharmacyModel.empty() {
    return const PharmacyModel(
      pharmacy_name: '',
      Pharmacy_Address: '',
      website_link: '',
    );
  }

  @override
  String toString() {
    return 'PharmacyModel(pharmacy_name: $pharmacy_name, Pharmacy_Address: $Pharmacy_Address, website_link: $website_link)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PharmacyModel &&
        other.pharmacy_name == pharmacy_name &&
        other.Pharmacy_Address == Pharmacy_Address &&
        other.website_link == website_link;
  }

  @override
  int get hashCode {
    return pharmacy_name.hashCode ^ Pharmacy_Address.hashCode ^ website_link.hashCode;
  }
}
