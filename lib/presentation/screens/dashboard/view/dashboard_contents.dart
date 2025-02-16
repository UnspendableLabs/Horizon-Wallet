import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_state.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/view/import_address_pk_form.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/view/view_seed_phrase_form.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/screens/dashboard/bloc/reset/view/reset_dialog.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_state.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_event.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';

class TransparentHorizonSliverAppBar extends StatelessWidget {
  final double expandedHeight;

  const TransparentHorizonSliverAppBar({
    super.key,
    this.expandedHeight = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      // floating: true,
      // snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: const FlexibleSpaceBar(
        background: HorizonAppBarContent(),
      ),
    );
  }
}

class HorizonAppBarContent extends StatelessWidget {
  const HorizonAppBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 700;

    final backgroundColor = isDarkTheme ? lightNavyDarkTheme : greyLightTheme;
    final selectedColor =
        isDarkTheme ? blueDarkThemeGradiantColor : royalBlueLightTheme;
    final unselectedColor = isDarkTheme ? mainTextGrey : mainTextGrey;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: isDarkTheme
                        ? SvgPicture.asset(
                            'assets/logo-white.svg',
                            width: 35,
                            height: 35,
                          )
                        : SvgPicture.asset(
                            'assets/logo-black.svg',
                            width: 35,
                            height: 35,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Text('Horizon',
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black,
                        fontSize: isSmallScreen ? 25 : 30,
                        fontWeight: FontWeight.w700,
                      )),
                  if (!isSmallScreen) const SizedBox(width: 8),
                  if (!isSmallScreen)
                    const Text('Wallet',
                        style: TextStyle(
                          color: neonBlueDarkTheme,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        )),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(
                        color: isDarkTheme
                            ? darkNavyDarkTheme
                            : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (isDarkTheme) {
                              context.read<ThemeBloc>().add(ThemeToggled());
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isDarkTheme ? backgroundColor : selectedColor,
                            ),
                            child: Icon(
                              Icons.wb_sunny,
                              size: 20,
                              color:
                                  isDarkTheme ? unselectedColor : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (!isDarkTheme) {
                              context.read<ThemeBloc>().add(ThemeToggled());
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isDarkTheme ? selectedColor : backgroundColor,
                            ),
                            child: Icon(
                              Icons.dark_mode,
                              size: 20,
                              color: isDarkTheme
                                  ? neonBlueDarkTheme
                                  : unselectedColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                BlocProvider(
                  create: (context) => ResetBloc(
                    kvService: GetIt.I.get<SecureKVService>(),
                    inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
                    walletRepository: GetIt.I.get<WalletRepository>(),
                    accountRepository: GetIt.I.get<AccountRepository>(),
                    addressRepository: GetIt.I.get<AddressRepository>(),
                    importedAddressRepository:
                        GetIt.I.get<ImportedAddressRepository>(),
                    cacheProvider: GetIt.I.get<CacheProvider>(),
                    analyticsService: GetIt.I.get<AnalyticsService>(),
                  ),
                  child: BlocConsumer<ResetBloc, ResetState>(
                    listener: (context, state) {
                      if (state.resetState is Out) {
                        final session = context.read<SessionStateCubit>();
                        session.onOnboarding();
                      }
                    },
                    builder: (context, state) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDarkTheme
                              ? darkNavyDarkTheme
                              : lightBlueLightTheme,
                          shape: BoxShape.circle,
                          border: Border.all(color: noBackgroundColor),
                        ),
                        child: PopupMenuButton<String>(
                          position: PopupMenuPosition.under,
                          icon: Icon(
                            Icons.settings,
                            size: 20,
                            color: isDarkTheme
                                ? mainTextGrey
                                : royalBlueLightTheme,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'lock_screen':
                                context.read<SessionStateCubit>().onLogout();
                                return;
                              case 'reset':
                                HorizonUI.HorizonDialog.show(
                                    context: context,
                                    body: BlocProvider.value(
                                      value:
                                          BlocProvider.of<ResetBloc>(context),
                                      child: const ResetDialog(),
                                    ));
                              case 'import_address_pk':
                                HorizonUI.HorizonDialog.show(
                                  context: context,
                                  body: Builder(builder: (context) {
                                    final bloc =
                                        context.watch<ImportAddressPkBloc>();

                                    final cb = switch (bloc.state) {
                                      ImportAddressPkStep2() => () {
                                          bloc.add(ResetForm());
                                        },
                                      _ => () {
                                          Navigator.of(context).pop();
                                        },
                                    };

                                    return HorizonUI.HorizonDialog(
                                      onBackButtonPressed: cb,
                                      title: "Import address private key",
                                      body: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: ImportAddressPkForm(),
                                      ),
                                    );
                                  }),
                                );
                              case 'view_address_pk':
                              // HorizonUI.HorizonDialog.show(
                              //     context: context,
                              //     body: HorizonUI.HorizonDialog(
                              //       includeBackButton: false,
                              //       includeCloseButton: true,
                              //       title: "View address private key",
                              //       body: Padding(
                              //         padding: const EdgeInsets.symmetric(
                              //             horizontal: 16.0),
                              //         child: ViewAddressPkFormWrapper(
                              //             address: address!),
                              //       ),
                              //     ));
                              case 'view_seed_phrase':
                                HorizonUI.HorizonDialog.show(
                                    context: context,
                                    body: const HorizonUI.HorizonDialog(
                                      includeBackButton: false,
                                      includeCloseButton: true,
                                      title: "View wallet seed phrase",
                                      body: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: ViewSeedPhraseFormWrapper(),
                                      ),
                                    ));
                              case 'settings':
                                context.go("/settings");
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'settings',
                              child: Text('Settings'),
                            ),
                            // PopupMenuItem<String>(
                            //   value: 'view_current_address_in_explorer',
                            //   child: Link(
                            //       display: const Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             Text('View address in explorer'),
                            //             Icon(Icons.open_in_new, size: 16)
                            //           ]),
                            //       href: addressURL),
                            // ),
                            const PopupMenuItem<String>(
                              value: 'view_seed_phrase',
                              child: Text('View wallet seed phrase'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'import_address_pk',
                              child: Text('Import new address private key'),
                            ),
                            // const PopupMenuItem<String>(
                            //   value: 'view_address_pk',
                            //   child: Text('View current address private key'),
                            // ),
                            const PopupMenuItem<String>(
                              value: 'reset',
                              child: Text('Reset wallet'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'lock_screen',
                              child: Text('Lock Screen'),
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
