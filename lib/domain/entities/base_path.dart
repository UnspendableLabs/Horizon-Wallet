import 'package:horizon/domain/entities/network.dart';

class BasePath {
  String Function(Network network) get;
  BasePath(this.get);
}
