import 'package:flutter/material.dart';

class CustomDate extends StatefulWidget {
  final String title;
  final String hint;
  final Function(DateTime)? onDateSelected;
  final Function(TimeOfDay)? onTimeSelected;

  const CustomDate({
    super.key,
    required this.title,
    required this.hint,
    this.onDateSelected,
    this.onTimeSelected,
  });

  @override
  State<CustomDate> createState() => _CustomDateState();
}

class _CustomDateState extends State<CustomDate> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDateTime() async {
    // Date Picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFFF6B35),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Time Picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary:  Color(0xffE0712D),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteTextColor: Colors.black87,
                dayPeriodTextColor:Colors.black87, // AM/PM text
                dayPeriodColor: Color(0xffE0712D),
                dayPeriodBorderSide: BorderSide(color: Color(0xffE0712D), width: 1 ),
                dialHandColor: Color(0xffE0712D),
                dialBackgroundColor: Color(0xFFFFF0E6),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });

        if (widget.onDateSelected != null) {
          widget.onDateSelected!(pickedDate);
        }
        if (widget.onTimeSelected != null) {
          widget.onTimeSelected!(pickedTime);
        }
      }
    }
  }

  String _getDisplayText() {
    if (selectedDate != null && selectedTime != null) {
      return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${selectedTime!.format(context)}';
    }
    return widget.hint;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),

          GestureDetector(
            onTap: _selectDateTime,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Color(0xffFFF0E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _getDisplayText(),
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedDate != null && selectedTime != null
                            ? Colors.black87
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_month,
                    color: Color(0xffE0712D),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}