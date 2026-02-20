import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomRefill extends StatelessWidget {
  final String medicineName;
  final int remainingCount;
  final VoidCallback? onRefill;

  const CustomRefill({
    super.key,
    required this.medicineName,
    required this.remainingCount,
    this.onRefill,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFFFF0E6),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/pill.svg',
                  width: 56,
                  height: 56,
                ),
              ),
            ),
            SizedBox(width: 16),

            Expanded(
              child: Text(
                medicineName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),

            // Remains
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFFE0712D),
                  width: 1,
                ),
              ),
              child: Text(
                'Remains: ${remainingCount.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFE0712D),
                ),
              ),
            ),
            SizedBox(width: 7),

            // Refill
            GestureDetector(
              onTap: onRefill,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFE0712D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Refill',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
