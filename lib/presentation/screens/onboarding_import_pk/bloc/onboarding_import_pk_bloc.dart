import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_event.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_state.dart';

class OnboardingImportPKBloc
    extends Bloc<OnboardingImportPKEvent, OnboardingImportPKState> {
  final WalletService walletService;
  final ImportWalletUseCase importWalletUseCase;
  OnboardingImportPKBloc({
    required this.walletService,
    required this.importWalletUseCase,
  }) : super(const OnboardingImportPKState()) {
    on<PKChanged>((event, emit) async {
      if (event.pk.isEmpty) {
        emit(state.copyWith(pkError: "PK is required", pk: event.pk));
      }
      emit(state.copyWith(pk: event.pk, pkError: null));
    });

    on<ImportFormatChanged>((event, emit) async {
      emit(state.copyWith(importFormat: event.importFormat));
    });

    on<PKSubmit>((event, emit) async {
      if (state.pk.isEmpty) {
        emit(state.copyWith(pkError: "PK is required"));
        return;
      }

      // TODO: validate PK

      ImportFormat importFormat = switch (event.importFormat) {
        "Horizon" => ImportFormat.horizon,
        "Freewallet" => ImportFormat.freewallet,
        "Counterwallet" => ImportFormat.counterwallet,
        _ => throw Exception('Invariant: Invalid import format')
      };

      emit(state.copyWith(
          importState: ImportStatePKCollected(),
          importFormat: importFormat,
          pk: event.pk));
    });

    on<ImportWallet>((event, emit) async {
      emit(state.copyWith(importState: ImportStateLoading()));
      final password = event.password;
      await importWalletUseCase.call(
        password: password,
        importFormat: state.importFormat,
        secret: state.pk,
        deriveWallet: (secret, password) =>
            walletService.fromBase58(secret, password),
        onError: (msg) {
          emit(state.copyWith(importState: ImportStateError(message: msg)));
        },
        onSuccess: () {
          emit(state.copyWith(importState: ImportStateSuccess()));
        },
      );
      return;
    });
  }
}
