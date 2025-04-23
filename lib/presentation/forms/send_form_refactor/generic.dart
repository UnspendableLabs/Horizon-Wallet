import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';

class TransactionFlowModel<T> {
  final T? formData;

  TransactionFlowModel({this.formData});
}

class TransactionFlowController<T>
    extends FlowController<TransactionFlowModel<T>> {
  TransactionFlowController({
    required TransactionFlowModel<T> initialState,
  }) : super(initialState);
}

class TransactionFlowView<T> extends StatefulWidget {
  final Widget formView;

  const TransactionFlowView({
    required this.formView,
    super.key,
  });

  @override
  State<TransactionFlowView> createState() => _TransactionFlowView<T>();
}

class _TransactionFlowView<T> extends State<TransactionFlowView<T>> {
  late TransactionFlowController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransactionFlowController(
      initialState: TransactionFlowModel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<TransactionFlowModel<T>>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          MaterialPage(child: widget.formView),
          if (model.formData != null)
            MaterialPage(
              child: Text('Review transaction flow'),
            ),
        ];
      },
    );
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }
}
