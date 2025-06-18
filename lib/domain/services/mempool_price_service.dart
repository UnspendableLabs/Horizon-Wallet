import 'dart:async';

abstract class MempoolPriceService {
  Stream<int> get priceStream;
  void startListening();
  void stopListening();
  void dispose();
}