import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/address_v2_repository.dart';

import 'package:horizon/presentation/common/gradient_avatar.dart';
import 'package:go_router/go_router.dart';

import 'package:formz/formz.dart';
import "./bloc/generate_account_bloc.dart";

class AccountsScreen extends StatelessWidget {
  final BitcoinRepository _bitcoinRepository;
  final AddressV2Repository _addressV2Repository;

  AccountsScreen(
      {BitcoinRepository? bitcoinRepository,
      AddressV2Repository? addressV2Repository,
      super.key})
      : _addressV2Repository =
            addressV2Repository ?? GetIt.I<AddressV2Repository>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final currentAccount = session.currentAccount;
    final accounts = session.accounts;

    return BlocProvider(
      create: (_) => GenerateAccountBloc(),
      child: BlocConsumer<GenerateAccountBloc, GenerateAccountState>(
          listener: (context, state) {
        if (state.status.isSuccess) {
          context.read<SessionStateCubit>().refresh();
        }
      }, builder: (context, state) {
        final session =
            context.watch<SessionStateCubit>().state.successOrThrow();

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];

                  // TODO: need to make this actully work

                  final isSelected = account.hash == currentAccount!.hash;

                  return ListTile(
                    leading: GradientAvatar(
                      input: account.hash,
                      radius: 18,
                    ),
                    trailing: PopupMenuButton(
                      tooltip: "account actions",
                      icon: const Icon(Icons.more_vert, size: 16),
                      onSelected: (value) {
                        switch (value) {
                          case "manage_addresses":
                            context.go(
                              "/accounts/detail",
                              extra: account,
                            );
                          default:
                          // no op
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'manage_addresses',
                          child: Text('Manage Addresses'),
                        ),
                        // PopupMenuItem(
                        //   value: 'delete',
                        //   child: Text('Delete'),
                        // ),
                      ],
                    ),
                    title: Text(
                      account.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: RemoteDataTaskEitherBuilder(task:
                        TaskEither<String, List<AddressInfo>>.Do(($) async {
                      final addressSet = await $(
                          _addressV2Repository.getByAccountT(
                              account: account,
                              onError: (e, _) =>
                                  "failed to generate account addresses"));

                      return await $(_bitcoinRepository.getAddressInfoMultiT(
                          httpConfig: session.httpConfig,
                          addresses:
                              addressSet.list.map((a) => a.address).toList(),
                          onError: (
                            e,
                          ) =>
                              "failed to fetch BTC balance"));
                    }), builder: (context, state, refresh) {
                      return state.fold3(
                          onNone: () => const SizedBox.shrink(),
                          onFailure: (_) => const SizedBox.shrink(),
                          onReplete: (addressInfoList) {
                            final total = addressInfoList.fold(0, (sum, info) {
                              final funded = info.chainStats.fundedTxoSum;
                              final spent = info.chainStats.spentTxoSum;
                              final quantity = funded - spent;
                              return sum + quantity;
                            });

                            return SatsToUsdDisplay(
                              sats: BigInt.from(total),
                            );
                          });
                    }),
                    onTap: () {
                      context
                          .read<SessionStateCubit>()
                          .onAccountChanged(account, () {
                        context.go("/");
                      });

                      // TODO: this isn't totally ideal
                      // Update session (if changing current account is allowed)
                      // Navigator.of(context).pop(); // go back after selecting
                    },
                  );
                },
              ),
            ),
            Builder(builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: HorizonButton(
                  child: TextButtonContent(value: 'New Account'),
                  onPressed: () {
                    context
                        .read<GenerateAccountBloc>()
                        .add(GenerateAccountClicked());
                    // TODO: Push to create account flow
                  },
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
