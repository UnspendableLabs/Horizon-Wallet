import 'package:test/test.dart';
import 'package:drift_dev/api/migrations.dart';
import "package:horizon/data/sources/local/db.dart";

import 'drift_migrations/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    // GeneratedHelper() was generated by drift, the verifier is an api
    // provided by drift_dev.
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('upgrade from v1 to v2', () async {
    // Use startAt(1) to obtain a database connection with all tables
    // from the v1 schema.
    final connection = await verifier.startAt(1);

    final db = DB(connection);

    // Use this to run a migration to v2 and then validate that the
    // database has the expected schema.
    await verifier.migrateAndValidate(db, 2);

    await db.close();
  });

  test('upgrade from v2 to v3', () async {
    // Use startAt(1) to obtain a database connection with all tables
    // from the v1 schema.
    final connection = await verifier.startAt(2);
    final db = DB(connection);

    // Use this to run a migration to v2 and then validate that the
    // database has the expected schema.
    await verifier.migrateAndValidate(db, 3);
    await db.close();
  });

  test('upgrade from v3 to v4', () async {
    final connection = await verifier.startAt(3);
    final db = DB(connection);

    await verifier.migrateAndValidate(db, 4);
    await db.close();
  });

  test('upgrade from v4 to v5', () async {
    final connection = await verifier.startAt(4);
    final db = DB(connection);

    await verifier.migrateAndValidate(db, 5);
    await db.close();
  });

  test('upgrade from v5 to v6', () async {
    final connection = await verifier.startAt(5);
    final db = DB(connection);

    await verifier.migrateAndValidate(db, 6);
    await db.close();
  });
}
