import 'package:flutter/material.dart';

class CustomDosages extends StatelessWidget {
  const CustomDosages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      width: 380,
      decoration: BoxDecoration(
        color: Color(0xffFFF0E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Dosages form",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Dosages weight",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            ),
                SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                    Text(
                      "Pill",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "500 gm",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ],
        ),
      ),
    );
  }
}
