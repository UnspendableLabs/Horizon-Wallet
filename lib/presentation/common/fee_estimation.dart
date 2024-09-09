import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/discrete_slider.dart';
import 'package:horizon/common/format.dart';

class FeeEstimation extends StatefulWidget {
  final Map<String, double> feeMap;
  final Function(double) onChanged;
  final int virtualSize;

  const FeeEstimation(
      {super.key,
      required this.feeMap,
      required this.onChanged,
      required this.virtualSize});

  @override
  FeeEstimationState createState() => FeeEstimationState();
}

class FeeEstimationState extends State<FeeEstimation> {
  late String _confirmationTarget;

  @override
  void initState() {
    super.initState();
    _confirmationTarget = widget.feeMap.keys.first;
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        DiscreteSlider(
          valueMap: widget.feeMap,
          onChanged: (key) {
            setState(() {
              _confirmationTarget = key;
            });
            widget.onChanged(_getTotalSats().toDouble());
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SelectableText(
                        "$_confirmationTarget block${int.parse(_confirmationTarget) > 1 ? "s" : ""}",
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(width: 4),
                    SelectableText(
                      "(${widget.feeMap[_confirmationTarget]!.toStringAsFixed(4)} sats/vbyte)",
                    ),
                  ],
                ),
              ),
              Row(children: [
                SelectableText("${satoshisToBtc(_getTotalSats()).toString()} BTC",
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(width: 4),
                SelectableText(
                  "${_getTotalSats().toString()} sats",
                ),
              ]),
            ],
          ),
        )
      ],
    );
  }

  int _getTotalSats() {
    return (widget.virtualSize * widget.feeMap[_confirmationTarget]!).ceil();
  }
}
