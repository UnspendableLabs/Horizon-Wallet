import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/issuance.dart' as issuance_entity;
import 'package:horizon/domain/entities/send.dart' as send_entity;
import 'package:horizon/domain/entities/transaction.dart' as transaction_entity;
import 'package:horizon/domain/repositories/address_tx_repository.dart';

class HistoryTable extends StatefulWidget {
  final String address;
  const HistoryTable({super.key, required this.address});
  @override
  _HistoryTableState createState() => _HistoryTableState();
}

class _HistoryTableState extends State<HistoryTable>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _data = [];
  List<send_entity.Send> _sends = [];
  List<issuance_entity.Issuance> _issuances = [];
  List<transaction_entity.Transaction> _transactions = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fetchData(0);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      fetchData(_tabController.index);
    }
  }

  Future<void> fetchData(int tabId) async {
    final addressTxRepository = GetIt.I.get<AddressTxRepository>();
    switch (tabId) {
      case 0:
        if (_sends.isNotEmpty) return;
        _sends = await addressTxRepository.getSendsByAddress(widget.address);

        setState(() {
          _sends = _sends;
        });
        break;
      case 1:
        if (_issuances.isNotEmpty) return;
        _issuances =
            await addressTxRepository.getIssuancesByAddress(widget.address);
        setState(() {
          _issuances = _issuances;
        });
        break;
      case 2:
        if (_transactions.isNotEmpty) return;
        _transactions =
            await addressTxRepository.getTransactionsByAddress(widget.address);
        setState(() {
          _transactions = _transactions;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Sends'),
            Tab(text: 'Issuances'),
            Tab(text: 'Transactions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSendsTable(),
          _buildIssuancesTable(),
          _buildTransactionsTable(),
        ],
      ),
    );
  }

  Widget _buildSendsTable() {
    if (_sends.isEmpty) return const Text('No sends at this address');
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DataTable(
            columns: const [
              DataColumn(label: Text('TxHash')),
              DataColumn(label: Text('Asset')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Status')),
            ],
            rows: _sends
                .map(
                  (item) => DataRow(cells: [
                    DataCell(Text(item.txHash)),
                    DataCell(Text(item.asset)),
                    DataCell(Text(item.quantity.toString())),
                    DataCell(Text(item.status)),
                  ]),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuancesTable() {
    if (_issuances.isEmpty) return const Text('No issuances at this address');
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DataTable(
            columns: const [
              DataColumn(label: Text('TxHash')),
              DataColumn(label: Text('Asset')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Status')),
            ],
            rows: _issuances
                .map(
                  (item) => DataRow(cells: [
                    DataCell(Text(item.txHash)),
                    DataCell(Text(item.asset)),
                    DataCell(Text(item.quantity.toString())),
                    DataCell(Text(item.status)),
                  ]),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable() {
    if (_transactions.isEmpty) {
      return const Text('No transactions at this address');
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DataTable(
            columns: const [
              DataColumn(label: Text('TxHash')),
              DataColumn(label: Text('Source')),
              DataColumn(label: Text('Destination')),
              DataColumn(label: Text('BTC Amount')),
            ],
            rows: _transactions
                .map(
                  (item) => DataRow(cells: [
                    DataCell(SizedBox(
                      width: 100,
                      child: Text(item.txHash ?? "",
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1),
                    )),
                    DataCell(Text(item.source)),
                    DataCell(Text(item.destination ?? "")),
                    DataCell(Text(item.btcAmount.toString())),
                  ]),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
