import 'dart:math' as math;

/// Core time-value-of-money functions.
///
/// Conventions (shown to users as assumptions):
/// - SIP contributions are made at the START of each month (annuity due),
///   matching common Indian SIP calculators.
/// - Monthly rate = annual rate / 12.
/// - Lump sums compound annually.
class MoneyMath {
  MoneyMath._();

  /// Value of [presentValue] after [years] growing at [annualRate].
  static double futureValue(double presentValue, double annualRate, double years) =>
      presentValue * math.pow(1 + annualRate, years);

  /// Today's cost [amount] adjusted for [inflation] over [years].
  static double inflate(double amount, double inflation, double years) =>
      futureValue(amount, inflation, years);

  /// Future value of a monthly SIP of [monthly] for [years] at [annualRate].
  ///
  /// [annualStepUp] increases the SIP every 12 months (0.10 = +10% a year).
  static double sipFutureValue(
    double monthly,
    double annualRate,
    double years, {
    double annualStepUp = 0,
  }) {
    final months = (years * 12).round();
    if (months <= 0 || monthly <= 0) return 0;
    final r = annualRate / 12;

    if (annualStepUp == 0) {
      if (r == 0) return monthly * months;
      return monthly * ((math.pow(1 + r, months) - 1) / r) * (1 + r);
    }

    // Step-up: simulate month by month (transparent and exact).
    var balance = 0.0;
    var sip = monthly;
    for (var m = 0; m < months; m++) {
      if (m > 0 && m % 12 == 0) sip *= (1 + annualStepUp);
      balance = (balance + sip) * (1 + r);
    }
    return balance;
  }

  /// Starting monthly SIP needed to reach [target] in [years].
  ///
  /// [existingCorpus] is invested today as a lump sum at the same rate.
  /// Returns 0 if the existing corpus already covers the target.
  static double requiredSip(
    double target,
    double annualRate,
    double years, {
    double existingCorpus = 0,
    double annualStepUp = 0,
  }) {
    final gap = target - futureValue(existingCorpus, annualRate, years);
    if (gap <= 0) return 0;
    // FV is linear in the starting SIP, so divide by the FV of ₹1/month.
    final perRupee =
        sipFutureValue(1, annualRate, years, annualStepUp: annualStepUp);
    if (perRupee <= 0) return double.infinity;
    return gap / perRupee;
  }
}
