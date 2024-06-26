import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => DashboardBloc(), child: _DashboardPage_());
  }
}

class _DashboardPage_ extends StatefulWidget {
  @override
  _DashboardPage_State createState() => _DashboardPage_State();
}

class _DashboardPage_State extends State<_DashboardPage_> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(SetAccountAndWallet());
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return BlocBuilder<DashboardBloc, DashboardState>(builder: (context, state) {
      final width = MediaQuery.of(context).size.width;
      return shell.state.maybeWhen(success: (state) => Text(state.currentAccountUuid), orElse: () => Text(""));
    });

    // return Scaffold(
    //   body: Column(
    //     children: <Widget>[
    //       Expanded(
    //         child: Row(
    //           children: <Widget>[
    // NavigationRail(
    //     selectedIndex: 0,
    //     destinations: const <NavigationRailDestination>[
    //       NavigationRailDestination(
    //         icon: Icon(Icons.home),
    //         selectedIcon: Icon(Icons.home),
    //         label: Text('Home'),
    //       ),
    //       NavigationRailDestination(
    //         icon: Badge(child: Icon(Icons.bookmark_border)),
    //         selectedIcon: Badge(child: Icon(Icons.book)),
    //         label: Text('Second'),
    //       ),
    //     ]),
    // Container(
    //   decoration: const BoxDecoration(
    //     border: Border(
    //       right: BorderSide(
    //         color: Colors.grey, // Color of the border
    //         width: 1.0, // Width of the border
    //       ),
    //     ),
    //   ),
    //   width: width / 4,
    // child: ListView(
    //   children: <Widget>[
    //     const ListTile(
    //       title: Text('Horizon',
    //           style: TextStyle(
    //               fontSize: 16, fontWeight: FontWeight.bold),
    //           textAlign: TextAlign.center),
    //       contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 20),
    //     ),
    //     state.accountState is AccountStateSuccess
    //         ? Column(
    //             children: state.accountState.accounts
    //                 .map<Widget>((account) => ListTile(
    //                     title: Text(account.name!),
    //                     selected: account.uuid ==
    //                         state.accountState.currentAccount
    //                             .uuid,
    //                     autofocus: account.uuid ==
    //                         state.accountState.currentAccount
    //                             .uuid,
    //                     onTap: () {}))
    //                 .toList())
    //         : const Text(""),
    //     state.accountState is AccountStateLoading
    //         ? const CircularProgressIndicator()
    //         : const Text(""),
    //     state.accountState is AccountStateError
    //         ? Text("Error: ${state.accountState.error}")
    //         : const Text(""),
    //   ],
    // ),
    // ),
    // state.accountState is AccountStateSuccess
    //     ? Expanded(
    //         child: Column(
    //           children: [const AddressDisplay()]
    //         ),
    //       )
    //     : const Text(''),
    // state.accountState is AccountStateLoading
    //     ? const CircularProgressIndicator()
    //     : const Text(''),
    // state.accountState is AccountStateError
    //     ? Text("Error: ${state.accountState.error}")
    //     : const Text(""),
    //     ],
    //   ),
    // ),
    //   kDebugMode
    //       ? Align(
    //           alignment: Alignment.bottomRight,
    //           child: Container(
    //             padding: EdgeInsets.all(8.0), // Adjust padding as needed
    //             child: ElevatedButton(
    //               onPressed: () {
    //                 context.read<DashboardBloc>().add(DeleteWallet());
    //                 GoRouter.of(context).go('/onboarding');
    //               },
    //               child: Text("Delete DB", style: TextStyle(fontSize: 12)), // Smaller text size
    //               style: ElevatedButton.styleFrom(
    //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Smaller button padding
    //               ),
    //             ),
    //           ),
    //         )
    //       : const SizedBox(),
    // ],
    // )
    // );
    // });
  }
}
