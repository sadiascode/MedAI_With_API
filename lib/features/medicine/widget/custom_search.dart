import 'package:flutter/material.dart';

class CustomSearch extends StatelessWidget {
  final Function(String)? onChanged;

  const CustomSearch({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFFF0E6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xff333333)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: "Search your medicines...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xff333333)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
