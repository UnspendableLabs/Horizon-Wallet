sealed class RemoteData<T> {}

class NotAsked<T> extends RemoteData<T> {
  NotAsked();
}

class Loading<T> extends RemoteData<T> {
  Loading();
}

class Success<T> extends RemoteData<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends RemoteData<T> {
  final String errorMessage;
  Failure(this.errorMessage);
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
