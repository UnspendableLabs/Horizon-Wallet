import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';

class ComposeIssuanceBloc extends Bloc<ComposeIssuanceEvent, ComposeIssuanceState> {
  ComposeIssuanceBloc() : super(ComposeIssuanceInitial()) {}
}
