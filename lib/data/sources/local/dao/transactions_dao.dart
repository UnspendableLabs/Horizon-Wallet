import 'package:drift/drift.dart';
import 'package:horizon/data/models/transaction.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/transactions_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<DB> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<int> deleteByHash(String txHash) async {
    return (delete(transactions)..where((t) => t.hash.equals(txHash))).go();
  }

  Future<void> insert(TransactionModel transaction) {
    return into(transactions).insert(transaction);
  }

  Future<List<TransactionModel>> getAll() => select(transactions).get();

  Future<List<TransactionModel>> getAllBySources(List<String> sources) {
    return (select(transactions)..where((tbl) => tbl.source.isIn(sources)))
        .get();
  }

  Future<List<TransactionModel>> getAllBySourcesAfterDate(
    List<String> sources,
    DateTime date,
  ) {
    return (select(transactions)
          ..where((row) {
            final matchesSources = row.source.isIn(sources);
            final matchesDate = row.submittedAt.isBiggerOrEqualValue(date);
            return matchesDate & matchesSources;
          }))
        .get();
  }

  Future<void> deleteAllTransactions() {
    return delete(transactions).go();
  }
}
