import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthwise_ai/data/app_repository.dart';
import 'package:wealthwise_ai/data/database.dart';

import '../generated_migrations/schema.dart';

/// Guards upgrades for people who already have data on their phone.
/// When bumping schemaVersion: dump the schema (see CLAUDE.md), regenerate
/// test/generated_migrations, and add a case here.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in [1, 2]) {
    test('v$from -> v3 produces the expected schema', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 3);
      await db.close();
    });
  }

  test('v1 data survives the upgrade to the latest version', () async {
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute(
      'INSERT INTO profiles (id, age, monthly_income, monthly_expenses, dependents) '
      'VALUES (1, 30, 50000, 20000, 2)',
    );
    schema.rawDatabase.execute(
      "INSERT INTO goals (id, name, type, today_cost, years) "
      "VALUES ('g1', 'Car', 'car', 800000, 3)",
    );

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    final state = await AppRepository(db).load();
    await db.close();

    expect(state.profile!.age, 30);
    expect(state.profile!.dependents, 2);
    expect(state.profile!.expenseBreakdown, isNull);
    expect(state.goals.single.name, 'Car');
  });

  test('v2 users keep their totals and stay in quick mode on v3', () async {
    final schema = await verifier.schemaAt(2);
    schema.rawDatabase.execute(
      'INSERT INTO profiles (id, age, monthly_income, monthly_expenses, monthly_emi, '
      'savings, investments, loan_outstanding, expense_breakdown) '
      "VALUES (1, 32, 90000, 40000, 12000, 150000, 300000, 600000, '{\"food\":10000}')",
    );

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    final p = (await AppRepository(db).load()).profile!;
    await db.close();

    expect(p.balanceSheet, isNull);
    expect(p.savings, 150000);
    expect(p.investments, 300000);
    expect(p.loanOutstanding, 600000);
    expect(p.monthlyEmi, 12000);
    expect(p.expenseBreakdown!.total, 10000);
  });
}
