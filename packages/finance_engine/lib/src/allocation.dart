import 'assumptions.dart';
import 'risk.dart';

/// Illustrative asset split in percentages (sums to 100).
class Allocation {
  final int equity;
  final int debt;
  final int gold;
  final int cash;
  final List<String> reasons;

  const Allocation({
    required this.equity,
    required this.debt,
    required this.gold,
    required this.cash,
    this.reasons = const [],
  });

  int get total => equity + debt + gold + cash;

  /// Weighted illustrative annual return for this mix.
  double expectedReturn(Assumptions a) =>
      (equity * a.equityReturn +
          debt * a.debtReturn +
          gold * a.goldReturn +
          cash * a.cashReturn) /
      100;
}

/// Rule-based, illustrative allocation by risk profile and time horizon.
///
/// Education only: categories, never specific schemes.
class AllocationPlanner {
  AllocationPlanner._();

  static const _baseEquity = {
    RiskProfile.conservative: 30,
    RiskProfile.moderate: 55,
    RiskProfile.aggressive: 75,
  };

  static Allocation suggest(RiskProfile risk, double horizonYears) {
    final reasons = <String>[];

    if (horizonYears < 1) {
      return const Allocation(equity: 0, debt: 20, gold: 0, cash: 80, reasons: [
        'Money needed within a year should not be exposed to market swings.',
        'Savings accounts, sweep FDs or liquid funds keep it safe and accessible.',
      ]);
    }
    if (horizonYears < 3) {
      return const Allocation(equity: 0, debt: 70, gold: 5, cash: 25, reasons: [
        'Under 3 years, equity can fall and not recover in time.',
        'Short-duration debt funds or FDs give steadier returns.',
      ]);
    }

    var equity = _baseEquity[risk]!;
    reasons.add('Starting point for a ${risk.name} investor: $equity% equity.');

    final int cap;
    if (horizonYears < 5) {
      cap = 35;
    } else if (horizonYears < 7) {
      cap = 55;
    } else {
      cap = 100;
    }
    if (equity > cap) {
      equity = cap;
      reasons.add(
          'Equity capped at $cap% because the goal is ${horizonYears.toStringAsFixed(0)} years away.');
    } else if (horizonYears >= 7) {
      reasons.add('A 7+ year horizon gives equity time to recover from falls.');
    }

    const gold = 10;
    const cash = 5;
    final debt = 100 - equity - gold - cash;
    reasons.add('About 10% gold helps diversify; it often moves differently from equity.');
    reasons.add('Debt adds stability and reduces large swings.');

    return Allocation(
      equity: equity,
      debt: debt,
      gold: gold,
      cash: cash,
      reasons: reasons,
    );
  }
}
