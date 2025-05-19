import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_event.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_state.dart';
import 'package:horizon/domain/entities/http_config.dart';

class FooterBloc extends Bloc<FooterEvent, FooterState> {
  final NodeInfoRepository nodeInfoRepository;
  final HttpConfig httpConfig;

  FooterBloc({required this.nodeInfoRepository, required this.httpConfig})
      : super(const FooterState()) {
    on<NodeInfoRequested>(_onNodeInfoRequested);
  }

  Future<void> _onNodeInfoRequested(
      NodeInfoRequested event, Emitter<FooterState> emit) async {
    emit(const FooterState(nodeInfoState: NodeInfoState.loading()));
    try {
      final nodeInfo = await nodeInfoRepository.getNodeInfo(httpConfig);
      emit(FooterState(nodeInfoState: NodeInfoState.success(nodeInfo)));
    } catch (e) {
      emit(FooterState(
          nodeInfoState: NodeInfoState.error('Failed to fetch node info: $e')));
    }
  }
}
