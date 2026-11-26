import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wealthwise_ai/data/app_repository.dart';
import 'package:wealthwise_ai/data/database.dart';
import 'package:wealthwise_ai/data/database_opener.dart';

const _profile = FinancialProfile(
  age: 25,
  monthlyIncome: 40000,
  monthlyExpenses: 25000,
  savings: 80000,
  investments: 20000,
  dependents: 1,
  hasHealthInsurance: true,
);

const _goal = Goal(
  id: 'g1',
  name: 'House',
  type: GoalType.house,
  todayCost: 1500000,
  years: 8,
  alreadySaved: 100000,
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('AppRepository', () {
    late AppDatabase db;
    late AppRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = AppRepository(db);
    });
    tearDown(() => db.close());

    test('empty database means not onboarded', () async {
      expect((await repo.load()).isOnboarded, isFalse);
    });

    test('onboarding round-trips', () async {
      await repo.saveOnboarding(
        profile: _profile,
        riskAnswers: {'drop': 2, 'goal': 2},
        fiTargetAge: 45,
      );
      final s = await repo.load();
      expect(s.profile!.monthlyIncome, 40000);
      expect(s.profile!.dependents, 1);
      expect(s.profile!.hasHealthInsurance, isTrue);
      expect(s.riskAnswers, {'drop': 2, 'goal': 2});
      expect(s.fiTargetAge, 45);
    });

    test('expense breakdown round-trips and can be cleared', () async {
      final b = ExpenseBreakdown({ExpenseCategory.housing: 12000, ExpenseCategory.food: 6000});
      await repo.saveProfile(FinancialProfile(
          age: 30, monthlyIncome: 50000, monthlyExpenses: 18000, expenseBreakdown: b));
      expect((await repo.load()).profile!.expenseBreakdown, b);
      expect(((await repo.exportData())['profile'] as Map)['expenseBreakdown'],
          {'housing': 12000.0, 'food': 6000.0});

      await repo.saveProfile(_profile);
      expect((await repo.load()).profile!.expenseBreakdown, isNull);
    });

    test('goals: insert, update, delete, keep order', () async {
      await repo.saveProfile(_profile);
      await repo.upsertGoal(_goal);
      await repo.upsertGoal(const Goal(
          id: 'g2', name: 'Car', type: GoalType.car, todayCost: 800000, years: 3));
      await repo.upsertGoal(const Goal(
          id: 'g1', name: 'Bigger house', type: GoalType.house, todayCost: 2000000, years: 8));

      var goals = (await repo.load()).goals;
      expect(goals.map((g) => g.id), ['g1', 'g2']);
      expect(goals.first.name, 'Bigger house');
      expect(goals.first.type, GoalType.house);

      await repo.deleteGoal('g1');
      goals = (await repo.load()).goals;
      expect(goals.map((g) => g.id), ['g2']);
    });

    test('deleteAll wipes everything', () async {
      await repo.saveOnboarding(profile: _profile, riskAnswers: {}, fiTargetAge: 50);
      await repo.upsertGoal(_goal);
      await repo.deleteAll();
      final s = await repo.load();
      expect(s.isOnboarded, isFalse);
      expect(s.goals, isEmpty);
    });

    test('export contains profile and goals but nothing extra', () async {
      await repo.saveOnboarding(profile: _profile, riskAnswers: {'drop': 1}, fiTargetAge: 50);
      await repo.upsertGoal(_goal);
      final json = await repo.exportData();
      expect(json['app'], 'WealthWise AI');
      expect((json['profile'] as Map)['monthlyIncome'], 40000);
      expect((json['goals'] as List).single['name'], 'House');
      expect(json['financialIndependenceAge'], 50);
    });
  });

  group('encryption', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('ww_enc_'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('data is readable only with the right key', () async {
      final file = File('${dir.path}/test.db');
      final key = DatabaseKeyStore.generateKey();

      final db = AppDatabase(NativeDatabase(file, setup: (r) => applyEncryptionKey(r, key)));
      await AppRepository(db).saveProfile(_profile);
      await db.close();

      // File content must not contain SQLite's plain-text header.
      final bytes = file.readAsBytesSync();
      expect(String.fromCharCodes(bytes.take(15)), isNot('SQLite format 3'));

      // Right key: data comes back.
      final again = AppDatabase(NativeDatabase(file, setup: (r) => applyEncryptionKey(r, key)));
      expect((await AppRepository(again).load()).profile!.age, 25);
      await again.close();

      // Wrong key: refuses to open.
      final wrong = DatabaseKeyStore.generateKey();
      expect(() => _rawOpen(file, (r) => applyEncryptionKey(r, wrong)), throwsA(isA<SqliteException>()));

      // No key: refuses to read.
      expect(() => _rawOpen(file, (_) {}), throwsA(isA<SqliteException>()));
    });

    test('rejects malformed keys', () {
      final raw = sqlite3.openInMemory();
      addTearDown(raw.close);
      expect(() => applyEncryptionKey(raw, "abc' ; DROP"), throwsArgumentError);
    });

    test('generated keys are 64 hex chars and unique', () {
      final a = DatabaseKeyStore.generateKey();
      final b = DatabaseKeyStore.generateKey();
      expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(a, isNot(b));
    });
  });
}

void _rawOpen(File file, void Function(Database) setup) {
  final raw = sqlite3.open(file.path);
  try {
    setup(raw);
    raw.select('SELECT * FROM profiles');
  } finally {
    raw.close();
  }
}
