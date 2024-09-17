import 'package:flutter/material.dart';

class DiscreteSlider extends StatefulWidget {
  final Map<String, double> valueMap;
  final Function(String) onChanged;

  const DiscreteSlider(
      {super.key, required this.valueMap, required this.onChanged});

  @override
  DiscreteSliderState createState() => DiscreteSliderState();
}

class DiscreteSliderState extends State<DiscreteSlider> {
  late List<String> _keys;
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _keys = widget.valueMap.keys.toList();
    _currentValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          min: 0,
          max: (_keys.length - 1).toDouble(),
          divisions: _keys.length - 1,
          value: _currentValue,
          onChanged: (value) {
            setState(() {
              _currentValue = value;
            });
            int index = value.round();
            if (index >= 0 && index < _keys.length) {
              widget.onChanged(_keys[index]);
            }
          },
        ),
      ],
    );
  }
}
