import 'package:flutter_bloc/flutter_bloc.dart';

class SendBlocEvents {}

class SendPageState {
  const SendPageState();
}

class SendPageBloc extends Bloc<SendBlocEvents, SendPageState> {
  SendPageBloc(super.initialState);
}
