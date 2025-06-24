import 'dart:async';
import 'package:horizon/data/sources/network/mempool_space_client.dart';
import 'package:horizon/data/sources/network/mempool_space_client_factory.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/services/mempool_price_service.dart';
import 'package:rxdart/rxdart.dart';

class MempoolPriceServiceImpl implements MempoolPriceService {
  final MempoolSpaceClientFactory _mempoolSpaceClientFactory;
  MempoolSpaceApi? _client;
  final _priceController = BehaviorSubject<int>();
  Timer? _timer;
  int _subscriberCount = 0;

  MempoolPriceServiceImpl(
      {required MempoolSpaceClientFactory mempoolSpaceClientFactory})
      : _mempoolSpaceClientFactory = mempoolSpaceClientFactory;

  @override
  Stream<int> get priceStream => _priceController.stream;

  @override
  int? get lastPrice => _priceController.valueOrNull;

  @override
  void startListening({required HttpConfig httpConfig}) {
    _client = _mempoolSpaceClientFactory.getClient(httpConfig);
    _subscriberCount++;
    if (_subscriberCount == 1) {
      _fetchPrice();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _fetchPrice());
    }
  }

  @override
  void stopListening() {
    _subscriberCount--;
    if (_subscriberCount == 0) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _fetchPrice() async {
    if (_client == null) {
      return;
    }
    try {
      final response = await _client!.getPrices();
      _priceController.add(response.usd);
    } catch (e) {
      print('Error fetching price: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _priceController.close();
  }
}
