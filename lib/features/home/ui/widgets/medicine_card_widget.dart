import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MedicineCard extends StatelessWidget {
  final String time, name, dosage , subtitle ;
  const MedicineCard({
    super.key,
    required this.time,
    required this.name,
    required this.dosage,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xffE0712D), width: 5),
          top: BorderSide(color: Color(0xffE0712D), width: 1),
          right: BorderSide(color: Color(0xffE0712D), width: 1),
          bottom: BorderSide(color: Color(0xffE0712D), width: 1),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SvgPicture.asset(
                'assets/pio.svg',
                height: 20,
                width: 20,
                color: Colors.grey,
              ),

              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    dosage,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
