import 'package:equatable/equatable.dart';

sealed class RemoteData<T> extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotAsked<T> extends RemoteData<T> {
  NotAsked();
  @override
  String toString() => "NotAsked";
}

class Loading<T> extends RemoteData<T> {
  Loading();
  @override
  String toString() => "Loading";
}

class Success<T> extends RemoteData<T> {
  final T data;
  Success(this.data);
  @override
  String toString() => "Success";
}

class Failure<T> extends RemoteData<T> {
  final String errorMessage;
  Failure(this.errorMessage);
  @override
  String toString() => "Failure";
}

T successOrThrow<T>(RemoteData<T> remoteData) {
  if (remoteData is Success<T>) {
    return remoteData.data;
  }
  if (remoteData is Failure<T>) {
    throw Exception(remoteData.errorMessage);
  }
  throw Exception('RemoteData is neither Success nor Failure');
}
