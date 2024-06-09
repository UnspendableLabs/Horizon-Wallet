import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';



@JS("JSON.stringify")
external JSString stringify(JSObject obj);

Widget renderObjectProperties(Map<String, dynamic> map) {
  final keyValuePairs = map.entries.map((entry) {
    return MapEntry(
      entry.key,
      Text('${entry.key}: ${entry.value.toString()}'),
    );
  }).toList();

  return Column(
    children: [
      ...keyValuePairs.map((entry) => entry.value),
    ],
  );
}
