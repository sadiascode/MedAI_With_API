import 'package:flutter/material.dart';
import '../models/doctor_model.dart';

class CustomDoctext extends StatelessWidget {
  final DoctorModel? doctor;
  
  const CustomDoctext({super.key, this.doctor});

  @override
  Widget build(BuildContext context) {
    // Use real doctor notes if available, otherwise show empty state
    final notes = doctor?.notes ?? [];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notes.isNotEmpty) ...[
            ...notes.asMap().entries.map((entry) {
              final index = entry.key;
              final note = entry.value;
              return _buildDateSection(
                date: 'Note ${index + 1}',
                advices: [note.note],
              );
            }).toList(),
          ] else ...[
            _buildDateSection(
              date: 'No notes available',
              advices: ['Your doctor has not added any suggestions yet'],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSection({
    required String date,
    required List<String> advices,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),

        ...advices.map((advice) => _buildAdviceItem(advice)),
      ],
    );
  }

  Widget _buildAdviceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


