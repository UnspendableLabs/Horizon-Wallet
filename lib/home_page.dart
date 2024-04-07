import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/data_bloc.dart';
import 'package:uniparty/bloc/data_events.dart';
import 'package:uniparty/bloc/data_state.dart';
import 'package:uniparty/components/wallet_pages/wallet.dart';
import 'package:uniparty/components/wallet_recovery_pages/create_and_recover_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Dispatch the FetchDataEvent when the widget is initialized
    print('init?');
    BlocProvider.of<DataBloc>(context).add(FetchDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<DataBloc>(context),
      listener: (BuildContext context, DataState state) {
        if (state is Success) {
          Navigator.of(context).pushNamed('/wallet');
        }
      },
      child: BlocBuilder(
          bloc: BlocProvider.of<DataBloc>(context),
          builder: (BuildContext context, DataState state) {
            if (state.loading != null) {
              return const Text('Loading...');
            }
            if (state.initial != null) {
              return const CreateAndRecoverPage();
            }
            if (state.success != null) {
              return const Wallet();
            }
            if (state.failure != null) {
              return ErrorWidget('${state.failure}');
            }

            return const Text('no state');
          }),
    );

    // return BlocBuilder<DataBloc, DataState>(
    //   builder: (context, state) {
    //     print('DO WE GET HERE? ${state.isLoading}');
    //     print(state.error);
    //     print(state.data);
    //     if (state.isLoading) {
    //       return const Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     } else if (state.error != null) {
    //       return Center(
    //         child: Text('${state.error}'),
    //       );
    //     } else if (state.data == null) {
    //       return const CreateAndRecoverPage();
    //     }
    //     return const Wallet();
    //   },
    // );
  }
}
