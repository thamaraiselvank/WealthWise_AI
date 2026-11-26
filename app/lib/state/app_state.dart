import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory app state. Persistence (encrypted SQLite via drift) comes in
/// the next Phase 1 slice.
class AppState {
  final FinancialProfile? profile;
  final Map<String, int> riskAnswers;
  final RiskProfile risk;
  final int fiTargetAge;
  final List<Goal> goals;

  const AppState({
    this.profile,
    this.riskAnswers = const {},
    this.risk = RiskProfile.moderate,
    this.fiTargetAge = 55,
    this.goals = const [],
  });

  AppState copyWith({
    FinancialProfile? profile,
    Map<String, int>? riskAnswers,
    RiskProfile? risk,
    int? fiTargetAge,
    List<Goal>? goals,
  }) =>
      AppState(
        profile: profile ?? this.profile,
        riskAnswers: riskAnswers ?? this.riskAnswers,
        risk: risk ?? this.risk,
        fiTargetAge: fiTargetAge ?? this.fiTargetAge,
        goals: goals ?? this.goals,
      );
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => const AppState();

  void completeOnboarding({
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
  }

  void setFiTargetAge(int age) => state = state.copyWith(fiTargetAge: age);

  void addGoal(Goal goal) => state = state.copyWith(goals: [...state.goals, goal]);

  void removeGoal(String id) =>
      state = state.copyWith(goals: state.goals.where((g) => g.id != id).toList());
}

final appStateProvider =
    NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

final healthReportProvider = Provider<HealthReport?>((ref) {
  final p = ref.watch(appStateProvider).profile;
  return p == null ? null : HealthAnalyzer.analyze(p);
});

/// Id used for the built-in financial-independence goal.
const fiGoalId = 'fi';

final fiPlanProvider = Provider<GoalPlan?>((ref) {
  final s = ref.watch(appStateProvider);
  final p = s.profile;
  if (p == null || s.fiTargetAge <= p.age) return null;
  return GoalPlanner.planIndependence(p, targetAge: s.fiTargetAge, risk: s.risk);
});

final goalPlansProvider = Provider<List<GoalPlan>>((ref) {
  final s = ref.watch(appStateProvider);
  final p = s.profile;
  if (p == null) return const [];
  return [
    for (final g in s.goals)
      GoalPlanner.plan(g, risk: s.risk, availableMonthly: p.monthlySurplus),
  ];
});
