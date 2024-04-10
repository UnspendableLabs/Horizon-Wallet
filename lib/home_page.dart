// // my_widget.dart

// import 'package:flutter/material.dart';
// import 'package:uniparty/bloc/data_state.dart';
// import 'package:uniparty/components/wallet_pages/wallet.dart';
// import 'package:uniparty/components/wallet_recovery_pages/create_and_recover_page.dart';
// import 'package:uniparty/models/wallet_retrieve_info.dart';
// import 'package:uniparty/utils/secure_storage.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   Future<DataState>? _loadData;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     Future<WalletRetrieveInfo?> data = SecureStorage().readWalletRetrieveInfo();
//     _loadData ??= data.then((data) {
//       if (data != null) {
//         return DataState(data: data);
//       } else {
//         return DataState(data: null);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<DataState>(
//         future: _loadData,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Text('ERROR: ${snapshot.error}');
//           }
//           if (!snapshot.hasData) {
//             return const Text('Loading...');
//           }
//           if (snapshot.data?.data == null) {
//             return const OnboardingPage();
//           }
//           return const Wallet();
//         });
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:uniparty/bloc/data_bloc.dart';
// // import 'package:uniparty/bloc/data_events.dart';
// // import 'package:uniparty/bloc/data_state.dart';

// // class HomePage extends StatefulWidget {
// //   const HomePage({super.key});

// //   @override
// //   State<HomePage> createState() => _HomePageState();
// // }

// // class _HomePageState extends State<HomePage> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Dispatch the FetchDataEvent when the widget is initialized
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     BlocProvider.of<DataBloc>(context).add(FetchDataEvent());

// //     return BlocBuilder(
// //         bloc: BlocProvider.of<DataBloc>(context),
// //         builder: (BuildContext context, DataState state) {
// //           // print('state loading: ${state.loading}');
// //           // print('state initial: ${state.initial}');
// //           // print('state success: ${state.success}');
// //           // print('state failure: ${state.failure}');
// //           // if (state.loading != null) {
// //           //   return const Text('Loading...');
// //           // }
// //           // if (state.initial != null) {
// //           //   return const OnboardingPage();
// //           // }
// //           // if (state.success != null) {
// //           //   return const Wallet();
// //           // }
// //           // if (state.failure != null) {
// //           //   return ErrorWidget('${state.failure}');
// //           // }

// //           return const Text('no state');
// //         });
// //   }
// // }

// // /**
// //  * return BlocListener(
// //       bloc: BlocProvider.of<DataBloc>(context),
// //       listener: (BuildContext context, DataState state) {
// //         if (state.success != null) {
// //           Navigator.of(context).pushNamed('/wallet');
// //         }
// //       },
// //       child: BlocBuilder(
// //           bloc: BlocProvider.of<DataBloc>(context),
// //           builder: (BuildContext context, DataState state) {
// //             if (state.loading != null) {
// //               return const Text('Loading...');
// //             }
// //             if (state.initial != null) {
// //               return const OnboardingPage();
// //             }
// //             if (state.success != null) {
// //               return const Wallet();
// //             }
// //             if (state.failure != null) {
// //               return ErrorWidget('${state.failure}');
// //             }

// //             return const Text('no state');
// //           }),
// //     );
// //  */
