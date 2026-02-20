class PharmacyModel {
  final String pharmacy_name;
  final String Pharmacy_Address;
  final String website_link;

  const PharmacyModel({
    required this.pharmacy_name,
    required this.Pharmacy_Address,
    required this.website_link,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      pharmacy_name: json['pharmacy_name'] as String? ?? '',
      Pharmacy_Address: json['Pharmacy_Address'] as String? ?? '',
      website_link: json['website_link'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pharmacy_name': pharmacy_name,
      'Pharmacy_Address': Pharmacy_Address,
      'website_link': website_link,
    };
  }
}
