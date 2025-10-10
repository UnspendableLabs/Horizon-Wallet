import 'package:flutter_bloc/flutter_bloc.dart';
import './remote_data_state.dart';

// TODO: rip this out
abstract class RemoteDataCubit<S> extends Cubit<RemoteDataState<S>> {
  RemoteDataCubit(super.initialState);
}
