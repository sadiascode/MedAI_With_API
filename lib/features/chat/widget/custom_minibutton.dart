import 'package:flutter/material.dart';

class CustomMinibutton extends StatelessWidget {
  final String text;
  final Color textcolor;
  final VoidCallback onTap;
  final Color backgroundColor;

  const CustomMinibutton({
    super.key,
    required this.text,
    required this.onTap,
    required this.textcolor,
     required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * 0.3,
      height: screenHeight * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(
              color: Color(0xffE0712D),
              width: 2,
            ),
          ),
        ),
        onPressed: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              color: textcolor,
            ),
          ),
        ),
      ),
    );
  }
}
