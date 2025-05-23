import 'package:flutter_bloc/flutter_bloc.dart';
import './base_form_event.dart';
import 'package:horizon/domain/entities/remote_data.dart';

abstract class Loader<Args, Data> {
  Future<Data> load(Args args);
}

class BaseFormBloc<LoadArgs, LoadData>
    extends Bloc<BaseFormEvent, RemoteData<LoadData>> {
  final Loader<LoadArgs, LoadData> _loader;

  BaseFormBloc({required Loader<LoadArgs, LoadData> loader})
      : _loader = loader,
        super(Initial<LoadData>()) {
    on<LoadDependencies<LoadArgs>>(_loadWithArgs);
  }

  Future<void> load(
    LoadArgs args,
  ) async {
    add(LoadDependencies<LoadArgs>(args));
  }

  Future<void> _loadWithArgs(
    LoadDependencies<LoadArgs> event,
    Emitter<RemoteData> emit,
  ) async {
    emit(Loading<LoadData>());

    try {
      final formDeps = await _loader.load(event.args);
      emit(Success<LoadData>(formDeps));
    } catch (e) {
      emit(Failure<LoadData>(e));
    }
  }
}
