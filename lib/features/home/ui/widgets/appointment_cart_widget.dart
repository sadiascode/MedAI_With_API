import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppointmentCartWidget extends StatelessWidget {
  final String doctorName;

  const AppointmentCartWidget({
    super.key,
    required this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xffE0712D), width: 5),
          top: BorderSide(color: Color(0xffE0712D), width: 1),
          right: BorderSide(color: Color(0xffE0712D), width: 1),
          bottom: BorderSide(color: Color(0xffE0712D), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/note.svg',
            height: 20,
            width: 20,
            color: Colors.grey,
          ),
          const SizedBox(width: 12),
           Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  "You have an appointment with Dr. ${doctorName.isNotEmpty ? doctorName : 'Not specified'}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}