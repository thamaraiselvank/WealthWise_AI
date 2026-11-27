import 'package:finance_engine/finance_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_repository.dart';

/// Everything the UI needs about the user. Loaded from the encrypted local
/// database at startup and written through on every change.
@immutable
class AppState {
  final FinancialProfile? profile;
  final Map<String, int> riskAnswers;
  final RiskProfile risk;
  final int fiTargetAge;
  final List<Goal> goals;

  /// The user's planning assumptions (defaults unless edited in Settings).
  final Assumptions assumptions;

  const AppState({
    this.profile,
    this.riskAnswers = const {},
    this.risk = RiskProfile.moderate,
    this.fiTargetAge = 55,
    this.goals = const [],
    this.assumptions = Assumptions.standard,
  });

  bool get isOnboarded => profile != null;

  AppState copyWith({
    FinancialProfile? profile,
    Map<String, int>? riskAnswers,
    RiskProfile? risk,
    int? fiTargetAge,
    List<Goal>? goals,
    Assumptions? assumptions,
  }) =>
      AppState(
        profile: profile ?? this.profile,
        riskAnswers: riskAnswers ?? this.riskAnswers,
        risk: risk ?? this.risk,
        fiTargetAge: fiTargetAge ?? this.fiTargetAge,
        goals: goals ?? this.goals,
        assumptions: assumptions ?? this.assumptions,
      );
}

/// Provided in main() (or tests) via overrides.
final repositoryProvider = Provider<AppRepository>(
  (ref) => throw UnimplementedError('repositoryProvider must be overridden'),
);

/// State loaded from the database before the first frame.
final initialAppStateProvider = Provider<AppState>((ref) => const AppState());

/// UI state is updated immediately; the write to the database follows.
class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => ref.read(initialAppStateProvider);

  AppRepository get _repo => ref.read(repositoryProvider);

  Future<void> completeOnboarding({
    required FinancialProfile profile,
    required Map<String, int> riskAnswers,
    required int fiTargetAge,
  }) {
    state = state.copyWith(
      profile: profile,
      riskAnswers: riskAnswers,
      risk: RiskQuestionnaire.score(riskAnswers),
      fiTargetAge: fiTargetAge,
    );
    return _repo.saveOnboarding(
        profile: profile, riskAnswers: riskAnswers, fiTargetAge: fiTargetAge);
  }

  Future<void> updateProfile(FinancialProfile profile) {
    // Keep the FI age valid if the user's age changed.
    final fiAge = state.fiTargetAge <= profile.age
        ? (profile.age + 1).clamp(profile.age + 1, 75)
        : state.fiTargetAge;
    state = state.copyWith(profile: profile, fiTargetAge: fiAge);
    return Future.wait([
      _repo.saveProfile(profile),
      _repo.saveFiTargetAge(fiAge),
    ]);
  }

  Future<void> updateRiskAnswers(Map<String, int> answers) {
    state = state.copyWith(
        riskAnswers: answers, risk: RiskQuestionnaire.score(answers));
    return _repo.saveRiskAnswers(answers);
  }

  Future<void> setFiTargetAge(int age) {
    state = state.copyWith(fiTargetAge: age);
    return _repo.saveFiTargetAge(age);
  }

  /// Adds a new goal or replaces one with the same id.
  Future<void> saveGoal(Goal goal) {
    final exists = state.goals.any((g) => g.id == goal.id);
    state = state.copyWith(
      goals: exists
          ? [for (final g in state.goals) g.id == goal.id ? goal : g]
          : [...state.goals, goal],
    );
    return _repo.upsertGoal(goal);
  }

  Future<void> removeGoal(String id) {
    state = state.copyWith(goals: state.goals.where((g) => g.id != id).toList());
    return _repo.deleteGoal(id);
  }

  Future<void> setAssumptions(Assumptions a) {
    state = state.copyWith(assumptions: a);
    return _repo.saveAssumptions(a);
  }

  Future<void> resetAssumptions() => setAssumptions(Assumptions.standard);

  Future<void> deleteAllData() async {
    await _repo.deleteAll();
    state = const AppState();
  }
}

final appStateProvider =
    NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

final healthReportProvider = Provider<HealthReport?>((ref) {
  final s = ref.watch(appStateProvider);
  final p = s.profile;
  return p == null ? null : HealthAnalyzer.analyze(p, a: s.assumptions);
});

/// Id used for the built-in financial-independence goal.
const fiGoalId = 'fi';

final fiPlanProvider = Provider<GoalPlan?>((ref) {
  final s = ref.watch(appStateProvider);
  final p = s.profile;
  if (p == null || s.fiTargetAge <= p.age) return null;
  return GoalPlanner.planIndependence(p,
      targetAge: s.fiTargetAge, risk: s.risk, a: s.assumptions);
});

final goalPlansProvider = Provider<List<GoalPlan>>((ref) {
  final s = ref.watch(appStateProvider);
  final p = s.profile;
  if (p == null) return const [];
  return [
    for (final g in s.goals)
      GoalPlanner.plan(g,
          risk: s.risk, availableMonthly: p.monthlySurplus, a: s.assumptions),
  ];
});
