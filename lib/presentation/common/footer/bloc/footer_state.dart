import 'package:horizon/domain/entities/node_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'footer_state.freezed.dart';

@freezed
class FooterState with _$FooterState {
  const factory FooterState({
    @Default(NodeInfoState.initial()) nodeInfoState,
  }) = _FooterState;
}

@freezed
class NodeInfoState with _$NodeInfoState {
  const factory NodeInfoState.initial() = _Initial;
  const factory NodeInfoState.loading() = _Loading;
  const factory NodeInfoState.error(String error) = _Error;
  const factory NodeInfoState.success(NodeInfo nodeInfo) = _Success;
}
