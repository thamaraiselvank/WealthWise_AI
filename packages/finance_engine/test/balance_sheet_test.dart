import 'dart:math' as math;

import 'package:finance_engine/finance_engine.dart';
import 'package:test/test.dart';

/// Standard EMI formula, rounded up to the rupee like banks do.
double emiFor(double p, double annualRate, int months) {
  final r = annualRate / 12;
  final f = math.pow(1 + r, months);
  return (p * r * f / (f - 1)).ceilToDouble();
}

const _sheet = BalanceSheet(
  assets: [
    Asset(id: 'a1', type: AssetType.bank, value: 60000),
    Asset(id: 'a2', type: AssetType.fixedDeposit, value: 100000),
    Asset(id: 'a3', type: AssetType.mutualFundsStocks, value: 250000),
    Asset(id: 'a4', type: AssetType.retirement, value: 400000),
    Asset(id: 'a5', type: AssetType.gold, value: 150000),
    Asset(id: 'a6', type: AssetType.property, value: 4000000),
  ],
  loans: [
    Loan(id: 'l1', type: LoanType.home, outstanding: 3000000, emi: 26035, annualRate: 0.085),
    Loan(id: 'l2', type: LoanType.creditCard, outstanding: 40000, emi: 5000, annualRate: 0.36),
    Loan(id: 'l3', type: LoanType.vehicle, outstanding: 300000, emi: 9000),
  ],
);

void main() {
  group('BalanceSheet', () {
    test('classifies assets', () {
      expect(_sheet.liquidAssets, 160000);
      expect(_sheet.investableAssets, 800000);
      expect(_sheet.propertyAssets, 4000000);
      expect(_sheet.totalAssets, 4960000);
      expect(_sheet.totalLoans, 3340000);
      expect(_sheet.totalEmi, 40035);
      expect(_sheet.netWorth, 1620000);
      expect(_sheet.debtToAssets, closeTo(3340000 / 4960000, 1e-12));
    });

    test('fromTotals carries quick-mode numbers over', () {
      final s = BalanceSheet.fromTotals(
          savings: 80000, investments: 20000, loanOutstanding: 50000, monthlyEmi: 4000);
      expect(s.liquidAssets, 80000);
      expect(s.investableAssets, 20000);
      expect(s.totalLoans, 50000);
      expect(s.totalEmi, 4000);
      expect(BalanceSheet.fromTotals().isEmpty, isTrue);
    });

    test('every asset type has a class', () {
      for (final t in AssetType.values) {
        expect(t.assetClass, isA<AssetClass>());
      }
    });
  });

  group('FinancialProfile.detailed', () {
    final p = FinancialProfile.detailed(
      age: 35,
      monthlyIncome: 120000,
      monthlyExpenses: 50000,
      sheet: _sheet,
    );

    test('derives totals from the sheet', () {
      expect(p.savings, 160000);
      expect(p.investments, 800000);
      expect(p.loanOutstanding, 3340000);
      expect(p.monthlyEmi, 40035);
      expect(p.propertyValue, 4000000);
      expect(p.netWorth, 1620000);
      expect(p.monthlySurplus, 120000 - 50000 - 40035);
    });

    test('an empty sheet means quick mode', () {
      final q = FinancialProfile.detailed(
          age: 30, monthlyIncome: 1, monthlyExpenses: 1, sheet: const BalanceSheet());
      expect(q.balanceSheet, isNull);
    });

    test('quick-mode net worth is savings + investments - loans', () {
      const q = FinancialProfile(
          age: 30,
          monthlyIncome: 1,
          monthlyExpenses: 1,
          savings: 10,
          investments: 20,
          loanOutstanding: 5);
      expect(q.netWorth, 25);
      expect(q.propertyValue, 0);
    });

    test('FI plan counts investable assets only and says so', () {
      final plan = GoalPlanner.planIndependence(p,
          targetAge: 55, risk: RiskProfile.moderate);
      expect(plan.goal.alreadySaved, 800000);
      expect(plan.steps.join('\n'), contains('property is not counted'));
    });
  });

  group('LoanMath', () {
    test('a standard 20-year home loan pays off in 240 months', () {
      final emi = emiFor(3000000, 0.085, 240);
      expect(emi, 26035);
      expect(LoanMath.monthsToPayoff(3000000, emi, 0.085), 240);
      final interest = LoanMath.interestRemaining(3000000, emi, 0.085)!;
      // Total paid minus principal, allowing for the smaller last payment.
      expect(interest, closeTo(emi * 240 - 3000000, emi));
    });

    test('zero interest is simple division', () {
      expect(LoanMath.monthsToPayoff(100000, 30000, 0), 4);
      expect(LoanMath.interestRemaining(100000, 30000, 0), 0);
    });

    test('an EMI that does not cover interest never pays off', () {
      expect(LoanMath.monthsToPayoff(100000, 1000, 0.36), isNull);
      expect(LoanMath.monthsToPayoff(100000, 0, 0.10), isNull);
      expect(LoanMath.monthsToPayoff(0, 0, 0.10), 0);
    });
  });

  group('DebtAnalyzer', () {
    final r = DebtAnalyzer.analyze(_sheet.loans);

    test('orders by rate, credit card first, unknown rates last', () {
      expect(r.payoffOrder.map((i) => i.loan.id), ['l2', 'l1', 'l3']);
    });

    test('flags high-cost debt and missing rates', () {
      expect(r.highCost.map((i) => i.loan.id), ['l2']);
      expect(r.highCostOutstanding, 40000);
      expect(r.missingRates, isTrue);
      expect(r.debtFreeInMonths, isNull); // vehicle loan rate unknown
      expect(r.payoffOrder.first.monthlyInterest, closeTo(1200, 1e-9));
    });

    test('debt-free date is the longest payoff when all rates are known', () {
      final r2 = DebtAnalyzer.analyze(_sheet.loans.take(2).toList());
      expect(r2.debtFreeInMonths, 240);
    });

    test('a credit card with unknown rate is still high cost', () {
      final r3 = DebtAnalyzer.analyze(
          const [Loan(id: 'c', type: LoanType.creditCard, outstanding: 1000, emi: 100)]);
      expect(r3.highCost, hasLength(1));
    });

    test('ignores fully repaid loans', () {
      final r4 = DebtAnalyzer.analyze(
          const [Loan(id: 'z', type: LoanType.personal, outstanding: 0)]);
      expect(r4.payoffOrder, isEmpty);
      expect(r4.debtFreeInMonths, 0);
    });
  });

  group('health with a balance sheet', () {
    test('suggests clearing costly debt and warns about a growing loan', () {
      final p = FinancialProfile.detailed(
        age: 30,
        monthlyIncome: 60000,
        monthlyExpenses: 30000,
        hasHealthInsurance: true,
        sheet: const BalanceSheet(
          assets: [Asset(id: 'a', type: AssetType.bank, value: 300000)],
          loans: [
            Loan(id: 'c', type: LoanType.creditCard, outstanding: 50000, emi: 1000, annualRate: 0.36),
          ],
        ),
      );
      final h = HealthAnalyzer.analyze(p);
      final titles = h.actions.map((a) => a.title).toList();
      expect(titles, containsAllInOrder(['A loan is not going down', 'Clear costly debt first']));
      expect(h.actions[1].detail, contains('36.0%'));
      expect(h.netWorth, 250000);
      expect(h.debt, isNotNull);
    });

    test('emergency fund uses only bank + FDs', () {
      final p = FinancialProfile.detailed(
        age: 30,
        monthlyIncome: 60000,
        monthlyExpenses: 20000,
        sheet: _sheet,
      );
      final h = HealthAnalyzer.analyze(p);
      expect(h.emergencyMonthsCovered,
          closeTo(160000 / (20000 + 40035), 1e-9));
    });

    test('quick mode has no loan-by-loan report', () {
      const p = FinancialProfile(
          age: 30, monthlyIncome: 50000, monthlyExpenses: 20000, monthlyEmi: 5000);
      expect(HealthAnalyzer.analyze(p).debt, isNull);
    });
  });
}
