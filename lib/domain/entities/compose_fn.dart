import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/network_error.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class ComposeParams extends Equatable {}

typedef ComposeFunction<P extends ComposeParams, R extends ComposeResponse>
    = TaskEither<NetworkError, R> Function(
        num fee, List<Utxo> inputsSet, P params, HttpConfig httpConfig);
