import 'package:care_agent/common/custom_button.dart';
import 'package:care_agent/features/medicine/screen/medicine_screen.dart';
import 'package:care_agent/features/medicine/widget/custom_checkout.dart';
import 'package:care_agent/features/medicine/widget/custom_pharmacy.dart';
import 'package:care_agent/features/medicine/models/medicine_model.dart';
import 'package:care_agent/features/pharmacy/models/pharmacy_model.dart';
import 'package:care_agent/features/pharmacy/services/pharmacy_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/app_shell.dart';
import '../../profile/widget/custom_edit.dart';

class CheckoutScreen extends StatefulWidget {
  final MedicineModel medicine;

  const CheckoutScreen({
    super.key,
    required this.medicine,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int selectedPharmacyIndex = 0;
  List<PharmacyModel> pharmacies = [];
  bool isLoading = true;
  int selectedQuantity = 0;

  // Text controllers for add pharmacy dialog
  final _pharmacyNameController = TextEditingController();
  final _pharmacyAddressController = TextEditingController();
  final _websiteUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedQuantity = widget.medicine.quantity;
    _fetchPharmacies();
  }

  @override
  void dispose() {
    _pharmacyNameController.dispose();
    _pharmacyAddressController.dispose();
    _websiteUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchPharmacies() async {
    try {
      final pharmacyData = await PharmacyService.fetchPharmacies();
      setState(() {
        pharmacies = pharmacyData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Adds a new pharmacy and refreshes the list
  Future<void> _addPharmacy() async {
    try {
      final pharmacyName = _pharmacyNameController.text.trim();
      final pharmacyAddress = _pharmacyAddressController.text.trim();
      final websiteUrl = _websiteUrlController.text.trim();

      if (pharmacyName.isEmpty || pharmacyAddress.isEmpty || websiteUrl.isEmpty) {
        _showErrorSnackBar('Please fill in all fields');
        return;
      }

      // Show loading indicator
      _showLoadingSnackBar();

      await PharmacyService.addPharmacy(
        pharmacyName: pharmacyName,
        pharmacyAddress: pharmacyAddress,
        websiteUrl: websiteUrl,
      );

      // Clear controllers
      _pharmacyNameController.clear();
      _pharmacyAddressController.clear();
      _websiteUrlController.clear();

      // Close dialog
      Navigator.of(context).pop();

      // Refresh pharmacy list
      await _fetchPharmacies();

      // Show success message
      _showSuccessSnackBar('Pharmacy added successfully');
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLoadingSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 16),
            Text('Adding pharmacy...'),
          ],
        ),
        backgroundColor: Color(0xffE0712D),
        duration: Duration(seconds: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      parentTabIndex: 1,
      backgroundColor: Color(0xFFFFFAF7),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: ( Icon(Icons.arrow_back_ios, color: Color(0xffE0712D), size: 18))),
        title:  Text(
          "Checkout",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            children: [
              SizedBox(height: 20),
              CustomCheckout(medicine: widget.medicine),

              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xffFFF0E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pharmacies.isNotEmpty 
                            ? pharmacies[selectedPharmacyIndex].Pharmacy_Address.isNotEmpty
                                ? pharmacies[selectedPharmacyIndex].Pharmacy_Address
                                : 'NO Address Found'
                            : 'NO Address Found',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff000000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/bo.svg',
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Select pharmacy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Color(0xffE0712D)),
                        ),
                      )
                    else
                      ...pharmacies.asMap().entries.map((entry) {
                        final index = entry.key;
                        final pharmacy = entry.value;
                        return CustomPharmacy(
                          pharmacyName: pharmacy.pharmacy_name,
                          isSelected: selectedPharmacyIndex == index,
                          onTap: () {
                            setState(() {
                              selectedPharmacyIndex = index;
                            });
                          },
                        );
                      }).toList(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFFFFFAF7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          content: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomEdit(
                                  title: "Pharmacy Name",
                                  hintText: "Type pharmacy name here",
                                  controller: _pharmacyNameController,
                                ),
                                const SizedBox(height: 15),
                                CustomEdit(
                                  title: "Pharmacy Address",
                                  hintText: "Type your pharmacy address",
                                  controller: _pharmacyAddressController,
                                ),
                                const SizedBox(height: 15),
                                CustomEdit(
                                  title: "Website URL (order page URL)",
                                  hintText: "Please enter the website URL",
                                  controller: _websiteUrlController,
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: _addPharmacy,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffE0712D),
                                    padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 11),
                                  ),
                                  child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Color(0xFFE0712D), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add pharmacy',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE0712D),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFE0712D),
                          decorationThickness: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE0712D),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    pharmacies.isNotEmpty 
                        ? 'Your order will be redirected to ${pharmacies[selectedPharmacyIndex].pharmacy_name}'
                        : 'Your order will be redirected to selected pharmacy',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
              CustomButton(text: "Confirm", onTap: (){
                // Create updated medicine with new stock = original stock + selected quantity
                final updatedMedicine = MedicineModel(
                  id: widget.medicine.id,
                  name: widget.medicine.name,
                  howManyDay: widget.medicine.howManyDay,
                  stock: widget.medicine.stock + selectedQuantity, // Add selected quantity to stock
                  prescriptionId: widget.medicine.prescriptionId,
                  quantity: 0, // Reset quantity after confirmation
                );
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicineScreen()),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}