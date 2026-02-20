import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomLinkwith extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String hospital;
  final String? imageUrl;
  final VoidCallback? onTap;

  const CustomLinkwith({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.hospital,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey[400],
                size: 70,
              ),
            ),

            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    specialization,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hospital: $hospital',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: InkWell(
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: const BoxDecoration(
                    color: Color(0xffE0712D),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: const Text("Add", style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    )
                    ),
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
