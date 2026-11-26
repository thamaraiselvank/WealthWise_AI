import 'health.dart' show ActionItem;

enum ExpenseCategory {
  housing,
  food,
  transport,
  utilities,
  health,
  education,
  lifestyle,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  /// Essentials ("needs") vs. discretionary ("wants") for the 50/30/20 guide.
  bool get isEssential => switch (this) {
        ExpenseCategory.lifestyle || ExpenseCategory.other => false,
        _ => true,
      };
}

/// Monthly spending split by category (rupees). Missing categories are 0.
class ExpenseBreakdown {
  final Map<ExpenseCategory, double> amounts;

  ExpenseBreakdown(Map<ExpenseCategory, double> amounts)
      : amounts = Map.unmodifiable({
          for (final e in amounts.entries)
            if (e.value > 0) e.key: e.value,
        });

  double operator [](ExpenseCategory c) => amounts[c] ?? 0;

  double get total => amounts.values.fold(0, (s, v) => s + v);

  bool get isEmpty => amounts.isEmpty;

  Map<String, double> toJson() => {for (final e in amounts.entries) e.key.name: e.value};

  /// Unknown category names are ignored (forward compatible).
  factory ExpenseBreakdown.fromJson(Map<String, dynamic> json) {
    final byName = {for (final c in ExpenseCategory.values) c.name: c};
    return ExpenseBreakdown({
      for (final e in json.entries)
        if (byName[e.key] != null && e.value is num)
          byName[e.key]!: (e.value as num).toDouble(),
    });
  }

  @override
  bool operator ==(Object other) =>
      other is ExpenseBreakdown &&
      other.amounts.length == amounts.length &&
      amounts.entries.every((e) => other.amounts[e.key] == e.value);

  @override
  int get hashCode => Object.hashAllUnordered(
      amounts.entries.map((e) => Object.hash(e.key, e.value)));
}

class ExpenseLine {
  final ExpenseCategory category;
  final double amount;
  final double shareOfSpending;
  final double shareOfIncome;
  const ExpenseLine(this.category, this.amount, this.shareOfSpending, this.shareOfIncome);
}

class ExpenseAnalysis {
  /// Largest first.
  final List<ExpenseLine> lines;
  final double total;
  final double essentialShareOfIncome;
  final double discretionaryShareOfIncome;
  final List<ActionItem> insights;

  const ExpenseAnalysis({
    required this.lines,
    required this.total,
    required this.essentialShareOfIncome,
    required this.discretionaryShareOfIncome,
    required this.insights,
  });
}

/// Rules of thumb (shown as guides, not rules):
/// - Housing under 30% of income.
/// - Essentials (needs) under 50% of income.
/// - Lifestyle / other (wants) under 30% of income.
class ExpenseAnalyzer {
  ExpenseAnalyzer._();

  static const housingLimit = 0.30;
  static const essentialsLimit = 0.50;
  static const wantsLimit = 0.30;

  static ExpenseAnalysis analyze(ExpenseBreakdown b, double monthlyIncome) {
    final total = b.total;
    double ofIncome(double v) => monthlyIncome <= 0 ? 0 : v / monthlyIncome;

    final lines = [
      for (final e in b.amounts.entries)
        ExpenseLine(e.key, e.value, total <= 0 ? 0 : e.value / total, ofIncome(e.value)),
    ]..sort((a, c) => c.amount.compareTo(a.amount));

    final essentials = b.amounts.entries
        .where((e) => e.key.isEssential)
        .fold<double>(0, (s, e) => s + e.value);
    final wants = total - essentials;

    String p(double v) => '${(v * 100).round()}%';
    final insights = <ActionItem>[];

    final housing = ofIncome(b[ExpenseCategory.housing]);
    if (housing > housingLimit) {
      insights.add(ActionItem(
        'Housing is ${p(housing)} of income',
        'A common guide is to keep rent or home EMI under ${p(housingLimit)} of take-home pay.',
      ));
    }
    if (ofIncome(essentials) > essentialsLimit) {
      insights.add(ActionItem(
        'Essentials take ${p(ofIncome(essentials))} of income',
        'The 50/30/20 guide suggests about ${p(essentialsLimit)} for needs. Look for savings in your biggest essential costs.',
      ));
    }
    if (ofIncome(wants) > wantsLimit) {
      insights.add(ActionItem(
        'Lifestyle spending is ${p(ofIncome(wants))} of income',
        'Shopping, eating out and entertainment above ${p(wantsLimit)} of income slows your goals. Small cuts here add up fast.',
      ));
    }
    if (lines.isNotEmpty && insights.isEmpty) {
      insights.add(ActionItem(
        'Your spending looks balanced',
        'Housing, essentials and lifestyle spending are all within common guides.',
      ));
    }

    return ExpenseAnalysis(
      lines: lines,
      total: total,
      essentialShareOfIncome: ofIncome(essentials),
      discretionaryShareOfIncome: ofIncome(wants),
      insights: insights,
    );
  }
}
