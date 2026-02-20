import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomNotification extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String iconPath;
  final VoidCallback? onTap;

  const CustomNotification({
    super.key,
    required this.title ,
    required this.message ,
    required this.time ,
    required this.iconPath ,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 45,
                    height: 45,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Text(
              time,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xff333333),
              ),
            ),
          ],
        ),
    );
  }
}
