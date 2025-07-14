import 'package:bloc_test/bloc_test.dart';
import "package:fpdart/fpdart.dart" hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
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

Matcher equalsSimulatedOrders(List<SimulatedOrder> expected) {
  return predicate<List<SimulatedOrder>>(
    (actual) => _equalsByValue(expected, actual),
    'equalsSimulatedOrders($expected)',
  );
}

bool _equalsByValue(
    List<SimulatedOrder> expected, List<SimulatedOrder> actual) {
  if (expected.length != actual.length) return false;

  for (int i = 0; i < expected.length; i++) {
    if (expected[i] != actual[i]) {
      print('❌ Mismatch at index $i:');
      print('   expected: ${expected[i]}');
      print('   actual:   ${actual[i]}');
      return false;
    }
  }
  return true;
}

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
  final String? description;

  final List<SimulatedOrder> expectedOrders;

  const TestCase({
    required this.priceType,
    required this.amountType,
    required this.giveDivisible,
    required this.getDivisible,
    required this.buyOrders,
    required this.sellOrders,
    required this.amountInput,
    required this.priceInput,
    required this.expectedOrders,
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
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value)))
        ]),
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
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value)))
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.give match-and-create giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)))
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.give match-many giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "1.0",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)))
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.give match-many-partial giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "125",
        priceInput: "1.0",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(25 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(25 * TenToTheEigth.value)))
        ]),
    //
    TestCase(
        description:
            "AmountType.give-PriceType.give match-many-and-create giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          // effective price of .5 give per get
          //                 or  2 get per give
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
          // effective price of 1 give per get
          //                 or 1 get per give
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "1.5", // i am willing to spend up to "1.5 GIVE per get"
        //
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true, quantity: BigInt.from(3333333333)))
        ]),
    // // // //
    TestCase(
        description:
            "AmountType.give-PriceType.give match-only giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        ]),
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
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        ]),
    // //
    TestCase(
        description:
            "AmountType.give-PriceType.give match-and-create giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(100))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.give match-many giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.give match-many-partial giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "125",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(25 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(25))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.give match-many-and-create giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "1.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(33)))
        ]),

    TestCase(
      description:
          "AmountType.give-PriceType.give match-only giveDiv=false getDiv=true",
      priceType: PriceType.give,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200 * TenToTheEigth.value,
            getQuantity: 100,
            giveRemaining: 200 * TenToTheEigth.value,
            getRemaining: 100),
      ],
      sellOrders: [],
      amountInput: "100",
      priceInput: "0.5",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(200 * TenToTheEigth.value)))
      ],
    ),
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
      expectedOrders: [
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(200 * TenToTheEigth.value)))
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.give match-and-create giveDiv=false getDiv=true",
      priceType: PriceType.give,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200 * TenToTheEigth.value,
            getQuantity: 100,
            giveRemaining: 200 * TenToTheEigth.value,
            getRemaining: 100),
      ],
      sellOrders: [],
      amountInput: "150",
      priceInput: "0.75",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(200 * TenToTheEigth.value))),
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true, quantity: BigInt.from(6666666666)))
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.give match-many  giveDiv=false getDiv=true",
      priceType: PriceType.give,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200 * TenToTheEigth.value,
            getQuantity: 100,
            giveRemaining: 200 * TenToTheEigth.value,
            getRemaining: 100),
        FakeOrder(
            giveQuantity: 50 * TenToTheEigth.value,
            getQuantity: 50,
            giveRemaining: 50 * TenToTheEigth.value,
            getRemaining: 50),
      ],
      sellOrders: [],
      amountInput: "150",
      priceInput: "1",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(200 * TenToTheEigth.value))),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(50 * TenToTheEigth.value))),
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.give match-many-partial  giveDiv=false getDiv=true",
      priceType: PriceType.give,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200 * TenToTheEigth.value,
            getQuantity: 100,
            giveRemaining: 200 * TenToTheEigth.value,
            getRemaining: 100),
        FakeOrder(
            giveQuantity: 50 * TenToTheEigth.value,
            getQuantity: 50,
            giveRemaining: 50 * TenToTheEigth.value,
            getRemaining: 50),
      ],
      sellOrders: [],
      amountInput: "125",
      priceInput: "1",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(200 * TenToTheEigth.value))),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(25)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(25 * TenToTheEigth.value))),
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.give match-many-and-create  giveDiv=false getDiv=true",
      priceType: PriceType.give,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200 * TenToTheEigth.value,
            getQuantity: 100,
            giveRemaining: 200 * TenToTheEigth.value,
            getRemaining: 100),
        FakeOrder(
            giveQuantity: 50 * TenToTheEigth.value,
            getQuantity: 50,
            giveRemaining: 50 * TenToTheEigth.value,
            getRemaining: 50),
      ],
      sellOrders: [],
      amountInput: "200",
      priceInput: "1.5",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(200 * TenToTheEigth.value))),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(50 * TenToTheEigth.value))),
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true, quantity: BigInt.from(3333333333)))
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.give match-only giveDiv=false getDiv=false",
      priceType: PriceType.give,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: false,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200,
            getQuantity: 100,
            giveRemaining: 200,
            getRemaining: 100)
      ],
      sellOrders: [],
      amountInput: "100",
      priceInput: "0.5",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
      ],
    ),
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
      expectedOrders: [
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.give match-and-create giveDiv=false getDiv=false",
      priceType: PriceType.give,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: false,
      sellOrders: [],
      amountInput: "150",
      priceInput: "0.75",
      buyOrders: [
        FakeOrder(
            giveQuantity: 200,
            getQuantity: 100,
            giveRemaining: 200,
            getRemaining: 100)
      ],
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(66)))
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.give match-many-partial giveDiv=false getDiv=false",
      priceType: PriceType.give,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: false,
      sellOrders: [],
      amountInput: "125",
      priceInput: "1",
      buyOrders: [
        FakeOrder(
            giveQuantity: 200,
            getQuantity: 100,
            giveRemaining: 200,
            getRemaining: 100),
        FakeOrder(
            giveQuantity: 50,
            getQuantity: 50,
            giveRemaining: 50,
            getRemaining: 50)
      ],
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(25)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(25))),
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.give match-many-and-create giveDiv=false getDiv=false",
      priceType: PriceType.give,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: false,
      sellOrders: [],
      amountInput: "200",
      priceInput: "1.5",
      buyOrders: [
        FakeOrder(
            giveQuantity: 200,
            getQuantity: 100,
            giveRemaining: 200,
            getRemaining: 100),
        FakeOrder(
            giveQuantity: 50,
            getQuantity: 50,
            giveRemaining: 50,
            getRemaining: 50)
      ],
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            // TODO: fix rounding error
            get: AssetQuantity(divisible: false, quantity: BigInt.from(33)))
      ],
    ),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-only giveDive=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "50",
        priceInput: "2", // get .5 GET asset per give
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get create-only giveDive=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "50",
        priceInput: "2", // get .5 GET asset per give
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value))),
        ]),

    TestCase(
        description:
            "AmountType.give-PriceType.get match-and-create giveDive=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "1.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true, quantity: BigInt.from(7500000000))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-many giveDive=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 *
                      TenToTheEigth.value))), // TODO: fix small rounding error
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-many-partial giveDive=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "125",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(25 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(25 *
                      TenToTheEigth.value))), // TODO: fix small rounding error
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-many-and-create giveDive=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: ".75", // get per give,,
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(
                      3750000000))), // TODO: fix small rounding error
        ]),
    // //
    TestCase(
        description:
            "AmountType.give-PriceType.get match-only giveDiv=true getDiv=false",
        amountType: AmountType.give,
        priceType: PriceType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        ]),
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
        priceInput: "2",
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        ]),

    TestCase(
        description:
            "AmountType.give-PriceType.get match-and-create giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "1.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(75))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-many giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-many-partial giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "125",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(25 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(25))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-many-and-create giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50,
              getRemaining: 50 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: ".75",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(37))),
        ]),
    // //
    TestCase(
        description:
            "AmountType.give-PriceType.get match-only giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value)))
        ]),
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
        priceInput: "2",
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value)))
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-and-create giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100)
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "1.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderCreate(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
              get: AssetQuantity(
                  divisible: true, quantity: BigInt.from(7500000000)))
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-many giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50)
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-many-partial giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50)
        ],
        sellOrders: [],
        amountInput: "125",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(25)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(25 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.give-PriceType.get match-many-and-create giveDiv=false getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.give,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: ".75",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value))),
          SimulatedOrderCreate(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
              get: AssetQuantity(
                  divisible: true, quantity: BigInt.from(3750000000))),
        ]),
    TestCase(
      description:
          "AmountType.give-PriceType.get match-only giveDiv=false getDiv=false",
      priceType: PriceType.get,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: false,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200,
            getQuantity: 100,
            giveRemaining: 200,
            getRemaining: 100)
      ],
      sellOrders: [],
      amountInput: "100",
      priceInput: "2.0",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
      ],
    ),
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
      expectedOrders: [
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.get match-and-create giveDiv=false getDiv=false",
      priceType: PriceType.get,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: false,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200,
            getQuantity: 100,
            giveRemaining: 200,
            getRemaining: 100)
      ],
      sellOrders: [],
      amountInput: "150",
      priceInput: "1.5",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(75))),
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.get match-many giveDiv=false getDiv=false",
      priceType: PriceType.get,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: false,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200,
            getQuantity: 100,
            giveRemaining: 200,
            getRemaining: 100),
        FakeOrder(
            giveQuantity: 50,
            getQuantity: 50,
            giveRemaining: 50,
            getRemaining: 50)
      ],
      sellOrders: [],
      amountInput: "150",
      priceInput: "1",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.get match-many-partial giveDiv=false getDiv=false",
      priceType: PriceType.get,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: false,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200,
            getQuantity: 100,
            giveRemaining: 200,
            getRemaining: 100),
        FakeOrder(
            giveQuantity: 50,
            getQuantity: 50,
            giveRemaining: 50,
            getRemaining: 50)
      ],
      sellOrders: [],
      amountInput: "125",
      priceInput: "1",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(25)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(25))),
      ],
    ),
    TestCase(
      description:
          "AmountType.give-PriceType.get match-many-and-create giveDiv=false getDiv=false",
      priceType: PriceType.get,
      amountType: AmountType.give,
      giveDivisible: false,
      getDivisible: false,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200,
            getQuantity: 100,
            giveRemaining: 200,
            getRemaining: 100),
        FakeOrder(
            giveQuantity: 50,
            getQuantity: 50,
            giveRemaining: 50,
            getRemaining: 50)
      ],
      sellOrders: [],
      amountInput: "200",
      priceInput: ".75",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(divisible: false, quantity: BigInt.from(37))),
      ],
    ),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-only giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
        ]),
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
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-and-create giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "250",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(25 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "250",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many-partial giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 80 * TenToTheEigth.value,
              getQuantity: 60 * TenToTheEigth.value,
              giveRemaining: 80 * TenToTheEigth.value,
              getRemaining: 60 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "240",
        priceInput: ".75",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(30 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(40 * TenToTheEigth.value))),
        ]),

    TestCase(
        description:
            "AmountType.get-PriceType.give match-many-and-create giveDiv=true getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50 * TenToTheEigth.value,
              getQuantity: 50 * TenToTheEigth.value,
              giveRemaining: 50 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "250",
        priceInput: "1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-only giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        ]),
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
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-and-create giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "0.75",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(75 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(100))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50,
              getQuantity: 40 * TenToTheEigth.value,
              giveRemaining: 50,
              getRemaining: 40 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "250",
        priceInput: "0.8",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(40 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many-partial giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50,
              getQuantity: 40 * TenToTheEigth.value,
              giveRemaining: 50,
              getRemaining: 40 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "230",
        priceInput: "0.8",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(30 * .8 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(30))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many-and-create giveDiv=true getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 200,
              getRemaining: 100 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 50,
              getQuantity: 40 * TenToTheEigth.value,
              giveRemaining: 50,
              getRemaining: 40 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "275",
        priceInput: "1.1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(200))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(40 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(25 * 1.1 * TenToTheEigth.value)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(25))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-only giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
        ]),
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
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-and-create giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "0.75",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                divisible: false,
                quantity: BigInt.from(75),
              ),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100),
          FakeOrder(
              giveQuantity: 100 * TenToTheEigth.value,
              getQuantity: 80,
              giveRemaining: 100 * TenToTheEigth.value,
              getRemaining: 80)
        ],
        sellOrders: [],
        amountInput: "300",
        priceInput: "0.8",
        // TODO: what should happen when not evenly divisible?
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                divisible: false,
                quantity: BigInt.from(80),
              ),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many-partial giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100),
          FakeOrder(
              giveQuantity: 100 * TenToTheEigth.value,
              getQuantity: 80,
              giveRemaining: 100 * TenToTheEigth.value,
              getRemaining: 80)
        ],
        sellOrders: [],
        amountInput: "290",
        priceInput: "0.8",
        // TODO: what should happen when not evenly divisible?
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                divisible: false,
                quantity: BigInt.from(90 * .8),
              ),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(90 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many-and-create giveDiv=false getDiv=true",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100,
              giveRemaining: 200 * TenToTheEigth.value,
              getRemaining: 100),
          FakeOrder(
              giveQuantity: 100 * TenToTheEigth.value,
              getQuantity: 80,
              giveRemaining: 100 * TenToTheEigth.value,
              getRemaining: 80)
        ],
        sellOrders: [],
        amountInput: "333",
        priceInput: "1.1",
        // TODO: what should happen when not evenly divisible?
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(100)),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(200 * TenToTheEigth.value))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                divisible: false,
                quantity: BigInt.from(80),
              ),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100 * TenToTheEigth.value))),
          SimulatedOrderCreate(
              give: AssetQuantity(
                divisible: false,
                quantity: BigInt.from(33 * 1.1),
              ),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(33 * TenToTheEigth.value))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-only giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100,
              giveRemaining: 150,
              getRemaining: 75)
        ],
        sellOrders: [],
        amountInput: "150",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(75)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(150))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give create-only giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "150",
        priceInput: "0.5",
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(75)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(150))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100,
              giveRemaining: 150,
              getRemaining: 75),
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 100,
              giveRemaining: 50,
              getRemaining: 50)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "1.1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(75)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(150))),
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many-partial giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100,
              giveRemaining: 150,
              getRemaining: 75),
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 100,
              giveRemaining: 50,
              getRemaining: 50)
        ],
        sellOrders: [],
        amountInput: "190",
        priceInput: "1.1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(75)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(150))),
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(40)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(40))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100,
              giveRemaining: 150,
              getRemaining: 75),
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 100,
              giveRemaining: 50,
              getRemaining: 50)
        ],
        sellOrders: [],
        amountInput: "200",
        priceInput: "1.1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(75)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(150))),
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.give match-many-and-create giveDiv=false getDiv=false",
        priceType: PriceType.give,
        amountType: AmountType.get,
        giveDivisible: false,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100,
              giveRemaining: 150,
              getRemaining: 75),
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 100,
              giveRemaining: 50,
              getRemaining: 50)
        ],
        sellOrders: [],
        amountInput: "210",
        priceInput: "1.1",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(75)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(150))),
          SimulatedOrderMatch(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(50))),
          SimulatedOrderCreate(
              give: AssetQuantity(divisible: false, quantity: BigInt.from(11)),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(10))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-only giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 100 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.get create-only giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-many giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 100 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 130 * TenToTheEigth.value,
              getQuantity: 130 * TenToTheEigth.value,
              giveRemaining: 130 * TenToTheEigth.value,
              getRemaining: 130 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "230",
        priceInput: "1.0",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(130) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(130) * TenToTheEigth.bigIntValue)),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-many-partial giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 100 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 130 * TenToTheEigth.value,
              getQuantity: 130 * TenToTheEigth.value,
              giveRemaining: 130 * TenToTheEigth.value,
              getRemaining: 130 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "225.5",
        priceInput: "1.0",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
          SimulatedOrderMatch(
            give: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(125.5 * TenToTheEigth.value)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(125.5 * TenToTheEigth.value)),
          )
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-many-and-create giveDiv=true getDiv=true",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: true,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200 * TenToTheEigth.value,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 100 * TenToTheEigth.value,
              getRemaining: 50 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 130 * TenToTheEigth.value,
              getQuantity: 130 * TenToTheEigth.value,
              giveRemaining: 130 * TenToTheEigth.value,
              getRemaining: 130 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "250",
        priceInput: ".9",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
          SimulatedOrderMatch(
            give: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(130 * TenToTheEigth.value)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(130 * TenToTheEigth.value)),
          ),
          SimulatedOrderCreate(
            give: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(20 / .9 * TenToTheEigth.value)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(20 * TenToTheEigth.value)),
          )
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-only giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 100,
              getRemaining: 50 * TenToTheEigth.value)
        ],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(100))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.get create-only giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [],
        sellOrders: [],
        amountInput: "100",
        priceInput: "2.0",
        expectedOrders: [
          SimulatedOrderCreate(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(100))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-many giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 100,
              getRemaining: 50 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 30,
              getRemaining: 30 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "130",
        priceInput: "1.0",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(100))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(30) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(30))),
        ]),
    TestCase(
        description:
            "AmountType.get-PriceType.get match-many-partial giveDiv=true getDiv=false",
        priceType: PriceType.get,
        amountType: AmountType.get,
        giveDivisible: true,
        getDivisible: false,
        buyOrders: [
          FakeOrder(
              giveQuantity: 200,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 100,
              getRemaining: 50 * TenToTheEigth.value),
          FakeOrder(
              giveQuantity: 100,
              getQuantity: 100 * TenToTheEigth.value,
              giveRemaining: 30,
              getRemaining: 30 * TenToTheEigth.value),
        ],
        sellOrders: [],
        amountInput: "120",
        priceInput: "1.0",
        expectedOrders: [
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(50) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(100))),
          SimulatedOrderMatch(
              give: AssetQuantity(
                  divisible: true,
                  quantity: BigInt.from(20) * TenToTheEigth.bigIntValue),
              get: AssetQuantity(divisible: false, quantity: BigInt.from(20))),
        ]),
    TestCase(
      description:
          "AmountType.get-PriceType.get match-only giveDiv=false getDiv=true",
      priceType: PriceType.get,
      amountType: AmountType.get,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200 * TenToTheEigth.value,
            getQuantity: 100,
            giveRemaining: 100 * TenToTheEigth.value,
            getRemaining: 50)
      ],
      sellOrders: [],
      amountInput: "100",
      priceInput: "2.0",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
      ],
    ),
    TestCase(
      description:
          "AmountType.get-PriceType.get create-only giveDiv=false getDiv=true",
      priceType: PriceType.get,
      amountType: AmountType.get,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [],
      sellOrders: [],
      amountInput: "100",
      priceInput: "2.0",
      expectedOrders: [
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
      ],
    ),
    TestCase(
      description:
          "AmountType.get-PriceType.get match-many giveDiv=false getDiv=true",
      priceType: PriceType.get,
      amountType: AmountType.get,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200 * TenToTheEigth.value,
            getQuantity: 100,
            giveRemaining: 100 * TenToTheEigth.value,
            getRemaining: 50),
        FakeOrder(
            giveQuantity: 50 * TenToTheEigth.value,
            getQuantity: 50,
            giveRemaining: 50 * TenToTheEigth.value,
            getRemaining: 50)
      ],
      sellOrders: [],
      amountInput: "150",
      priceInput: "1.0",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(50) * TenToTheEigth.bigIntValue)),
      ],
    ),
    TestCase(
      description:
          "AmountType.get-PriceType.get match-many-partial giveDiv=false getDiv=true",
      priceType: PriceType.get,
      amountType: AmountType.get,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200 * TenToTheEigth.value,
            getQuantity: 100,
            giveRemaining: 100 * TenToTheEigth.value,
            getRemaining: 50),
        FakeOrder(
            giveQuantity: 50 * TenToTheEigth.value,
            getQuantity: 50,
            giveRemaining: 50 * TenToTheEigth.value,
            getRemaining: 50)
      ],
      sellOrders: [],
      amountInput: "125",
      priceInput: "1.0",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(25)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(25) * TenToTheEigth.bigIntValue)),
      ],
    ),
    TestCase(
      description:
          "AmountType.get-PriceType.get match-many-and-create giveDiv=false getDiv=true",
      priceType: PriceType.get,
      amountType: AmountType.get,
      giveDivisible: false,
      getDivisible: true,
      buyOrders: [
        FakeOrder(
            giveQuantity: 200 * TenToTheEigth.value,
            getQuantity: 100,
            giveRemaining: 100 * TenToTheEigth.value,
            getRemaining: 50),
        FakeOrder(
            giveQuantity: 50 * TenToTheEigth.value,
            getQuantity: 50,
            giveRemaining: 50 * TenToTheEigth.value,
            getRemaining: 50)
      ],
      sellOrders: [],
      amountInput: "160",
      priceInput: ".5",
      expectedOrders: [
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(100) * TenToTheEigth.bigIntValue)),
        SimulatedOrderMatch(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(50)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(50) * TenToTheEigth.bigIntValue)),
        SimulatedOrderCreate(
            give: AssetQuantity(divisible: false, quantity: BigInt.from(20)),
            get: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(10) * TenToTheEigth.bigIntValue)),
      ],
    ),
    // TestCase(
    //     description:
    //         "AmountType.get-PriceType.get match-only giveDiv=false getDiv=false",
    //     priceType: PriceType.get,
    //     amountType: AmountType.get,
    //     giveDivisible: false,
    //     getDivisible: false,
    //     buyOrders: [
    //       FakeOrder(
    //           giveQuantity: 100,
    //           getQuantity: 200,
    //           giveRemaining: 100,
    //           getRemaining: 200)
    //     ],
    //     sellOrders: [],
    //     amountInput: "200",
    //     priceInput: "2.0",
    //     expectMatch: true,
    //     expectCreate: false),
    // TestCase(
    //     description:
    //         "AmountType.get-PriceType.get create-only giveDiv=false getDiv=false",
    //     priceType: PriceType.get,
    //     amountType: AmountType.get,
    //     giveDivisible: false,
    //     getDivisible: false,
    //     buyOrders: [],
    //     sellOrders: [],
    //     amountInput: "200",
    //     priceInput: "2.0",
    //     expectMatch: false,
    //     expectCreate: true),
    // TestCase(
    //     description:
    //         "AmountType.get-PriceType.get match and create giveDiv=false getDiv=false",
    //     priceType: PriceType.get,
    //     amountType: AmountType.get,
    //     giveDivisible: false,
    //     getDivisible: false,
    //     buyOrders: [
    //       FakeOrder(
    //           giveQuantity: 100,
    //           getQuantity: 200,
    //           giveRemaining: 100,
    //           getRemaining: 200)
    //     ],
    //     sellOrders: [],
    //     amountInput: "300",
    //     priceInput: "2.0",
    //     expectMatch: true,
    //     expectCreate: false)
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
            'giveDiv=${testCase.giveDivisible}, getDiv=${testCase.getDivisible}, amount=${testCase.amountType}, price=${testCase.priceType}',
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

          if (bloc.state.amountType != testCase.amountType) {
            bloc.add(AmountTypeClicked());
          }
          if (bloc.state.priceType != testCase.priceType) {
            bloc.add(PriceTypeClicked());
          }

          bloc.add(AmountInputChanged(value: testCase.amountInput));
          bloc.add(PriceInputChanged(value: testCase.priceInput));

          return bloc;
        },
        act: (bloc) => bloc..add(SimulatedOrdersRequested()),
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          final state = bloc.state;

          print("priceType: ${state.priceType}");
          print("state ${state.simulatedOrders}");
          state.simulatedOrders.maybeWhen(
            onSuccess: (actual) {
              // how do i use this here

              print("expected: ${testCase.expectedOrders}");
              print("  actual: $actual");
              expect(actual, equalsSimulatedOrders(testCase.expectedOrders));
            },
            orElse: () => fail(
                'Expected success with orders but got: ${state.simulatedOrders}'),
          );
        },
      );
    }
  });
}
