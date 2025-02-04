import 'package:equatable/equatable.dart';

sealed class DecryptionStrategy extends Equatable {}

class Password extends DecryptionStrategy {
  final String password;
  Password(this.password);

  @override
  List<Object> get props => [password];
}

class InMemoryKey extends DecryptionStrategy {
  // final String key;
  // InMemoryKey(this.key);
  @override
  List<Object> get props => [];
}
