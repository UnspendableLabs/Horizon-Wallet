import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';

class ComposeOrderEventParams {
  final String initialGiveAsset;
  final int initialGiveQuantity;
  final String initialGetAsset;
  final int initialGetQuantity;
  ComposeOrderEventParams({
    required this.initialGiveAsset,
    required this.initialGiveQuantity,
    required this.initialGetAsset,
    required this.initialGetQuantity,
  });
}

