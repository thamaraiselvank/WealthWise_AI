import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:finance_engine/finance_engine.dart';

import '../state/app_state.dart';
import 'database.dart';

/// The only place that reads or writes the local database.
class AppRepository {
  AppRepository(this._db);

  final AppDatabase _db;

  static const _profileId = 1;
  static const _kRiskAnswers = 'risk_answers';
  static const _kFiTargetAge = 'fi_target_age';
  static const _kAssumptions = 'assumptions';
  static const _kAiConsent = 'ai_consent';

  Future<AppState> load() async {
    final row = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(_profileId)))
        .getSingleOrNull();
    if (row == null) return const AppState();

    final settings = {
      for (final s in await _db.select(_db.settings).get()) s.key: s.value,
    };
    final answers = _decodeAnswers(settings[_kRiskAnswers]);
    final assetRows = await (_db.select(_db.assets)
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    final loanRows = await (_db.select(_db.loans)
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    final profile = _toProfile(row, assetRows, loanRows);
    final fiAge = int.tryParse(settings[_kFiTargetAge] ?? '') ??
        (profile.age + 20).clamp(profile.age + 1, 75);

    final goals = await (_db.select(_db.goals)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt), (t) => OrderingTerm.asc(t.id)]))
        .get();

    return AppState(
      profile: profile,
      riskAnswers: answers,
      risk: RiskQuestionnaire.score(answers),
      fiTargetAge: fiAge,
      goals: goals.map(_toGoal).toList(),
      assumptions: _decodeAssumptions(settings[_kAssumptions]),
      aiConsent: settings[_kAiConsent] != null,
    );
  }

  Future<void> saveOnboarding({
    required FinancialProfile profile,
    required Map<String, int> riskAnswers,
    required int fiTargetAge,
  }) =>
      _db.transaction(() async {
        await saveProfile(profile);
        await saveRiskAnswers(riskAnswers);
        await saveFiTargetAge(fiTargetAge);
      });

  /// Saves the profile row and replaces the itemised assets / loans
  /// (none in quick mode).
  Future<void> saveProfile(FinancialProfile p) => _db.transaction(() async {
        await _saveProfileRow(p);
        await _db.delete(_db.assets).go();
        await _db.delete(_db.loans).go();
        final sheet = p.balanceSheet;
        if (sheet == null) return;
        await _db.batch((b) {
          b.insertAll(_db.assets, [
            for (final (i, a) in sheet.assets.indexed)
              AssetsCompanion.insert(
                id: a.id,
                type: a.type,
                label: Value(a.label),
                value: a.value,
                position: Value(i),
              ),
          ]);
          b.insertAll(_db.loans, [
            for (final (i, l) in sheet.loans.indexed)
              LoansCompanion.insert(
                id: l.id,
                type: l.type,
                label: Value(l.label),
                outstanding: l.outstanding,
                emi: Value(l.emi),
                annualRate: Value(l.annualRate),
                position: Value(i),
              ),
          ]);
        });
      });

  Future<void> _saveProfileRow(FinancialProfile p) =>
      _db.into(_db.profiles).insertOnConflictUpdate(ProfilesCompanion(
            id: const Value(_profileId),
            age: Value(p.age),
            monthlyIncome: Value(p.monthlyIncome),
            monthlyExpenses: Value(p.monthlyExpenses),
            monthlyEmi: Value(p.monthlyEmi),
            savings: Value(p.savings),
            investments: Value(p.investments),
            loanOutstanding: Value(p.loanOutstanding),
            dependents: Value(p.dependents),
            hasHealthInsurance: Value(p.hasHealthInsurance),
            hasTermInsurance: Value(p.hasTermInsurance),
            expenseBreakdown: Value(_encodeBreakdown(p.expenseBreakdown)),
            updatedAt: Value(DateTime.now()),
          ));

  Future<void> saveRiskAnswers(Map<String, int> answers) =>
      _setSetting(_kRiskAnswers, jsonEncode(answers));

  Future<void> saveFiTargetAge(int age) => _setSetting(_kFiTargetAge, '$age');

  /// Stores only overrides; defaults are not written so future default
  /// changes still reach users who never edited anything.
  Future<void> saveAssumptions(Assumptions a) => a.isStandard
      ? (_db.delete(_db.settings)..where((t) => t.key.equals(_kAssumptions))).go()
      : _setSetting(_kAssumptions, jsonEncode({
          for (final f in a.changedFrom()) f.name: a.valueOf(f),
        }));

  /// Stores when consent was given; withdrawing removes it.
  Future<void> saveAiConsent(bool value) => value
      ? _setSetting(_kAiConsent, DateTime.now().toUtc().toIso8601String())
      : (_db.delete(_db.settings)..where((t) => t.key.equals(_kAiConsent))).go();

  Future<void> upsertGoal(Goal g) =>
      _db.into(_db.goals).insertOnConflictUpdate(GoalsCompanion(
            id: Value(g.id),
            name: Value(g.name),
            type: Value(g.type),
            todayCost: Value(g.todayCost),
            years: Value(g.years),
            alreadySaved: Value(g.alreadySaved),
          ));

  Future<void> deleteGoal(String id) =>
      (_db.delete(_db.goals)..where((t) => t.id.equals(id))).go();

  /// Removes every row and compacts the file so deleted data is not left
  /// behind in free pages.
  Future<void> deleteAll() async {
    await _db.transaction(() async {
      for (final table in _db.allTables) {
        await _db.delete(table).go();
      }
    });
    await _db.customStatement('VACUUM');
  }

  /// Everything the app stores, as plain JSON (for "Export my data").
  Future<Map<String, Object?>> exportData() async {
    final s = await load();
    final p = s.profile;
    return {
      'app': 'WealthWise AI',
      'exportVersion': 2,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'profile': p == null
          ? null
          : {
              'age': p.age,
              'monthlyIncome': p.monthlyIncome,
              'monthlyExpenses': p.monthlyExpenses,
              'monthlyEmi': p.monthlyEmi,
              'savings': p.savings,
              'investments': p.investments,
              'loanOutstanding': p.loanOutstanding,
              'dependents': p.dependents,
              'hasHealthInsurance': p.hasHealthInsurance,
              'hasTermInsurance': p.hasTermInsurance,
              'expenseBreakdown': p.expenseBreakdown?.toJson(),
              'assets': [
                for (final a in p.balanceSheet?.assets ?? const <Asset>[])
                  {'type': a.type.name, 'label': a.label, 'value': a.value},
              ],
              'loans': [
                for (final l in p.balanceSheet?.loans ?? const <Loan>[])
                  {
                    'type': l.type.name,
                    'label': l.label,
                    'outstanding': l.outstanding,
                    'emi': l.emi,
                    'annualRate': l.annualRate,
                  },
              ],
            },
      'riskAnswers': s.riskAnswers,
      'riskProfile': s.risk.name,
      'financialIndependenceAge': s.fiTargetAge,
      'assumptions': s.assumptions.toJson(),
      'aiAssistantConsent': s.aiConsent,
      'goals': [
        for (final g in s.goals)
          {
            'id': g.id,
            'name': g.name,
            'type': g.type.name,
            'todayCost': g.todayCost,
            'years': g.years,
            'alreadySaved': g.alreadySaved,
          },
      ],
    };
  }

  Future<void> _setSetting(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion(key: Value(key), value: Value(value)));

  static Map<String, int> _decodeAnswers(String? json) {
    if (json == null) return const {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return {for (final e in map.entries) if (e.value is int) e.key: e.value as int};
    } on FormatException {
      return const {};
    }
  }

  static Assumptions _decodeAssumptions(String? json) {
    if (json == null) return Assumptions.standard;
    try {
      return Assumptions.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } on FormatException {
      return Assumptions.standard;
    } on TypeError {
      return Assumptions.standard;
    }
  }

  static FinancialProfile _toProfile(
      ProfileRow r, List<AssetRow> assetRows, List<LoanRow> loanRows) {
    if (assetRows.isEmpty && loanRows.isEmpty) return _toQuickProfile(r);
    return FinancialProfile.detailed(
      age: r.age,
      monthlyIncome: r.monthlyIncome,
      monthlyExpenses: r.monthlyExpenses,
      dependents: r.dependents,
      hasHealthInsurance: r.hasHealthInsurance,
      hasTermInsurance: r.hasTermInsurance,
      expenseBreakdown: _decodeBreakdown(r.expenseBreakdown),
      sheet: BalanceSheet(
        assets: [
          for (final a in assetRows)
            Asset(id: a.id, type: a.type, label: a.label, value: a.value),
        ],
        loans: [
          for (final l in loanRows)
            Loan(
              id: l.id,
              type: l.type,
              label: l.label,
              outstanding: l.outstanding,
              emi: l.emi,
              annualRate: l.annualRate,
            ),
        ],
      ),
    );
  }

  static FinancialProfile _toQuickProfile(ProfileRow r) => FinancialProfile(
        age: r.age,
        monthlyIncome: r.monthlyIncome,
        monthlyExpenses: r.monthlyExpenses,
        monthlyEmi: r.monthlyEmi,
        savings: r.savings,
        investments: r.investments,
        loanOutstanding: r.loanOutstanding,
        dependents: r.dependents,
        hasHealthInsurance: r.hasHealthInsurance,
        hasTermInsurance: r.hasTermInsurance,
        expenseBreakdown: _decodeBreakdown(r.expenseBreakdown),
      );

  static String? _encodeBreakdown(ExpenseBreakdown? b) =>
      (b == null || b.isEmpty) ? null : jsonEncode(b.toJson());

  static ExpenseBreakdown? _decodeBreakdown(String? json) {
    if (json == null) return null;
    try {
      final b = ExpenseBreakdown.fromJson(jsonDecode(json) as Map<String, dynamic>);
      return b.isEmpty ? null : b;
    } on FormatException {
      return null;
    }
  }

  static Goal _toGoal(GoalRow r) => Goal(
        id: r.id,
        name: r.name,
        type: r.type,
        todayCost: r.todayCost,
        years: r.years,
        alreadySaved: r.alreadySaved,
      );
}
