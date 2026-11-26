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
  });

  /// Money left after expenses and EMIs.
  double get monthlySurplus => monthlyIncome - monthlyExpenses - monthlyEmi;

  /// Share of income left over (0.375 = 37.5%). 0 if income is 0.
  double get savingsRate =>
      monthlyIncome <= 0 ? 0 : monthlySurplus / monthlyIncome;

  double get netWorth => savings + investments - loanOutstanding;
}
