import 'package:drift/drift.dart';
import 'package:horizon/data/models/transaction.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/tables/transactions_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<DB> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);
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

            print("data: ${row.submittedAt} date: $date");
            print("matchesSources: $matchesSources matchesDate: $matchesDate");

  
            print('Transaction Details:');
            print('  Row submitted at: ${row.submittedAt}');
            print('  Comparison date: $date');
            print('  Matches sources: $matchesSources');
            print('  Matches or after date: $matchesDate');
            print('  Sources: $sources');
            print('  Row source: ${row.source}');
            print('---');

            return matchesSources & matchesDate;
          }))
        .get();
  }
}
