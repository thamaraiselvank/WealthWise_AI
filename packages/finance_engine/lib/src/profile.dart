import 'balance_sheet.dart';
import 'expenses.dart';

/// The user's financial snapshot, collected during onboarding.
///
/// All amounts are in rupees. Monthly values are per month.
class FinancialProfile {
  final int age;
  final double monthlyIncome;
  final double monthlyExpenses;

  /// Cash / bank savings / FDs that can serve as an emergency fund.
  final double savings;

  /// Existing investments (mutual funds, stocks, PPF, etc.).
  final double investments;

  /// Total outstanding loan principal.
  final double loanOutstanding;

  /// Total monthly EMIs. Assumed NOT to be included in [monthlyExpenses].
  final double monthlyEmi;

  final int dependents;
  final bool hasHealthInsurance;
  final bool hasTermInsurance;

  /// Optional split of [monthlyExpenses] by category. When present, its
  /// total is expected to equal [monthlyExpenses].
  final ExpenseBreakdown? expenseBreakdown;

  /// Optional item-by-item assets and loans ("detailed mode"). When present,
  /// [savings], [investments], [loanOutstanding] and [monthlyEmi] are derived
  /// from it; build such profiles with [FinancialProfile.detailed].
  final BalanceSheet? balanceSheet;

  const FinancialProfile({
    required this.age,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    this.savings = 0,
    this.investments = 0,
    this.loanOutstanding = 0,
    this.monthlyEmi = 0,
    this.dependents = 0,
    this.hasHealthInsurance = false,
    this.hasTermInsurance = false,
    this.expenseBreakdown,
    this.balanceSheet,
  });

  /// Profile whose money totals come from [sheet]:
  /// - savings = bank + FDs (the emergency fund)
  /// - investments = funds, stocks, EPF/PPF/NPS, gold, other (count to goals)
  /// - property counts only towards net worth
  factory FinancialProfile.detailed({
    required int age,
    required double monthlyIncome,
    required double monthlyExpenses,
    required BalanceSheet sheet,
    int dependents = 0,
    bool hasHealthInsurance = false,
    bool hasTermInsurance = false,
    ExpenseBreakdown? expenseBreakdown,
  }) =>
      FinancialProfile(
        age: age,
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
        savings: sheet.liquidAssets,
        investments: sheet.investableAssets,
        loanOutstanding: sheet.totalLoans,
        monthlyEmi: sheet.totalEmi,
        dependents: dependents,
        hasHealthInsurance: hasHealthInsurance,
        hasTermInsurance: hasTermInsurance,
        expenseBreakdown: expenseBreakdown,
        balanceSheet: sheet.isEmpty ? null : sheet,
      );

  /// Value of property owned (0 in quick mode).
  double get propertyValue => balanceSheet?.propertyAssets ?? 0;

  double get totalAssets => savings + investments + propertyValue;

  /// Loans as a share of everything owned (0 when nothing is owned).
  double get debtToAssets =>
      totalAssets <= 0 ? 0 : loanOutstanding / totalAssets;

  /// Money left after expenses and EMIs.
  double get monthlySurplus => monthlyIncome - monthlyExpenses - monthlyEmi;

  /// Share of income left over (0.375 = 37.5%). 0 if income is 0.
  double get savingsRate =>
      monthlyIncome <= 0 ? 0 : monthlySurplus / monthlyIncome;

  double get netWorth => totalAssets - loanOutstanding;
}
