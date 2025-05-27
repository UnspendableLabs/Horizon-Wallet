import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:fpdart/fpdart.dart";

enum AttachQuantityInputError { required }

class AttachQuantityInput extends FormzInput<String, AttachQuantityInputError> {
  const AttachQuantityInput.dirty({required String value}) : super.dirty(value);

  const AttachQuantityInput.pure() : super.pure("");

  @override
  AttachQuantityInputError? validator(String value) {
    if (value.isEmpty) {
      return AttachQuantityInputError.required;
    }
    return null;
  }
}

class AssetAttachFormModel with FormzMixin {
  final AttachQuantityInput attachQuantityInput;

  final FormzSubmissionStatus submissionStatus;

  AssetAttachFormModel(
      {required this.attachQuantityInput, required this.submissionStatus});

  @override
  List<FormzInput> get inputs => [attachQuantityInput];

  AssetAttachFormModel copyWith({
    AttachQuantityInput? attachQuantityInput,
    FormzSubmissionStatus? submissionStatus,
  }) {
    return AssetAttachFormModel(
      attachQuantityInput: attachQuantityInput ?? this.attachQuantityInput,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}

sealed class AssetAttachFormEvent extends Equatable {
  const AssetAttachFormEvent();

  @override
  List<Object?> get props => [];
}

class AttachQuantityInputChanged extends AssetAttachFormEvent {
  final String value;
  const AttachQuantityInputChanged({required this.value});
  @override
  List<Object?> get props => [value];
}

class AssetBalanceFormBloc
    extends Bloc<AssetAttachFormEvent, AssetAttachFormModel> {
  AssetBalanceFormBloc()
      : super(AssetAttachFormModel(
          attachQuantityInput: const AttachQuantityInput.pure(),
          submissionStatus: FormzSubmissionStatus.initial,
        )) {
    on<AttachQuantityInputChanged>(_handleAttachQuantityInputChanged);
  }

  void _handleAttachQuantityInputChanged(
    AttachQuantityInputChanged event,
    Emitter<AssetAttachFormModel> emit,
  ) {
    emit(state.copyWith(
        attachQuantityInput: AttachQuantityInput.dirty(value: event.value)));
  }
}
