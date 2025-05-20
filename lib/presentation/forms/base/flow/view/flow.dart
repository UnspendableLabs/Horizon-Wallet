import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';

import "package:fpdart/fpdart.dart" as fp;

class SubmitSuccess {
  String hex;
  String hash;

  SubmitSuccess({required this.hex, required this.hash});
}

class TransactionFlowModel<T> {
  final fp.Option<T> composeResponse;
  final fp.Option<SubmitSuccess> submitSuccess;

  TransactionFlowModel(
      {required this.composeResponse, required this.submitSuccess});

  TransactionFlowModel<T> copyWith({
    fp.Option<T>? composeResponse,
    fp.Option<SubmitSuccess>? submitSuccess,
  }) {
    return TransactionFlowModel(
      composeResponse: composeResponse ?? this.composeResponse,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }
}

class TransactionFlowController<T>
    extends FlowController<TransactionFlowModel<T>> {
  TransactionFlowController({
    required TransactionFlowModel<T> initialState,
  }) : super(initialState);
}

class TransactionFlowView<T> extends StatefulWidget {
  final Widget Function(BuildContext context) formView;
  final Widget Function(BuildContext context) signView;
  final Widget Function(BuildContext context) reviewView;

  const TransactionFlowView({
    required this.formView,
    required this.signView,
    required this.reviewView,
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
      initialState: TransactionFlowModel(
        composeResponse: const fp.Option.none(),
        submitSuccess: const fp.Option.none(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<TransactionFlowModel<T>>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          MaterialPage(child: Builder(builder: widget.formView)),
          if (model.composeResponse.isSome())
            MaterialPage(
              child: Builder(builder: widget.signView),
            ),
          if (model.submitSuccess.isSome())
            MaterialPage(
              child: Builder(builder: widget.reviewView),
            )
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
