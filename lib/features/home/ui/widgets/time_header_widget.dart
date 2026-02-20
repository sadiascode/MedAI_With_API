import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TimeHeader extends StatelessWidget {
  final String svgPath;
  final String title;

  const TimeHeader({
    super.key,
    required this.svgPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgPath,
            height: 32,
            width: 32,
            color: const Color(0xFFE67E22),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
