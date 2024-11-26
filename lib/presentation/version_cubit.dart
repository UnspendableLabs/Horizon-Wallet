import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pub_semver/pub_semver.dart';

sealed class VersionWarning {}

class NewVersionAvailable extends VersionWarning {}

class VersionServiceUnreachable extends VersionWarning {}

class VersionCubitState {
  final Version latest;
  final Version current;
  final VersionWarning? warning;

  const VersionCubitState(
      {required this.latest, required this.current, this.warning});
}

class VersionCubit extends Cubit<VersionCubitState> {
  VersionCubit(super.state);
}
