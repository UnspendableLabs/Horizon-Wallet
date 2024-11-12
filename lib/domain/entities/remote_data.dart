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
