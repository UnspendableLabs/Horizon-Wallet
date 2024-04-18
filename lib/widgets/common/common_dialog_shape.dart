import 'package:flutter/material.dart';

ShapeBorder getDialogShape() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4.0),
    side: const BorderSide(
      color: Color.fromRGBO(159, 194, 244, 1.0),
    ),
  );
}
