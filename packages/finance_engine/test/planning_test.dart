import 'package:finance_engine/finance_engine.dart';
import 'package:test/test.dart';

void main() {
  group('RiskQuestionnaire', () {
    test('all cautious answers → conservative', () {
      final a = {for (final q in RiskQuestionnaire.questions) q.id: 0};
      expect(RiskQuestionnaire.score(a), RiskProfile.conservative);
    });
    test('all middle / unanswered → moderate', () {
      expect(RiskQuestionnaire.score({}), RiskProfile.moderate);
    });
    test('all bold answers → aggressive', () {
      final a = {for (final q in RiskQuestionnaire.questions) q.id: 2};
      expect(RiskQuestionnaire.score(a), RiskProfile.aggressive);
    });
  });

  group('AllocationPlanner', () {
    test('always sums to 100', () {
      for (final risk in RiskProfile.values) {
        for (final y in [0.5, 2.0, 4.0, 6.0, 10.0, 25.0]) {
          final a = AllocationPlanner.suggest(risk, y);
          expect(a.total, 100, reason: '$risk $y');
          expect(a.reasons, isNotEmpty);
        }
      }
    });

    test('short horizons have no equity', () {
      expect(AllocationPlanner.suggest(RiskProfile.aggressive, 2).equity, 0);
      expect(AllocationPlanner.suggest(RiskProfile.aggressive, 0.5).equity, 0);
    });

    test('equity capped for medium horizons', () {
      expect(AllocationPlanner.suggest(RiskProfile.aggressive, 4).equity, 35);
      expect(AllocationPlanner.suggest(RiskProfile.aggressive, 6).equity, 55);
    });

    test('long horizon uses the risk base', () {
      expect(AllocationPlanner.suggest(RiskProfile.conservative, 15).equity, 30);
      expect(AllocationPlanner.suggest(RiskProfile.moderate, 15).equity, 55);
      expect(AllocationPlanner.suggest(RiskProfile.aggressive, 15).equity, 75);
    });

    test('expected return is a weighted average', () {
      const a = Allocation(equity: 50, debt: 50, gold: 0, cash: 0);
      expect(a.expectedReturn(Assumptions.standard), closeTo(0.0875, 1e-9));
    });
  });

  group('GoalPlanner', () {
    test('house goal: inflates cost and round-trips the SIP', () {
      const goal = Goal(
        id: 'h',
        name: 'House down payment',
        type: GoalType.house,
        todayCost: 1500000,
        years: 8,
      );
      final plan = GoalPlanner.plan(goal,
          risk: RiskProfile.moderate, availableMonthly: 100000);
      expect(plan.futureCost,
          closeTo(MoneyMath.inflate(1500000, 0.06, 8), 0.01));
      expect(
        MoneyMath.sipFutureValue(plan.requiredSip, plan.assumedReturn, 8),
        closeTo(plan.futureCost, 1),
      );
      expect(plan.requiredSipWithStepUp, lessThan(plan.requiredSip));
      expect(plan.feasibility, Feasibility.onTrack);
      expect(plan.steps, isNotEmpty);
    });

    test('feasibility bands', () {
      const goal = Goal(
          id: 'g', name: 'G', type: GoalType.other, todayCost: 1000000, years: 10);
      final base = GoalPlanner.plan(goal,
          risk: RiskProfile.moderate, availableMonthly: 1e9);
      final between = (base.requiredSip + base.requiredSipWithStepUp) / 2;

      expect(
          GoalPlanner.plan(goal, risk: RiskProfile.moderate, availableMonthly: between)
              .feasibility,
          Feasibility.stretch);
      expect(
          GoalPlanner.plan(goal, risk: RiskProfile.moderate, availableMonthly: 10)
              .feasibility,
          Feasibility.notFeasible);
    });

    test('FI at 45 for the worked example is not feasible on ₹15k', () {
      const p = FinancialProfile(
        age: 25,
        monthlyIncome: 40000,
        monthlyExpenses: 25000,
        savings: 80000,
        investments: 20000,
      );
      final plan = GoalPlanner.planIndependence(p,
          targetAge: 45, risk: RiskProfile.moderate);
      expect(plan.futureCost, closeTo(2.405e7, 1e5));
      expect(plan.requiredSip, greaterThan(15000));
      expect(plan.goal.years, 20);
      expect(plan.feasibility, isNot(Feasibility.onTrack));
    });

    test('FI target age must be in the future', () {
      const p = FinancialProfile(age: 40, monthlyIncome: 1, monthlyExpenses: 1);
      expect(
        () => GoalPlanner.planIndependence(p, targetAge: 40, risk: RiskProfile.moderate),
        throwsArgumentError,
      );
    });
  });
}
