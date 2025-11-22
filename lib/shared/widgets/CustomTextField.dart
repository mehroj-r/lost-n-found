import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final int maxLines;

  const CustomTextField({
    Key? key,
    required this.label,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      keyboardType: keyboardType,
      maxLines: maxLines, // NEW
      decoration: InputDecoration(labelText: label),
    );
  }
}