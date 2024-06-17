import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/send.dart' as entity;
import 'package:horizon/domain/repositories/address_tx_repository.dart';

class HistoryTable extends StatefulWidget {
  final String address;
  const HistoryTable({super.key, required this.address});
  @override
  _HistoryTableState createState() => _HistoryTableState();
}

class _HistoryTableState extends State<HistoryTable> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _data = [];
  List<entity.Send> _sends = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 1, length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      fetchData(_tabController.index + 1);
    }
  }

  Future<void> fetchData(int tabId) async {
    print('ARE WE FETCHING? tabId: $tabId');
    switch (tabId) {
      case 1:
        if (_sends.isNotEmpty) return;
        _sends = await GetIt.I.get<AddressTxRepository>().getSends(widget.address);
        break;
      default:
        _data = List.from(
          _sends.map(
            (item) => {'id': item.txHash, 'name': item.asset, 'age': item.quantity.toString()},
          ),
        );
    }

    setState(() {
      _sends = _sends;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
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
          _buildDataTable(),
          _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildSendsTable() {
    return SingleChildScrollView(
      child: Column(
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

  Widget _buildDataTable() {
    return SingleChildScrollView(
      child: Column(
        children: [
          DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Age')),
            ],
            rows: _data
                .map(
                  (item) => DataRow(cells: [
                    DataCell(Text(item['id'].toString())),
                    DataCell(Text(item['name'])),
                    DataCell(Text(item['age'].toString())),
                  ]),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
