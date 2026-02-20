import 'package:flutter/material.dart';

class BottomTabItem {
  final String label;
  final Widget icon;
  final Widget page;
  final bool isCenter;

  BottomTabItem({
    required this.label,
    required this.icon,
    required this.page,
    this.isCenter = false,
  });
}
