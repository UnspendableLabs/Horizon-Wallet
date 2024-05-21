import 'package:uniparty/data/models/account.dart';
import 'package:drift/drift.dart';

part 'account_dao.g.dart';



//
// class TodoItems extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get title => text().withLength(min: 6, max: 32)();
//   TextColumn get content => text().named('body')();
//   IntColumn get category =>
//       integer().nullable().references(TodoCategory, #id)();
//   DateTimeColumn get createdAt => dateTime().nullable()();
// }
//
// class TodoCategory extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get description => text()();
// }

// @DriftAccessor(tables: [Todos]) class TodosDao extends DatabaseAccessor<MyDatabase> with _$TodosDaoMixin {
//   // this constructor is required so that the main database can create an instance
//   // of this object.
//   TodosDao(MyDatabase db) : super(db);
//
//   Stream<List<TodoEntry>> todosInCategory(Category category) {
//     if (category == null) {
//       return (select(todos)..where((t) => isNull(t.category))).watch();
//     } else {
//       return (select(todos)..where((t) => t.category.equals(category.id)))
//           .watch();
//     }
//   }
// }


// @dao
// abstract class AccountDao {
//   @Query('SELECT * FROM account')
//   Future<List<AccountModel>> findAllAccounts();
//   @Query('SELECT * FROM account WHERE uuid = :uuid')
//   Future<AccountModel?> findAccountByUuid(String uuid);
//   @insert
//   Future<void> insertAccount(AccountModel account);
//   @update
//   Future<void> updateAccount(AccountModel account);kkkkkkkkk
//   @delete
//   Future<void> deletueAccount(AccountModel account);
// }
//
//
//

// class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin { AccountDao(AppDatabase db) : super(db);
//   Future<List<AccountModel>> findAllAccounts() => select(account).get();
//   Future<AccountModel?> findAccountByUuid(String uuid) =>
//       (select(account)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
//   Future<void> insertAccount(AccountModel account) => into(this.account).insert(account);
//   Future<void> updateAccount(AccountModel account) => update(this.account).replace(account);
//   Future<void> deleteAccount(AccountModel account) => delete(this.account).delete(account);
// }
