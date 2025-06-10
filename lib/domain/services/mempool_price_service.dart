import 'dart:async';
import 'package:horizon/data/sources/network/mempool_space_client.dart';
import 'package:horizon/domain/entities/network.dart';

class MempoolPriceService {
  final _mempoolSpaceApi = MempoolSpaceApi();
  final _priceController = StreamController<int>.broadcast();
  Timer? _timer;
  int _subscriberCount = 0;

  Stream<int> get priceStream => _priceController.stream;

  void startListening() {
    _subscriberCount++;
    if (_subscriberCount == 1) {
      _fetchPrice();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _fetchPrice());
    }
  }

  void stopListening() {
    _subscriberCount--;
    if (_subscriberCount == 0) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _fetchPrice() async {
    try {
      final response = await _mempoolSpaceApi.getPrices(network: Network.mainnet);
      _priceController.add(response.usd);
    } catch (e) {
      print('Error fetching price: $e');
    }
  }

  void dispose() {
    _timer?.cancel();
    _priceController.close();
  }
}