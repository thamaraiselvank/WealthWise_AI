import 'package:finance_engine/finance_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Assumptions', () {
    test('defaults match the documented values', () {
      const a = Assumptions.standard;
      expect(a.inflation, 0.06);
      expect(a.emergencyFundMonths, 6);
      expect(a.corpusMultiple, 25);
      expect(a.equityReturn, 0.11);
      expect(a.sipStepUp, 0.10);
      expect(a.isStandard, isTrue);
      expect(a.cautions, isEmpty);
    });

    test('every default sits inside its safe range', () {
      for (final s in AssumptionSpec.all) {
        final v = Assumptions.standard.valueOf(s.field);
        expect(v, inInclusiveRange(s.min, s.max), reason: s.label);
        expect(s.divisions, greaterThan(0), reason: s.label);
      }
      expect(AssumptionSpec.all.map((s) => s.field).toSet(),
          AssumptionField.values.toSet());
    });

    test('withValue clamps to the safe range', () {
      final a = Assumptions.standard
          .withValue(AssumptionField.equityReturn, 0.25)
          .withValue(AssumptionField.inflation, -1)
          .withValue(AssumptionField.emergencyFundMonths, 7.6);
      expect(a.equityReturn, 0.14);
      expect(a.inflation, 0.03);
      expect(a.emergencyFundMonths, 8);
    });

    test('JSON round trip, ignoring junk and clamping', () {
      final a = Assumptions.standard
          .withValue(AssumptionField.inflation, 0.07)
          .withValue(AssumptionField.corpusMultiple, 30);
      expect(Assumptions.fromJson(a.toJson()), a);

      final b = Assumptions.fromJson({
        'inflation': 0.5,
        'equityReturn': 'abc',
        'unknown': 1,
      });
      expect(b.inflation, 0.10);
      expect(b.equityReturn, 0.11);
    });

    test('describeChanges lists only changed fields', () {
      final a = Assumptions.standard.withValue(AssumptionField.inflation, 0.07);
      expect(a.changedFrom(), [AssumptionField.inflation]);
      expect(a.describeChanges(), ['Inflation 7.0% (default 6.0%)']);
    });

    test('cautions flag optimistic settings', () {
      final a = Assumptions.standard.withValue(AssumptionField.equityReturn, 0.14);
      expect(a.cautions.single, contains('Equity return of 14.0%'));
      final b = Assumptions.standard
          .withValue(AssumptionField.equityReturn, 0.06)
          .withValue(AssumptionField.inflation, 0.08);
      expect(b.cautions.single, contains('not above inflation'));
    });
  });

  group('assumptions flow into plans', () {
    const p = FinancialProfile(
        age: 25, monthlyIncome: 40000, monthlyExpenses: 25000, savings: 80000);

    test('higher inflation raises the FI corpus', () {
      final base = GoalPlanner.planIndependence(p,
          targetAge: 45, risk: RiskProfile.moderate);
      final hot = GoalPlanner.planIndependence(p,
          targetAge: 45,
          risk: RiskProfile.moderate,
          a: Assumptions.standard.withValue(AssumptionField.inflation, 0.08));
      expect(hot.futureCost, greaterThan(base.futureCost));
      expect(hot.steps[1], contains('8.0% inflation'));
    });

    test('corpus multiple and step-up come from assumptions', () {
      final a = Assumptions.standard
          .withValue(AssumptionField.corpusMultiple, 30)
          .withValue(AssumptionField.sipStepUp, 0.05);
      final plan = GoalPlanner.planIndependence(p,
          targetAge: 45, risk: RiskProfile.moderate, a: a);
      final base = GoalPlanner.planIndependence(p,
          targetAge: 45, risk: RiskProfile.moderate);
      expect(plan.futureCost / base.futureCost, closeTo(30 / 25, 1e-9));
      expect(plan.stepUp, 0.05);
    });

    test('emergency months change the health target', () {
      final r = HealthAnalyzer.analyze(p,
          a: Assumptions.standard.withValue(AssumptionField.emergencyFundMonths, 9));
      expect(r.emergencyTarget, 25000 * 9);
    });
  });
}
