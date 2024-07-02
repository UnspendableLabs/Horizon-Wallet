// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/services.dart';
//
// import 'package:horizon/domain/entities/account.dart';
// import 'package:horizon/domain/entities/wallet.dart';
// import 'package:horizon/domain/entities/address.dart';
// import 'package:horizon/domain/repositories/materialized_address_repository.dart';
// import 'package:horizon/domain/repositories/account_settings_repository.dart';
// import 'package:horizon/domain/repositories/wallet_repository.dart';
// import 'package:horizon/domain/services/address_service.dart';
// import 'package:horizon/domain/services/wallet_service.dart';
// import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
// import 'package:flutter_settings_screens/flutter_settings_screens.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
// import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';
// import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
//
// class AddressesPage extends StatelessWidget {
//   final String accountUuid;
//
//   const AddressesPage({super.key, required this.accountUuid});
//
//   @override
//   Widget build(BuildContext context) {
//     final accountSettingsRepository = GetIt.I.get<AccountSettingsRepository>();
//
//     final shell = context.watch<ShellStateCubit>();
//     final addressBloc = context.read<AddressesBloc>();
//
//     addressBloc.add(Generate(
//         accountUuid: accountUuid,
//         gapLimit: accountSettingsRepository.getGapLimit(accountUuid) ?? 10));
//
//     Account? account = shell.state.maybeWhen(
//         success: (state) => state.accounts
//             .firstWhere((account) => account.uuid == state.currentAccountUuid),
//         orElse: () => null);
//
//     if (account == null) {
//       throw Exception("invariant: account is null");
//     }
//
//     return Padding(
//         padding: EdgeInsets.all(8.0),
//         child: BlocBuilder<AddressesBloc, AddressesState>(
//             builder: (context, state) {
//           final uuid = account.uuid;
//
//           return state.map(
//               initial: (_) => const Text("initial"),
//               loading: (_) => const Text("loading"),
//               error: (e) => Text("error: ${e.error}"),
//               success: (state) {
//                 return Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                           child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text(
//                                 "Receive Addresses",
//                                 style: TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Container(
//                               height: 300,
//                               child: Card(
//                                 elevation: 1,
//                                 // color: theme.colorScheme.surfaceVariant,
//                                 child: SingleChildScrollView(
//                                     child: DataTable(
//                                   columns: [
//                                     DataColumn(label: Text("Address")),
//                                     DataColumn(label: Text("Path"))
//                                   ],
//                                   rows: state.addresses.map((address) {
//                                     return DataRow(
//                                         onLongPress: () {
//                                           print(address.address);
//                                         },
//                                         cells: [
//                                           DataCell(Text(address.address,
//                                               style: TextStyle(
//                                                   fontFamily: "monospace"))),
//                                           DataCell(Text(
//                                               "${account.purpose}/${account.coinType}/${account.accountIndex}/0/${address.index}"))
//                                         ]);
//                                   }).toList(),
//                                 )),
//                               ),
//                             )
//                           ]))
//                     ]);
//               });
//         }));
//   }
// }
//
//
//     //     final gapLimit = box.get("$uuid:gap-limit") ?? 10;
//     //     final change = box.get("$uuid:change") ?? false;
//     //     final theme = Theme.of(context);
//     //
//     //     return Column(
//     //         mainAxisAlignment: MainAxisAlignment.start,
//     //         crossAxisAlignment: CrossAxisAlignment.start,
//     //         children: [
//     //           FutureBuilder<List<Address>>(
//     //               future: materializedAddressRepository.getAddresses(
//     //                   account, gapLimit),
//     //               builder: (context, snapshot) {
//     //                 if (snapshot.connectionState == ConnectionState.waiting) {
//     //                   return SizedBox.shrink();
//     //                 }
//     //                 if (snapshot.hasError) {
//     //                   return Text("Error: ${snapshot.error}");
//     //                 }
//     //                 if (snapshot.hasData) {
//     //                   return Expanded(
//     //                       child: Column(
//     //                           crossAxisAlignment: CrossAxisAlignment.start,
//     //                           children: [
//     //                         Padding(
//     //                           padding: EdgeInsets.all(8.0),
//     //                           child: Text(
//     //                             "Receive Addresses",
//     //                             style: TextStyle(
//     //                                 fontSize: 18, fontWeight: FontWeight.bold),
//     //                           ),
//     //                         ),
//     //                         Container(
//     //                           height: 300,
//     //                           child: Card(
//     //                             elevation: 1,
//     //                             color: theme.colorScheme.surfaceVariant,
//     //                             child: SingleChildScrollView(
//     //                                 child: DataTable(
//     //                               columns: [
//     //                                 DataColumn(label: Text("Address")),
//     //                                 DataColumn(label: Text("Path"))
//     //                               ],
//     //                               rows: snapshot.data!.map((address) {
//     //                                 return DataRow(
//     //                                     onLongPress: () {
//     //                                       print(address.address);
//     //                                     },
//     //                                     cells: [
//     //                                       DataCell(Text(address.address,
//     //                                           style: TextStyle(
//     //                                               fontFamily: "monospace"))),
//     //                                       DataCell(Text(
//     //                                           "${account.purpose}/${account.coinType}/${account.accountIndex}/0/${address.index}"))
//     //                                     ]);
//     //                               }).toList(),
//     //                             )),
//     //                           ),
//     //                         )
//     //                       ]));
//     //
//     //                   // return ListView.builder(
//     //                   //     itemCount: snapshot.data!.length,
//     //                   //     itemBuilder: (BuildContext context, int index) {
//     //                   //       return ListTile(
//     //                   //         title: Text(snapshot.data![index].address),
//     //                   //         subtitle: Text("${account.purpose}/${account.coinType}/${account.accountIndex}/0/$index"),
//     //                   //         onTap: () => print(index),
//     //                   //       );
//     //                   //     });
//     //                 }
//     //                 return const Text("No data");
//     //               }),
//     //           if (change)
//     //             FutureBuilder<List<Address>>(
//     //                 future: materializedAddressRepository.getAddresses(
//     //                     account, gapLimit, change),
//     //                 builder: (context, snapshot) {
//     //                   if (snapshot.connectionState == ConnectionState.waiting) {
//     //                     return SizedBox.shrink();
//     //                   }
//     //                   if (snapshot.hasError) {
//     //                     return Text("Error: ${snapshot.error}");
//     //                   }
//     //                   if (snapshot.hasData) {
//     //                     return Expanded(
//     //                         child: Column(
//     //                             crossAxisAlignment: CrossAxisAlignment.start,
//     //                             children: [
//     //                           Padding(
//     //                             padding: EdgeInsets.all(8.0),
//     //                             child: Text(
//     //                               "Change Addresses",
//     //                               style: TextStyle(
//     //                                   fontSize: 18,
//     //                                   fontWeight: FontWeight.bold),
//     //                             ),
//     //                           ),
//     //                           Container(
//     //                             height: 300,
//     //                             child: Card(
//     //                               elevation: 1,
//     //                               color: theme.colorScheme.surfaceVariant,
//     //                               child: SingleChildScrollView(
//     //                                   child: DataTable(
//     //                                 columns: [
//     //                                   DataColumn(label: Text("Address")),
//     //                                   DataColumn(label: Text("Path"))
//     //                                 ],
//     //                                 rows: snapshot.data!.map((address) {
//     //                                   return DataRow(cells: [
//     //                                     DataCell(Text(address.address,
//     //                                         style: TextStyle(
//     //                                             fontFamily: "monospace"))),
//     //                                     DataCell(Text(
//     //                                         "${account.purpose}/${account.coinType}/${account.accountIndex}/1/${address.index}"))
//     //                                   ]);
//     //                                 }).toList(),
//     //                               )),
//     //                             ),
//     //                           )
//     //                         ]));
//     //
//     //                     // return ListView.builder(
//     //                     //     itemCount: snapshot.data!.length,
//     //                     //     itemBuilder: (BuildContext context, int index) {
//     //                     //       return ListTile(
//     //                     //         title: Text(snapshot.data![index].address),
//     //                     //         subtitle: Text("${account.purpose}/${account.coinType}/${account.accountIndex}/0/$index"),
//     //                     //         onTap: () => print(index),
//     //                     //       );
//     //                     //     });
//     //                   }
//     //                   return const Text("No data");
//     //                 })
//     //           else
//     //             SizedBox.shrink(),
//     //         ]);
//     //   }),
//     // );
//   // }
