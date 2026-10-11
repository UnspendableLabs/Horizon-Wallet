import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_bloc.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';

class MockSendBloc extends MockBloc<ComposeBaseEvent, ComposeSendState>
    implements ComposeSendBloc {}

class MockActivityBloc extends Mock implements DashboardActivityFeedBloc {}

Balance xcp(int quantity) => Balance(
    address: 'source',
    quantity: quantity,
    quantityNormalized: (quantity / 100000000).toString(),
    asset: 'XCP',
    assetInfo: const AssetInfo(divisible: true));

void main() {
  late MockSendBloc bloc;
  late StreamController<ComposeSendState> stream;
  late List<ComposeBaseEvent> events;
  final key = GlobalKey<ComposeSendPageState>();

  setUpAll(() => registerFallbackValue(
      AsyncFormDependenciesRequested(currentAddress: 'source')));
  setUp(() {
    bloc = MockSendBloc();
    stream = StreamController<ComposeSendState>();
    events = [];
    whenListen(bloc, stream.stream,
        initialState: ComposeSendState.initial().copyWith(
            asset: 'XCP',
            balancesState: BalancesState.success([xcp(200000000)])));
    when(() => bloc.add(any())).thenAnswer((call) {
      events.add(call.positionalArguments.first as ComposeBaseEvent);
    });
  });
  tearDown(() async {
    await stream.close();
    await bloc.close();
  });

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: BlocProvider<ComposeSendBloc>.value(
                    value: bloc,
                    child: ComposeSendPage(
                        key: key,
                        address: 'source',
                        asset: 'XCP',
                        dashboardActivityFeedBloc: MockActivityBloc()))))));
    await tester.pump();
    key.currentState!.destinationAddressController.text = 'destination';
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
  }

  testWidgets(
      'programmatically filled quantity submits without a typing callback',
      (tester) async {
    await mount(tester);
    key.currentState!.quantityController.text = '1';
    await submit(tester);
    final submitted = events.whereType<FormSubmitted>().single;
    expect((submitted.params as ComposeSendEventParams).quantity, 100000000);
    expect((submitted.params as ComposeSendEventParams).asset, 'XCP');
    expect(tester.takeException(), isNull);
  });

  testWidgets('MAX-filled quantity uses the current balance', (tester) async {
    await mount(tester);
    stream.add(bloc.state.copyWith(
        sendMax: true, maxValue: const MaxValueState.success(100000000)));
    await tester.pump();
    expect(key.currentState!.quantityController.text, '1.00000000');
    await submit(tester);
    expect(events.whereType<FormSubmitted>(), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing balance blocks submission and offers a refresh',
      (tester) async {
    await mount(tester);
    key.currentState!.quantityController.text = '1';
    stream.add(
        bloc.state.copyWith(balancesState: const BalancesState.success([])));
    await tester.pump();
    await submit(tester);
    expect(events.whereType<FormSubmitted>(), isEmpty);
    expect(find.text('Refresh balances'), findsOneWidget);
    await tester.tap(find.text('Refresh balances'));
    await tester.pump();
    expect(events.whereType<AsyncFormDependenciesRequested>(), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'changed balances are revalidated instead of using a cached amount',
      (tester) async {
    await mount(tester);
    key.currentState!.quantityController.text = '1';
    stream.add(bloc.state
        .copyWith(balancesState: BalancesState.success([xcp(10000000)])));
    await tester.pump();
    await submit(tester);
    expect(events.whereType<FormSubmitted>(), isEmpty);
    expect(find.text('quantity exceeds max'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'a selected asset missing from refreshed dropdown entries does not throw',
      (tester) async {
    await mount(tester);
    stream.add(bloc.state.copyWith(
        balancesState: BalancesState.success([
      Balance(
          address: 'source',
          quantity: 1000,
          quantityNormalized: '0.00001',
          asset: 'BTC',
          assetInfo: const AssetInfo(divisible: true)),
    ])));
    await tester.pump();
    await submit(tester);
    expect(events.whereType<FormSubmitted>(), isEmpty);
    expect(find.text('Refresh balances'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MAX arriving after balance disappearance does not throw',
      (tester) async {
    await mount(tester);
    stream.add(bloc.state.copyWith(
        sendMax: true,
        balancesState: const BalancesState.success([]),
        maxValue: const MaxValueState.success(100000000)));
    await tester.pump();
    expect(key.currentState!.quantityController.text, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
