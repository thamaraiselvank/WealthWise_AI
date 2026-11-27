import 'package:drift/drift.dart';
import 'package:finance_engine/finance_engine.dart' show AssetType, GoalType, LoanType;

part 'database.g.dart';

/// Single-row table (id = 1) holding the user's financial snapshot.
@DataClassName('ProfileRow')
class Profiles extends Table {
  IntColumn get id => integer()();
  IntColumn get age => integer()();
  RealColumn get monthlyIncome => real()();
  RealColumn get monthlyExpenses => real()();
  RealColumn get monthlyEmi => real().withDefault(const Constant(0))();
  RealColumn get savings => real().withDefault(const Constant(0))();
  RealColumn get investments => real().withDefault(const Constant(0))();
  RealColumn get loanOutstanding => real().withDefault(const Constant(0))();
  IntColumn get dependents => integer().withDefault(const Constant(0))();
  BoolColumn get hasHealthInsurance => boolean().withDefault(const Constant(false))();
  BoolColumn get hasTermInsurance => boolean().withDefault(const Constant(false))();

  /// JSON map of ExpenseCategory name -> monthly amount (added in schema v2).
  TextColumn get expenseBreakdown => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<GoalType>()();
  RealColumn get todayCost => real()();
  RealColumn get years => real()();
  RealColumn get alreadySaved => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Itemised assets (detailed mode, added in schema v3). Empty = quick mode.
@DataClassName('AssetRow')
class Assets extends Table {
  TextColumn get id => text()();
  TextColumn get type => textEnum<AssetType>()();
  TextColumn get label => text().withDefault(const Constant(''))();
  RealColumn get value => real()();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Itemised loans (detailed mode, added in schema v3).
@DataClassName('LoanRow')
class Loans extends Table {
  TextColumn get id => text()();
  TextColumn get type => textEnum<LoanType>()();
  TextColumn get label => text().withDefault(const Constant(''))();
  RealColumn get outstanding => real()();
  RealColumn get emi => real().withDefault(const Constant(0))();

  /// Annual rate (0.09 = 9%); null when unknown.
  RealColumn get annualRate => real().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small key-value store (risk answers, FI target age, ...). Values are JSON.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Profiles, Goals, Settings, Assets, Loans])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 -> v2: optional expense breakdown on the profile.
          if (from < 2) {
            await m.addColumn(profiles, profiles.expenseBreakdown);
          }
          // v2 -> v3: itemised assets and loans. Existing users stay in quick
          // mode (their totals live on the profile row).
          if (from < 3) {
            await m.createTable(assets);
            await m.createTable(loans);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
