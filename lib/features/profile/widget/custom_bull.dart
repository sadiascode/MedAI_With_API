import 'package:flutter/material.dart';

class CustomBull extends StatelessWidget {
  final String selectedMeal;
  final Function(String) onChanged;

  const CustomBull({
    super.key,
    required this.selectedMeal,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged('Before Meal'),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFE0712D), width: 2),
                ),
                child: selectedMeal == 'Before Meal'
                    ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color:Color(0xFFE0712D),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              ),
              SizedBox(width: 12),
              Text(
                'Before Meal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 50),
        GestureDetector(
          onTap: () => onChanged('After Meal'),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFE0712D), width: 2),
                ),
                child: selectedMeal == 'After Meal'
                    ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(0xFFE0712D),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              ),
              SizedBox(width: 12),
              Text(
                'After Meal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}