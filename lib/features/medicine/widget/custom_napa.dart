import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class CustomNapa extends StatefulWidget {
  final MedicineModel medicine;
  final Function(int) onQuantityChanged;

  const CustomNapa({
    super.key,
    required this.medicine,
    required this.onQuantityChanged,
  });

  @override
  State<CustomNapa> createState() => _CustomNapaState();
}

class _CustomNapaState extends State<CustomNapa> {
  int pillCount = 0;

  @override
  void initState() {
    super.initState();
    pillCount = widget.medicine.quantity;
  }

  void _updatePillCount(int newCount) {
    setState(() {
      pillCount = newCount;
    });
    widget.onQuantityChanged(pillCount);
  }

  @override
  Widget build(BuildContext context) {


    return Container(
      height: 218,
      width: 380,
      decoration: BoxDecoration(
        color: Color(0xffFFF0E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              widget.medicine.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tablets || Remaining pills ${widget.medicine.stock}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Remaining Days ${widget.medicine.howManyDay}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black
              ),
            ),
            const SizedBox(height: 25),
            Row(
             children: [
               const Text(
                'You will need  more pills',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),
               const SizedBox(width: 45),
               Container(
                 decoration: BoxDecoration(
                   color: Color(0xffFFF0E6),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: const  Color(0xffE0712D), width: 1),
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     GestureDetector(
                       onTap: () {
                         if (pillCount > 0) {
                           _updatePillCount(pillCount - 1);
                         }
                       },
                       child: Container(
                         width: 32,
                         height: 28,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: const BorderRadius.only(
                             topLeft: Radius.circular(6),
                             bottomLeft: Radius.circular(6),
                           ),
                         ),
                         child: const Icon(
                           Icons.remove,
                           color: Color(0xffE0712D),
                           size: 20,
                         ),
                       ),
                     ),
                     Container(
                       width: 32,
                       height: 28,
                       color: const Color(0xffE0712D),
                       child: Center(
                         child: Text(
                           '$pillCount',
                           style: const TextStyle(
                             fontSize: 18,
                             color: Colors.white,
                           ),
                         ),
                       ),
                     ),
                     GestureDetector(
                       onTap: () {
                         _updatePillCount(pillCount + 1);
                       },
                       child: Container(
                         width: 32,
                         height: 28, // reduced height
                         decoration: const BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.only(
                             topRight: Radius.circular(6),
                             bottomRight: Radius.circular(6),
                           ),
                         ),
                         child: const Icon(
                           Icons.add,
                           color:Color(0xffE0712D),
                           size: 20,
                         ),
                       ),
                     ),
                   ],
                 ),
               )

             ],
           ),
         ]
        ),
      )
    );
  }
}
