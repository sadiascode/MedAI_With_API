import 'package:flutter/material.dart';

class CustomDetails1 extends StatefulWidget {
  final String name;
  final String subtitle;
  final Function(String)? onChanged;

  const CustomDetails1({
    super.key,
    required this.name,
    required this.subtitle ,
    this.onChanged,
  });

  @override
  State<CustomDetails1> createState() => _CustomDetails1State();
}

class _CustomDetails1State extends State<CustomDetails1> {
  late TextEditingController _subtitleController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _subtitleController = TextEditingController(text: widget.subtitle);
  }

  @override
  void dispose() {
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xffFFF0E6),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              child: _isEditing
                  ? TextField(
                controller: _subtitleController,
                keyboardType: TextInputType.number,
                textAlignVertical: TextAlignVertical.center,
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
                    _isEditing = false;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                },
              )
                  : GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: Text(
                  _subtitleController.text,
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
