import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pub_semver/pub_semver.dart';

class VersionCubitState {
  final Version latest;
  final Version current;

  const VersionCubitState(
      {required this.latest,  required this.current});
}

class VersionCubit extends Cubit<VersionCubitState> {
  VersionCubit(super.initialVersionInfo);
}
