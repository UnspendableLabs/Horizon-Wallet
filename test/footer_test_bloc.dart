import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';
import 'package:horizon/domain/entities/node_info.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_bloc.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_state.dart';

class MockNodeInfoRepository extends Mock implements NodeInfoRepository {}

void main() {
  late FooterBloc footerBloc;
  late MockNodeInfoRepository mockNodeInfoRepository;

  const mockNodeInfo = NodeInfo(
    serverReady: true,
    network: 'mainnet',
    version: '10.6.1',
    backendHeight: 868866,
    counterpartyHeight: 868866,
    documentation: 'https://counterpartycore.docs.apiary.io/',
    routes: 'http://api.counterparty.io:4000/v2/routes',
    blueprint:
        'https://raw.githubusercontent.com/CounterpartyXCP/counterparty-core/refs/heads/master/apiary.apib',
  );

  setUp(() {
    mockNodeInfoRepository = MockNodeInfoRepository();
    footerBloc = FooterBloc(nodeInfoRepository: mockNodeInfoRepository);
  });

  tearDown(() {
    footerBloc.close();
  });

  group('FooterBloc', () {
    test('initial state is correct', () {
      expect(footerBloc.state, const FooterState());
    });

    blocTest<FooterBloc, FooterState>(
      'emits loading and success states when node info is fetched successfully',
      build: () {
        when(() => mockNodeInfoRepository.getNodeInfo())
            .thenAnswer((_) async => mockNodeInfo);
        return footerBloc;
      },
      act: (bloc) => bloc.add(NodeInfoRequested()),
      expect: () => [
        const FooterState(nodeInfoState: NodeInfoState.loading()),
        const FooterState(nodeInfoState: NodeInfoState.success(mockNodeInfo)),
      ],
      verify: (_) {
        verify(() => mockNodeInfoRepository.getNodeInfo()).called(1);
      },
    );

    blocTest<FooterBloc, FooterState>(
      'emits loading and error states when node info fetch fails',
      build: () {
        when(() => mockNodeInfoRepository.getNodeInfo())
            .thenThrow(Exception('Failed to connect'));
        return footerBloc;
      },
      act: (bloc) => bloc.add(NodeInfoRequested()),
      expect: () => [
        const FooterState(nodeInfoState: NodeInfoState.loading()),
        const FooterState(
          nodeInfoState: NodeInfoState.error(
            'Failed to fetch node info: Exception: Failed to connect',
          ),
        ),
      ],
      verify: (_) {
        verify(() => mockNodeInfoRepository.getNodeInfo()).called(1);
      },
    );
  });
}
