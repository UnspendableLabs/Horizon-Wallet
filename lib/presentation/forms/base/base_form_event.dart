import 'package:equatable/equatable.dart';
import "package:horizon/domain/entities/base/show.dart";

abstract class BaseFormEvent extends Equatable {
  const BaseFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadDependencies<Args> extends BaseFormEvent {
  final Args args;

  const LoadDependencies(this.args);

  @override
  List<Object?> get props => [args];

  @override
  String toString() => 'LoadDependencies { args: $args }';
}

class FormSubmitted<FormData extends Show> extends BaseFormEvent {
  final FormData formData;
  const FormSubmitted(this.formData);
  @override
  List<Object?> get props => [formData];
  @override
  String toString() => 'FormSubmitted { form: ${formData.show()} }';
}
