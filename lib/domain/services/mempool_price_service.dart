import 'dart:async';
import 'package:horizon/domain/entities/http_config.dart';

abstract class MempoolPriceService {
  Stream<int> get priceStream;
  void startListening({required HttpConfig httpConfig});
  void stopListening();
  void dispose();
}
