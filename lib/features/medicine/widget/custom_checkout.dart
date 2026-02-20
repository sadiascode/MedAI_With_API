import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class CustomCheckout extends StatelessWidget {
  final MedicineModel medicine;

  const CustomCheckout({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 87,
      width: 380,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffFFF0E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/box.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  medicine.name.isNotEmpty ? medicine.name : 'No Medicine ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffE0712D),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Quantity: ${medicine.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffE0712D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
