import 'package:flutter/material.dart';

class CustomPharmacy extends StatefulWidget {
  final String pharmacyName;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomPharmacy({
    super.key,
    required this.pharmacyName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CustomPharmacy> createState() => _CustomPharmacyState();
}

class _CustomPharmacyState extends State<CustomPharmacy> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected
                      ? Color(0xffE0712D)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: widget.isSelected
                  ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(0xffE0712D),
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
            SizedBox(width: 12),
            Text(
              widget.pharmacyName,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
