import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

import 'package:horizon/domain/entities/fee_option.dart';

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


  TransactionFormModelBase({ required this.feeOptionInput });



  @override
  List<FormzInput> get inputs =>
      [feeOptionInput];
}



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
