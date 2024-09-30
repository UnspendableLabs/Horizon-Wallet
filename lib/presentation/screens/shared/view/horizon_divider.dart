import 'package:flutter/material.dart';

class HorizonDivider extends StatelessWidget {
  const HorizonDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(
        thickness: 1.0,
      ),
    );
  }
}
