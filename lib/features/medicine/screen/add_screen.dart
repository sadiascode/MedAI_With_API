import 'package:care_agent/common/custom_button.dart';
import 'package:care_agent/features/medicine/screen/checkout_screen.dart';
import 'package:care_agent/features/medicine/screen/medicine_screen.dart';
import 'package:care_agent/features/medicine/widget/custom_dosages.dart';
import 'package:care_agent/features/medicine/widget/custom_napa.dart';
import 'package:care_agent/features/medicine/models/medicine_model.dart';
import 'package:flutter/material.dart';
import '../../../common/app_shell.dart';

class AddScreen extends StatefulWidget {
  final MedicineModel medicine;

  const AddScreen({
    super.key,
    required this.medicine,
  });

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  late MedicineModel _currentMedicine;

  @override
  void initState() {
    super.initState();
    _currentMedicine = widget.medicine;
  }

  void _updateQuantity(int newQuantity) {
    setState(() {
      _currentMedicine = MedicineModel(
        id: _currentMedicine.id,
        name: _currentMedicine.name,
        howManyDay: _currentMedicine.howManyDay,
        stock: _currentMedicine.stock,
        prescriptionId: _currentMedicine.prescriptionId,
        quantity: newQuantity,
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SubPageScaffold(
      parentTabIndex: 1,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xffE0712D), size: 18),
        ),
        title: const Text(
          "Refill Medicine",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: screenWidth,
              child: Image.asset(
                'assets/pills.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 35),
            CustomNapa(
  medicine: _currentMedicine,
  onQuantityChanged: _updateQuantity,
),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(15),
              child: CustomButton(
                text: "Next",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(medicine: _currentMedicine),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
