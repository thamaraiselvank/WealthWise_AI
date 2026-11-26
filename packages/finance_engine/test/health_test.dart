import 'package:finance_engine/finance_engine.dart';
import 'package:test/test.dart';

void main() {
  const example = FinancialProfile(
    age: 25,
    monthlyIncome: 40000,
    monthlyExpenses: 25000,
    savings: 80000,
    investments: 20000,
  );

  test('worked example basics', () {
    final r = HealthAnalyzer.analyze(example);
    expect(r.monthlySurplus, 15000);
    expect(r.savingsRate, closeTo(0.375, 1e-9));
    expect(r.emergencyTarget, 150000);
    expect(r.emergencyGap, 70000);
    expect(r.emergencyMonthsCovered, closeTo(3.2, 1e-9));
    expect(r.debtToIncome, 0);
  });

  test('worked example score breakdown', () {
    final r = HealthAnalyzer.analyze(example);
    // 30 savings + 25*(3.2/6)=13.33 emergency + 25 debt + 10 term (no dependents) + 0 health
    expect(r.score, 78);
    expect(r.band, HealthBand.good);
    expect(r.actions.map((a) => a.title),
        containsAll(['Get health insurance', 'Build your emergency fund']));
  });

  test('perfect profile scores 100 with a next-step action', () {
    const p = FinancialProfile(
      age: 30,
      monthlyIncome: 100000,
      monthlyExpenses: 40000,
      savings: 300000,
      dependents: 2,
      hasHealthInsurance: true,
      hasTermInsurance: true,
    );
    final r = HealthAnalyzer.analyze(p);
    expect(r.score, 100);
    expect(r.band, HealthBand.excellent);
    expect(r.actions.single.title, 'Start goal-based investing');
  });

  test('overspending and heavy EMI are flagged first', () {
    const p = FinancialProfile(
      age: 35,
      monthlyIncome: 50000,
      monthlyExpenses: 30000,
      monthlyEmi: 25000,
      dependents: 1,
    );
    final r = HealthAnalyzer.analyze(p);
    expect(r.monthlySurplus, -5000);
    expect(r.actions.first.title, 'Spending is more than income');
    expect(r.actions[1].title, 'High EMI burden');
    expect(r.actions.map((a) => a.title), contains('Consider term life insurance'));
    expect(r.band, HealthBand.needsAttention);
  });

  test('emergency target includes EMIs', () {
    const p = FinancialProfile(
      age: 30,
      monthlyIncome: 60000,
      monthlyExpenses: 20000,
      monthlyEmi: 10000,
    );
    expect(HealthAnalyzer.analyze(p).emergencyTarget, 180000);
  });

  test('zero income does not crash', () {
    const p = FinancialProfile(age: 22, monthlyIncome: 0, monthlyExpenses: 0);
    final r = HealthAnalyzer.analyze(p);
    expect(r.savingsRate, 0);
    expect(r.score, inInclusiveRange(0, 100));
  });
}
