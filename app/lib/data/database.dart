import 'package:drift/drift.dart';
import 'package:finance_engine/finance_engine.dart' show GoalType;

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

/// Small key-value store (risk answers, FI target age, ...). Values are JSON.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Profiles, Goals, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 -> v2: optional expense breakdown on the profile.
          if (from < 2) {
            await m.addColumn(profiles, profiles.expenseBreakdown);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
