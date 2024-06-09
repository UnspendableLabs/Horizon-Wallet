import 'package:flutter/material.dart';

class CommonBackButton extends StatelessWidget {
  const CommonBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      style: const ButtonStyle(alignment: AlignmentDirectional.topStart),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
