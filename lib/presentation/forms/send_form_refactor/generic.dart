import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

import "package:fpdart/fpdart.dart" as fp;
import 'package:horizon/domain/entities/fee_option.dart';

class SubmitSuccess {
  String hex;
  String hash;

  SubmitSuccess({required this.hex, required this.hash});
}

// TODO: refine FeeOptionError
enum FeeOptionError { invalid }

class FeeOptionInput extends FormzInput<FeeOption, FeeOptionError> {
  FeeOptionInput.pure() : super.pure(Medium());
  const FeeOptionInput.dirty(FeeOption value) : super.dirty(value);
  @override
  FeeOptionError? validator(FeeOption value) {
    return switch (value) {
      Custom(fee: var value) => value < 0 ? FeeOptionError.invalid : null,
      _ => null
    };
  }
}

class TransactionFormModelBase with FormzMixin {
  final FeeOptionInput feeOptionInput;

  TransactionFormModelBase({required this.feeOptionInput});

  @override
  List<FormzInput> get inputs => [feeOptionInput];
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
  final Widget Function(BuildContext context) reviewView;

  const TransactionFlowView({
    required this.formView,
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
              child: Builder(builder: widget.reviewView),
            ),
          if (model.submitSuccess.isSome()) MaterialPage(child: Text("foo "))
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
