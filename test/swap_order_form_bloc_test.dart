import 'package:bloc_test/bloc_test.dart';
import "package:fpdart/fpdart.dart" hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/order.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/presentation/forms/swap_order_form/bloc/swap_order_form_bloc.dart';
import 'package:horizon/domain/repositories/order_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository implements OrderRepository {
  final List<Order> buys;
  final List<Order> sells;

  MockOrderRepository({
    required this.buys,
    required this.sells,
  });

  @override
  Future<List<Order>> getByAddress(
      {required String address,
      String? status,
      required HttpConfig httpConfig}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Order>> getByPair(
      {required HttpConfig httpConfig,
      required String giveAsset,
      required String getAsset,
      String? status}) async {
    if (giveAsset == "GET") {
      return buys;
    } else {
      return sells;
    }
  }

  TaskEither<String, List<Order>> getByPairTE(
      {required HttpConfig httpConfig,
      required String giveAsset,
      required String getAsset,
      String? status}) {
    return TaskEither.tryCatch(
        () => getByPair(
            httpConfig: httpConfig, giveAsset: giveAsset, getAsset: getAsset),
        (_, __) => "Error");
  }
}

class TestCase {
  final PriceType priceType;
  final AmountType amountType;
  final bool giveDivisible;
  final bool getDivisible;
  final List<Order> buyOrders;
  final List<Order> sellOrders;
  final String amountInput;
  final String priceInput;
  final bool expectMatch;
  final bool expectCreate;
  final String? description;

  const TestCase({
    required this.priceType,
    required this.amountType,
    required this.giveDivisible,
    required this.getDivisible,
    required this.buyOrders,
    required this.sellOrders,
    required this.amountInput,
    required this.priceInput,
    required this.expectMatch,
    required this.expectCreate,
    this.description,
  });

  @override
  String toString() => """TestCase(
    description: "$description",
    priceType: $priceType,
    amountType: $amountType,
    giveDivisible: $giveDivisible,
    getDivisible: $getDivisible,
    buyOrders: $buyOrders,
    sellOrders: $sellOrders,
    amountInput: "$amountInput",
    priceInput: "$priceInput",
    expectMatch: $expectMatch,
    expectCreate: $expectCreate
  )""";
}

List<TestCase> generateTestCases() {
  return [
    TestCase(
        description:
            "AmountType.give-PriceType.give match-only giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.give create-only giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.give-PriceType.give match and create giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.give match-only giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.give create-only giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.give-PriceType.give match and create giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.give match-only giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.give create-only giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.give-PriceType.give match and create giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.give match-only giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.give create-only giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.give-PriceType.give match and create giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-only giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.get create-only giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.give-PriceType.get match and create giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-only giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.get create-only giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.give-PriceType.get match and create giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-only giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.get create-only giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.give-PriceType.get match and create giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-only giveDiv=false getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.give-PriceType.get create-only giveDiv=false getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.give-PriceType.get match and create giveDiv=false getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-only giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.give create-only giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.get-PriceType.give match and create giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-only giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.give create-only giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.get-PriceType.give match and create giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-only giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.give create-only giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.get-PriceType.give match and create giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-only giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.give create-only giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.get-PriceType.give match and create giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "0.5",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-only giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.get create-only giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "200",
        priceInput: "2.0",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.get-PriceType.get match and create giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-only giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.get create-only giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "200",
        priceInput: "2.0",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.get-PriceType.get match and create giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-only giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.get create-only giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "200",
        priceInput: "2.0",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.get-PriceType.get match and create giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-only giveDiv=false getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false),
    TestCase(
        description:
            "AmountType.get-PriceType.get create-only giveDiv=false getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "200",
        priceInput: "2.0",
        expectMatch: false,
        expectCreate: true),
    TestCase(
        description:
            "AmountType.get-PriceType.get match and create giveDiv=false getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 200,
              giveRemaining: 100,
              getRemaining: 200)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "2.0",
        expectMatch: true,
        expectCreate: false)
  ];
}

class FakeAddressV2 extends Fake implements AddressV2 {
  @override
  final String address;
  FakeAddressV2({required this.address});
}

class FakeAsset extends Fake implements Asset {
  @override
  final String asset;
  @override
  final String? assetLongname;
  @override
  final String? owner;
  @override
  final String? issuer;
  @override
  final bool divisible;
  @override
  final bool? locked;

  FakeAsset({
    required this.asset,
    this.assetLongname,
    this.owner,
    this.issuer,
    required this.divisible,
    this.locked,
  });
}

class FakeOrder extends Fake implements Order {
  @override
  final int giveQuantity;
  @override
  final int getQuantity;
  @override
  final int giveRemaining;
  @override
  final int getRemaining;
  FakeOrder({
    required this.giveQuantity,
    required this.getQuantity,
    required this.giveRemaining,
    required this.getRemaining,
  });

  @override
  String toString() {
    return """FakeOrder(
      giveQuantity: $giveQuantity,
      getQuantity: $getQuantity,
      giveRemaining: $giveRemaining,
      getRemaining: $getRemaining
     )""";
  }
}

void main() {
  group('SwapOrderFormBloc - Order Matching', () {
    final allTestCases = generateTestCases();


    for (final testCase in allTestCases) {
      blocTest<SwapOrderFormBloc, SwapOrderFormModel>(
        testCase.description ??
            'giveDiv=${testCase.giveDivisible}, getDiv=${testCase.getDivisible}, amount=${testCase.amountType}, price=${testCase.priceType}, match=${testCase.expectMatch}, create=${testCase.expectCreate}',
        build: () {
          final giveAsset =
              FakeAsset(asset: 'GIVE', divisible: testCase.giveDivisible);
          final getAsset =
              FakeAsset(asset: 'GET', divisible: testCase.getDivisible);

          final bloc = SwapOrderFormBloc(
            orderRepository: MockOrderRepository(
              buys: testCase.buyOrders,
              sells: testCase.sellOrders,
            ),
            address: FakeAddressV2(address: 'test-address'),
            httpConfig: HttpConfig.mainnet(),
            giveAsset: giveAsset,
            getAsset: getAsset,
            buyOrders: testCase.buyOrders,
            sellOrders: testCase.sellOrders,
          );

          if (testCase.amountType == AmountType.give) {
            bloc.add(AmountTypeClicked());
          }
          if (testCase.priceType == PriceType.give) {
            bloc.add(PriceTypeClicked());
          }

          return bloc;
        },
        act: (bloc) => bloc
          ..add(AmountInputChanged(value: testCase.amountInput))
          ..add(PriceInputChanged(value: testCase.priceInput))
          ..add(SimulatedOrdersRequested()),
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          final state = bloc.state;

          print("state.simulatedOrders: ${state.simulatedOrders}");

          expect(
            state.simulatedOrders.maybeWhen(
              onSuccess: (orders) =>
                  (testCase.expectMatch
                      ? orders.any((o) => o is SimulatedOrderMatch)
                      : true) &&
                  (testCase.expectCreate
                      ? orders.any((o) => o is SimulatedOrderCreate)
                      : true),
              orElse: () => false,
            ),
            isTrue,
          );
        },
      );
    }
  });
}
