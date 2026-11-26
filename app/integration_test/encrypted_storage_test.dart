// Runs on a real device / emulator (not in `flutter test`):
//   flutter test integration_test -d <device-id>
//
// Proves that on the actual platform the bundled SQLite has encryption,
// the key lives in the platform keystore, and data survives a reopen.
import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wealthwise_ai/data/app_repository.dart';
import 'package:wealthwise_ai/data/database_opener.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetLocalData());
  tearDown(() => resetLocalData());

  testWidgets('database is encrypted on the device and survives reopen', (tester) async {
    final db = await openAppDatabase();
    await AppRepository(db).saveProfile(FinancialProfile(
      age: 29,
      monthlyIncome: 60000,
      monthlyExpenses: 30000,
      expenseBreakdown: ExpenseBreakdown({ExpenseCategory.housing: 15000}),
    ));
    await db.close();

    // The file on disk must not be plain SQLite.
    final file = await databaseFile();
    final header = String.fromCharCodes((await file.readAsBytes()).take(15));
    expect(header, isNot('SQLite format 3'));

    // Reopen with the key from the keystore: data comes back.
    final again = await openAppDatabase();
    final state = await AppRepository(again).load();
    await again.close();
    expect(state.profile!.age, 29);
    expect(state.profile!.expenseBreakdown![ExpenseCategory.housing], 15000);
  });

  testWidgets('a lost key cannot open the data', (tester) async {
    final db = await openAppDatabase();
    await AppRepository(db).saveProfile(
        const FinancialProfile(age: 40, monthlyIncome: 1, monthlyExpenses: 1));
    await db.close();

    // Simulate a lost keystore entry: a new random key is generated.
    await const DatabaseKeyStore().delete();
    await expectLater(openAppDatabase(), throwsA(anything));
  });
}
