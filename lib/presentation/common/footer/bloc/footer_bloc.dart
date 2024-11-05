import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_event.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_state.dart';

class FooterBloc extends Bloc<FooterEvent, FooterState> {
  final NodeInfoRepository nodeInfoRepository;

  FooterBloc({required this.nodeInfoRepository}) : super(const FooterState()) {
    on<NodeInfoRequested>(_onNodeInfoRequested);
  }

  Future<void> _onNodeInfoRequested(
      NodeInfoRequested event, Emitter<FooterState> emit) async {
    emit(const FooterState(nodeInfoState: NodeInfoState.loading()));
    try {
      final nodeInfo = await nodeInfoRepository.getNodeInfo();
      emit(FooterState(nodeInfoState: NodeInfoState.success(nodeInfo)));
    } catch (e) {
      emit(FooterState(
          nodeInfoState: NodeInfoState.error('Failed to fetch node info: $e')));
    }
  }
}
