import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';

class ComposeIssuanceBloc extends Bloc<ComposeIssuanceEvent, ComposeIssuanceState> {
  ComposeIssuanceBloc() : super(ComposeIssuanceInitial()) {
    on<CreateIssuanceEvent>((event, emit) async {
      emit(ComposeIssuanceLoading());
      final composeRepository = GetIt.I.get<ComposeRepository>();
      try {
        ComposeIssuance issuance = await composeRepository.composeIssuance(event.sourceAddress.address, event.name,
            event.quantity, event.divisible, event.lock, event.reset, event.description, event.transferDestination);
        emit(ComposeIssuanceSuccess(composeIssuance: issuance));
      } catch (error) {
        if (error is DioException) {
          emit(ComposeIssuanceError(message: "${error.response!.data.keys.first} ${error.response!.data.values.first}"));
        } else {
          emit(ComposeIssuanceError(message: error.toString()));
        }
      }
    });
  }
}
