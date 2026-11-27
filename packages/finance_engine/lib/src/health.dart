import 'assumptions.dart';
import 'balance_sheet.dart';
import 'profile.dart';

enum HealthBand { needsAttention, fair, good, excellent }

/// One recommended next step, ordered by priority.
class ActionItem {
  final String title;
  final String detail;
  const ActionItem(this.title, this.detail);

  @override
  String toString() => '$title: $detail';
}

/// Score component with its points and the maximum possible.
class ScorePart {
  final String label;
  final double points;
  final double max;
  const ScorePart(this.label, this.points, this.max);
}

class HealthReport {
  final int score; // 0–100
  final HealthBand band;
  final List<ScorePart> parts;

  final double monthlySurplus;
  final double savingsRate;
  final double emergencyTarget;
  final double emergencyGap;
  final double emergencyMonthsCovered;

  /// Target months of cover (from [Assumptions.emergencyFundMonths]).
  final int emergencyTargetMonths;
  final double debtToIncome; // EMI / income

  /// Everything owned minus everything owed (property included).
  final double netWorth;

  /// Loans / everything owned.
  final double debtToAssets;

  /// Loan-by-loan analysis; null in quick mode (no itemised loans).
  final DebtReport? debt;
  final List<ActionItem> actions;

  const HealthReport({
    required this.score,
    required this.band,
    required this.parts,
    required this.monthlySurplus,
    required this.savingsRate,
    required this.emergencyTarget,
    required this.emergencyGap,
    required this.emergencyMonthsCovered,
    required this.emergencyTargetMonths,
    required this.debtToIncome,
    required this.netWorth,
    required this.debtToAssets,
    required this.debt,
    required this.actions,
  });
}

/// Scoring (100 points):
/// - Savings rate: 30 pts, full at >= 30% of income.
/// - Emergency fund: 25 pts, full at target months covered.
/// - Debt load: 25 pts, full at 0% EMI/income, zero at >= 50%.
/// - Protection: 20 pts, 10 health insurance + 10 term insurance
///   (term is not needed and counted as full when there are no dependents).
class HealthAnalyzer {
  HealthAnalyzer._();

  static HealthReport analyze(
    FinancialProfile p, {
    Assumptions a = Assumptions.standard,
  }) {
    final monthlyNeeds = p.monthlyExpenses + p.monthlyEmi;
    final emergencyTarget = monthlyNeeds * a.emergencyFundMonths;
    final emergencyGap = (emergencyTarget - p.savings).clamp(0, double.infinity).toDouble();
    final monthsCovered = monthlyNeeds <= 0 ? 0.0 : p.savings / monthlyNeeds;
    final dti = p.monthlyIncome <= 0 ? 0.0 : p.monthlyEmi / p.monthlyIncome;
    final rate = p.savingsRate;

    double clamp01(double x) => x.clamp(0.0, 1.0).toDouble();

    final savingsPts = 30 * clamp01(rate / 0.30);
    final emergencyPts = 25 * clamp01(monthsCovered / a.emergencyFundMonths);
    final debtPts = 25 * clamp01(1 - dti / 0.50);
    final healthPts = p.hasHealthInsurance ? 10.0 : 0.0;
    final termPts = (p.dependents == 0 || p.hasTermInsurance) ? 10.0 : 0.0;

    final parts = [
      ScorePart('Savings rate', savingsPts, 30),
      ScorePart('Emergency fund', emergencyPts, 25),
      ScorePart('Debt load', debtPts, 25),
      ScorePart('Insurance', healthPts + termPts, 20),
    ];
    final score =
        parts.fold<double>(0, (s, x) => s + x.points).round().clamp(0, 100);

    final sheet = p.balanceSheet;
    final debt = sheet == null || sheet.loans.isEmpty
        ? null
        : DebtAnalyzer.analyze(sheet.loans);

    final actions = <ActionItem>[];
    if (p.monthlySurplus < 0) {
      actions.add(ActionItem(
        'Spending is more than income',
        'You are short ₹${_r(-p.monthlySurplus)} every month. Reduce expenses before investing.',
      ));
    }
    for (final i in debt?.payoffOrder ?? const <LoanInsight>[]) {
      if (i.emiTooLow) {
        actions.add(ActionItem(
          'A loan is not going down',
          'Your ${loanTypeName(i.loan.type)} payment does not cover its interest '
              '(about ₹${_r(i.monthlyInterest!)} a month), so the balance keeps growing.',
        ));
      }
    }
    final costly = debt?.highCost ?? const <LoanInsight>[];
    if (costly.isNotEmpty) {
      final top = costly.first;
      final rate = top.loan.annualRate;
      actions.add(ActionItem(
        'Clear costly debt first',
        'Your ${loanTypeName(top.loan.type)} (₹${_r(top.loan.outstanding)}'
            '${rate == null ? '' : ' at ${(rate * 100).toStringAsFixed(1)}%'}) '
            'costs more than investments usually earn. Paying it off is a '
            'guaranteed return${top.monthlyInterest == null ? '' : ' and saves about ₹${_r(top.monthlyInterest!)} a month in interest'}.',
      ));
    }
    if (dti > 0.40) {
      actions.add(ActionItem(
        'High EMI burden',
        'EMIs take ${(dti * 100).toStringAsFixed(0)}% of income. Avoid new loans and consider prepaying the costliest one.',
      ));
    }
    if (!p.hasHealthInsurance) {
      actions.add(const ActionItem(
        'Get health insurance',
        'One hospital bill can wipe out years of savings.',
      ));
    }
    if (p.dependents > 0 && !p.hasTermInsurance) {
      actions.add(const ActionItem(
        'Consider term life insurance',
        'People depend on your income. Term insurance protects them.',
      ));
    }
    if (emergencyGap > 0) {
      actions.add(ActionItem(
        'Build your emergency fund',
        'Target ₹${_r(emergencyTarget)} (${a.emergencyFundMonths} months of expenses). You need ₹${_r(emergencyGap)} more.',
      ));
    }
    if (rate >= 0 && rate < 0.20 && p.monthlySurplus >= 0) {
      actions.add(const ActionItem(
        'Raise your savings rate',
        'Aim to save at least 20% of income. Review your largest expenses.',
      ));
    }
    if (actions.isEmpty) {
      actions.add(const ActionItem(
        'Start goal-based investing',
        'Your basics are in place. Set goals and plan monthly investments for them.',
      ));
    }

    return HealthReport(
      score: score,
      band: score >= 80
          ? HealthBand.excellent
          : score >= 60
              ? HealthBand.good
              : score >= 40
                  ? HealthBand.fair
                  : HealthBand.needsAttention,
      parts: parts,
      monthlySurplus: p.monthlySurplus,
      savingsRate: rate,
      emergencyTarget: emergencyTarget,
      emergencyGap: emergencyGap,
      emergencyMonthsCovered: monthsCovered,
      emergencyTargetMonths: a.emergencyFundMonths,
      debtToIncome: dti,
      netWorth: p.netWorth,
      debtToAssets: p.debtToAssets,
      debt: debt,
      actions: actions,
    );
  }

  static String _r(double v) => v.round().toString();
}

/// Lower-case name used inside sentences ("your credit card").
String loanTypeName(LoanType t) => switch (t) {
      LoanType.home => 'home loan',
      LoanType.vehicle => 'vehicle loan',
      LoanType.personal => 'personal loan',
      LoanType.education => 'education loan',
      LoanType.creditCard => 'credit card',
      LoanType.gold => 'gold loan',
      LoanType.other => 'loan',
    };
