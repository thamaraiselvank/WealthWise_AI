import 'dart:math' as math;

/// What kind of thing the user owns. The kind decides how the engine treats
/// it: liquid money backs the emergency fund, investable assets count towards
/// goals, and property counts only towards net worth.
enum AssetType {
  /// Savings account, cash at home.
  bank,

  /// Fixed / recurring deposits.
  fixedDeposit,

  /// Mutual funds (equity, debt, hybrid) and shares.
  mutualFundsStocks,

  /// EPF, PPF, NPS: long-term, mostly locked until retirement.
  retirement,

  /// Physical gold, gold ETFs / funds, sovereign gold bonds.
  gold,

  /// Land, flat, house (including the one you live in).
  property,

  other,
}

enum AssetClass { liquid, investable, property }

extension AssetTypeX on AssetType {
  AssetClass get assetClass => switch (this) {
        AssetType.bank || AssetType.fixedDeposit => AssetClass.liquid,
        AssetType.property => AssetClass.property,
        _ => AssetClass.investable,
      };
}

class Asset {
  final String id;
  final AssetType type;

  /// Optional user label ("Salary account"). Never sent off the phone.
  final String label;
  final double value;

  const Asset({
    required this.id,
    required this.type,
    required this.value,
    this.label = '',
  });

  @override
  bool operator ==(Object other) =>
      other is Asset &&
      other.id == id &&
      other.type == type &&
      other.label == label &&
      other.value == value;

  @override
  int get hashCode => Object.hash(id, type, label, value);
}

enum LoanType { home, vehicle, personal, education, creditCard, gold, other }

class Loan {
  final String id;
  final LoanType type;
  final String label;

  /// Principal still owed.
  final double outstanding;

  /// Monthly instalment (for credit cards: what you usually pay each month).
  final double emi;

  /// Annual interest rate (0.09 = 9%), or null when the user does not know.
  final double? annualRate;

  const Loan({
    required this.id,
    required this.type,
    required this.outstanding,
    this.emi = 0,
    this.annualRate,
    this.label = '',
  });

  @override
  bool operator ==(Object other) =>
      other is Loan &&
      other.id == id &&
      other.type == type &&
      other.label == label &&
      other.outstanding == outstanding &&
      other.emi == emi &&
      other.annualRate == annualRate;

  @override
  int get hashCode => Object.hash(id, type, label, outstanding, emi, annualRate);
}

/// Everything the user owns and owes, item by item.
class BalanceSheet {
  final List<Asset> assets;
  final List<Loan> loans;

  const BalanceSheet({this.assets = const [], this.loans = const []});

  /// Starting point when a quick-mode user switches to detailed mode: their
  /// totals become one item each, ready to be split or re-typed.
  factory BalanceSheet.fromTotals({
    double savings = 0,
    double investments = 0,
    double loanOutstanding = 0,
    double monthlyEmi = 0,
  }) =>
      BalanceSheet(
        assets: [
          if (savings > 0) Asset(id: 'q-savings', type: AssetType.bank, value: savings),
          if (investments > 0)
            Asset(id: 'q-invest', type: AssetType.mutualFundsStocks, value: investments),
        ],
        loans: [
          if (loanOutstanding > 0)
            Loan(id: 'q-loan', type: LoanType.other, outstanding: loanOutstanding, emi: monthlyEmi),
        ],
      );

  bool get isEmpty => assets.isEmpty && loans.isEmpty;

  double _sum(Iterable<double> xs) => xs.fold(0.0, (s, x) => s + x);

  double totalOf(AssetType t) =>
      _sum(assets.where((a) => a.type == t).map((a) => a.value));

  double totalOfClass(AssetClass c) =>
      _sum(assets.where((a) => a.type.assetClass == c).map((a) => a.value));

  /// Bank + FDs: backs the emergency fund.
  double get liquidAssets => totalOfClass(AssetClass.liquid);

  /// Funds, stocks, EPF/PPF/NPS, gold, other: counts towards goals.
  double get investableAssets => totalOfClass(AssetClass.investable);

  double get propertyAssets => totalOfClass(AssetClass.property);

  double get totalAssets => _sum(assets.map((a) => a.value));
  double get totalLoans => _sum(loans.map((l) => l.outstanding));
  double get totalEmi => _sum(loans.map((l) => l.emi));
  double get netWorth => totalAssets - totalLoans;

  /// Loans / assets. 0 when there are no assets.
  double get debtToAssets => totalAssets <= 0 ? 0 : totalLoans / totalAssets;

  @override
  bool operator ==(Object other) =>
      other is BalanceSheet &&
      _listEq(other.assets, assets) &&
      _listEq(other.loans, loans);

  @override
  int get hashCode => Object.hash(Object.hashAll(assets), Object.hashAll(loans));

  static bool _listEq<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Loan amortisation helpers (reducing balance, monthly compounding).
class LoanMath {
  LoanMath._();

  /// Months until [outstanding] is repaid paying [emi] a month at
  /// [annualRate]. Null if the EMI does not even cover the interest.
  static int? monthsToPayoff(double outstanding, double emi, double annualRate) {
    if (outstanding <= 0) return 0;
    if (emi <= 0) return null;
    final r = annualRate / 12;
    if (r <= 0) return (outstanding / emi).ceil();
    if (emi <= outstanding * r) return null;
    final n = -math.log(1 - r * outstanding / emi) / math.log(1 + r);
    return n.ceil();
  }

  /// Total interest still to pay, simulated month by month.
  static double? interestRemaining(double outstanding, double emi, double annualRate) {
    final months = monthsToPayoff(outstanding, emi, annualRate);
    if (months == null) return null;
    final r = annualRate / 12;
    var balance = outstanding;
    var interest = 0.0;
    for (var m = 0; m < months && balance > 0; m++) {
      final i = balance * r;
      interest += i;
      balance = balance + i - math.min(emi, balance + i);
    }
    return interest;
  }
}

/// Rates at or above this are treated as costly debt to clear first.
const highCostRate = 0.15;

class LoanInsight {
  final Loan loan;

  /// Interest charged this month on the balance, if the rate is known.
  final double? monthlyInterest;
  final int? monthsLeft;
  final double? interestLeft;

  /// True for credit cards and any loan at [highCostRate] or more.
  final bool isHighCost;

  /// The rate is known and the monthly payment does not cover the interest,
  /// so the balance never goes down.
  final bool emiTooLow;

  const LoanInsight({
    required this.loan,
    required this.monthlyInterest,
    required this.monthsLeft,
    required this.interestLeft,
    required this.isHighCost,
    required this.emiTooLow,
  });
}

class DebtReport {
  /// Loans in the order commonly suggested for extra repayments: costliest
  /// interest rate first ("avalanche"); unknown rates last, except credit
  /// cards, which are always treated as costly.
  final List<LoanInsight> payoffOrder;

  /// Months until every loan is repaid, if all rates are known and every EMI
  /// covers its interest.
  final int? debtFreeInMonths;

  final double totalOutstanding;
  final double totalEmi;
  final double highCostOutstanding;

  const DebtReport({
    required this.payoffOrder,
    required this.debtFreeInMonths,
    required this.totalOutstanding,
    required this.totalEmi,
    required this.highCostOutstanding,
  });

  List<LoanInsight> get highCost => payoffOrder.where((l) => l.isHighCost).toList();
  bool get missingRates => payoffOrder.any((l) => l.loan.annualRate == null);
}

class DebtAnalyzer {
  DebtAnalyzer._();

  static DebtReport analyze(List<Loan> loans) {
    final insights = [
      for (final l in loans.where((l) => l.outstanding > 0))
        _insight(l),
    ];

    double sortKey(LoanInsight i) =>
        i.loan.annualRate ?? (i.loan.type == LoanType.creditCard ? 1.0 : -1.0);
    insights.sort((a, b) {
      final c = sortKey(b).compareTo(sortKey(a));
      return c != 0 ? c : b.loan.outstanding.compareTo(a.loan.outstanding);
    });

    int? debtFree = 0;
    for (final i in insights) {
      final m = i.monthsLeft;
      if (m == null) {
        debtFree = null;
        break;
      }
      debtFree = math.max(debtFree!, m);
    }

    return DebtReport(
      payoffOrder: insights,
      debtFreeInMonths: insights.isEmpty ? 0 : debtFree,
      totalOutstanding: insights.fold(0.0, (s, i) => s + i.loan.outstanding),
      totalEmi: insights.fold(0.0, (s, i) => s + i.loan.emi),
      highCostOutstanding: insights
          .where((i) => i.isHighCost)
          .fold(0.0, (s, i) => s + i.loan.outstanding),
    );
  }

  static LoanInsight _insight(Loan l) {
    final rate = l.annualRate;
    final months = rate == null ? null : LoanMath.monthsToPayoff(l.outstanding, l.emi, rate);
    return LoanInsight(
      loan: l,
      monthlyInterest: rate == null ? null : l.outstanding * rate / 12,
      monthsLeft: months,
      interestLeft:
          rate == null ? null : LoanMath.interestRemaining(l.outstanding, l.emi, rate),
      isHighCost: l.type == LoanType.creditCard || (rate != null && rate >= highCostRate),
      emiTooLow: rate != null && months == null,
    );
  }
}
