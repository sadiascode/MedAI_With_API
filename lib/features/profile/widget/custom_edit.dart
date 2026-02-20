import 'package:flutter/material.dart';

class CustomEdit extends StatefulWidget {
  final String title;
  final String? hintText;
  final Color fillColor;
  final TextEditingController? controller;
  final List<String>? dropdownItems;
  final String? selectedValue;
  final Function(String?)? onDropdownChanged;

  const CustomEdit({
    super.key,
    required this.title,
    this.hintText,
    this.controller,
    this.fillColor = const Color(0xFFFFF0E6),
    this.dropdownItems,
    this.selectedValue,
    this.onDropdownChanged,
  });

  @override
  State<CustomEdit> createState() => _CustomEditState();
}

class _CustomEditState extends State<CustomEdit> {
  String? _internalSelectedValue;

  @override
  void initState() {
    super.initState();
    _internalSelectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(CustomEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      setState(() {
        _internalSelectedValue = widget.selectedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 5),
        widget.dropdownItems != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.fillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: _internalSelectedValue,
                  hint: Text(
                    widget.hintText ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: widget.dropdownItems!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _internalSelectedValue = newValue;
                    });
                    if (widget.onDropdownChanged != null) {
                      widget.onDropdownChanged!(newValue);
                    }
                  },
                ),
              )
            : TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: widget.fillColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 14,
                  ),
                ),
              ),
      ],
    );
  }
}
