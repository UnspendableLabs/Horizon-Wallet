import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import 'package:horizon/presentation/common/gradient_avatar.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:formz/formz.dart';
import "./bloc/generate_account_bloc.dart";
import "./bloc/account_balances_bloc.dart";
import 'package:horizon/domain/repositories/address_v2_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final currentAccount = session.currentAccount;
    final accounts = session.accounts;

    return MultiBlocProvider(
      providers: [
        BlocProvider<GenerateAccountBloc>(
          create: (_) => GenerateAccountBloc(),
        ),
        BlocProvider<AccountBalancesBloc>(
          create: (_) => AccountBalancesBloc(
            addressV2Repository: GetIt.I<AddressV2Repository>(),
            balanceRepository: GetIt.I<BalanceRepository>(),
          )..add(LoadAccountBalances(
              accounts: accounts,
              httpConfig: session.httpConfig,
            )),
        ),
      ],
      child: BlocConsumer<GenerateAccountBloc, GenerateAccountState>(
        listener: (context, state) {
          if (state.status.isSuccess) {
            context.read<SessionStateCubit>().refresh();
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<AccountBalancesBloc, AccountBalancesState>(
                    builder: (context, balancesState) {
                      if (balancesState.isLoading) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      }

                      if (balancesState.error.isSome()) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                  'Error: ${balancesState.error.getOrElse(() => "Unknown error")}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<AccountBalancesBloc>()
                                      .add(LoadAccountBalances(
                                        accounts: accounts,
                                        httpConfig: session.httpConfig,
                                      ));
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          final isSelected =
                              account.hash == currentAccount!.hash;

                          final balance =
                              balancesState.accountBalances[account.hash];

                          if (balance == null) {
                            return const SizedBox.shrink();
                          }

                          return ListTile(
                            leading: GradientAvatar(
                              input: account.hash,
                              radius: 18,
                            ),
                            title: Text(
                              account.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${balance.totalNormalized} BTC",
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                                SatsToUsdDisplay(
                                  sats: BigInt.from(balance.total),
                                  child: (usd) {
                                    return Text(
                                      "\$${usd.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              context
                                  .read<SessionStateCubit>()
                                  .onAccountChanged(account, () {
                                context.go("/dashboard");
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: HorizonButton(
                            child: TextButtonContent(value: 'New Account'),
                            onPressed: () {
                              context
                                  .read<GenerateAccountBloc>()
                                  .add(GenerateAccountClicked());
                              // TODO: Push to create account flow
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
