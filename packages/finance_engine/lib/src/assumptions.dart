/// Default assumptions used by every calculation.
///
/// These are illustrative scenario values, not promises. Every result that
/// depends on them must show them to the user.
class Assumptions {
  /// Annual inflation rate (0.06 = 6%).
  final double inflation;

  /// Emergency fund target, in months of expenses.
  final int emergencyFundMonths;

  /// Retirement / FI corpus as a multiple of annual expenses.
  final double corpusMultiple;

  /// Illustrative annual returns per asset class.
  final double equityReturn;
  final double debtReturn;
  final double goldReturn;
  final double cashReturn;

  const Assumptions({
    this.inflation = 0.06,
    this.emergencyFundMonths = 6,
    this.corpusMultiple = 25,
    this.equityReturn = 0.11,
    this.debtReturn = 0.065,
    this.goldReturn = 0.075,
    this.cashReturn = 0.035,
  });

  static const standard = Assumptions();

  Assumptions copyWith({
    double? inflation,
    int? emergencyFundMonths,
    double? corpusMultiple,
    double? equityReturn,
    double? debtReturn,
    double? goldReturn,
    double? cashReturn,
  }) =>
      Assumptions(
        inflation: inflation ?? this.inflation,
        emergencyFundMonths: emergencyFundMonths ?? this.emergencyFundMonths,
        corpusMultiple: corpusMultiple ?? this.corpusMultiple,
        equityReturn: equityReturn ?? this.equityReturn,
        debtReturn: debtReturn ?? this.debtReturn,
        goldReturn: goldReturn ?? this.goldReturn,
        cashReturn: cashReturn ?? this.cashReturn,
      );
}
