import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // Import flutter_svg package

class CustomScreen extends StatefulWidget {
  final String svgPath;
  final double svgHeight;
  final double svgWidth;
  final Widget child;

  const CustomScreen({
    super.key,
    required this.svgPath,
    required this.svgHeight,
    required this.svgWidth,
    required this.child,
  });

  @override
  State<CustomScreen> createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF0E6),
      body: Stack(
        children: [

          Container(color: const Color(0xffFFF0E6)),
          Positioned(
            top: 110,
            left: 10,
            right: 10,
            child: Center(
              child: SvgPicture.asset(
                widget.svgPath,
                height: widget.svgHeight,
                width: widget.svgWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.67,
              widthFactor: 0.93,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xffFEFEFE),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}