import 'package:flutter/material.dart';

class ProfitInputField extends StatelessWidget {
  final TextEditingController controller;

  ProfitInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'أدخل نسبة الربح (%)',
        border: OutlineInputBorder(),
      ),
    );
  }
}
