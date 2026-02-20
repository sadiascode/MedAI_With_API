import 'package:flutter/material.dart';

class CustomInfo extends StatefulWidget {
  final String name;
  final String age;
  final String sex;
  final String gender;
  final Function(String, String)? onChanged;

  const CustomInfo({
    super.key,
    required this.name,
    required this.age,
    required this.sex,
    required this.gender,
    this.onChanged,
  });

  @override
  State<CustomInfo> createState() => _CustomInfoState();
}

class _CustomInfoState extends State<CustomInfo> {
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  bool _isEditingAge = false;
  bool _isEditingGender = false;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.age);
    _genderController = TextEditingController(text: widget.gender);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffFFF0E6),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xffE0712D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: _isEditingAge
                  ? TextField(
                controller: _ageController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                autofocus: true,
                onSubmitted: (value) {
                  setState(() {
                    _isEditingAge = false;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(value, _genderController.text);
                  }
                },
              )
                  : GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditingAge = true;
                  });
                },
                child: Text(
                  _ageController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xffE0712D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Text(
              widget.sex,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: _isEditingGender
                  ? TextField(
                controller: _genderController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                autofocus: true,
                onSubmitted: (value) {
                  setState(() {
                    _isEditingGender = false;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(_ageController.text, value);
                  }
                },
              )
                  : GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditingGender = true;
                  });
                },
                child: Text(
                  _genderController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
