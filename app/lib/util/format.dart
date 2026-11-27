import 'package:finance_engine/finance_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

/// ₹1,50,000 (Indian grouping).
String inr(double v) => _inr.format(v.isFinite ? v.round() : 0);

/// ₹2.41 Cr / ₹1.50 L / ₹25,000.
String inrShort(double v) {
  if (!v.isFinite) return '—';
  final a = v.abs();
  final sign = v < 0 ? '-' : '';
  if (a >= 1e7) return '$sign₹${(a / 1e7).toStringAsFixed(2)} Cr';
  if (a >= 1e5) return '$sign₹${(a / 1e5).toStringAsFixed(2)} L';
  return inr(v);
}

String pct(double v, [int decimals = 0]) => '${(v * 100).toStringAsFixed(decimals)}%';

double parseAmount(String text) =>
    double.tryParse(text.replaceAll(',', '').trim()) ?? 0;

String riskLabel(RiskProfile r) => switch (r) {
      RiskProfile.conservative => 'Conservative',
      RiskProfile.moderate => 'Moderate',
      RiskProfile.aggressive => 'Aggressive',
    };

String goalTypeLabel(GoalType t) => switch (t) {
      GoalType.house => 'Buy a house',
      GoalType.car => 'Buy a car',
      GoalType.retirement => 'Retirement',
      GoalType.education => "Children's education",
      GoalType.passiveIncome => 'Passive income',
      GoalType.wealthCreation => 'Wealth creation',
      GoalType.financialIndependence => 'Financial independence',
      GoalType.other => 'Other',
    };

IconData goalTypeIcon(GoalType t) => switch (t) {
      GoalType.house => Icons.home_outlined,
      GoalType.car => Icons.directions_car_outlined,
      GoalType.retirement => Icons.beach_access_outlined,
      GoalType.education => Icons.school_outlined,
      GoalType.passiveIncome => Icons.payments_outlined,
      GoalType.wealthCreation => Icons.trending_up,
      GoalType.financialIndependence => Icons.self_improvement,
      GoalType.other => Icons.flag_outlined,
    };

String feasibilityLabel(Feasibility f) => switch (f) {
      Feasibility.onTrack => 'On track',
      Feasibility.stretch => 'Possible with yearly step-up',
      Feasibility.notFeasible => 'Gap: adjust the plan',
    };

Color feasibilityColor(Feasibility f, ColorScheme cs) => switch (f) {
      Feasibility.onTrack => Colors.green.shade600,
      Feasibility.stretch => Colors.orange.shade700,
      Feasibility.notFeasible => cs.error,
    };

String expenseLabel(ExpenseCategory c) => switch (c) {
      ExpenseCategory.housing => 'Rent / housing',
      ExpenseCategory.food => 'Food & groceries',
      ExpenseCategory.transport => 'Transport',
      ExpenseCategory.utilities => 'Bills & utilities',
      ExpenseCategory.health => 'Health',
      ExpenseCategory.education => 'Education',
      ExpenseCategory.lifestyle => 'Shopping, eating out, fun',
      ExpenseCategory.other => 'Other',
    };

IconData expenseIcon(ExpenseCategory c) => switch (c) {
      ExpenseCategory.housing => Icons.home_outlined,
      ExpenseCategory.food => Icons.restaurant_outlined,
      ExpenseCategory.transport => Icons.directions_bus_outlined,
      ExpenseCategory.utilities => Icons.bolt_outlined,
      ExpenseCategory.health => Icons.medical_services_outlined,
      ExpenseCategory.education => Icons.school_outlined,
      ExpenseCategory.lifestyle => Icons.shopping_bag_outlined,
      ExpenseCategory.other => Icons.more_horiz,
    };

/// Distinct, colour-blind-friendlier palette for expense charts.
Color expenseColor(ExpenseCategory c) => switch (c) {
      ExpenseCategory.housing => const Color(0xFF0F766E),
      ExpenseCategory.food => const Color(0xFFE69F00),
      ExpenseCategory.transport => const Color(0xFF3B82F6),
      ExpenseCategory.utilities => const Color(0xFF8B5CF6),
      ExpenseCategory.health => const Color(0xFFD55E00),
      ExpenseCategory.education => const Color(0xFF009E73),
      ExpenseCategory.lifestyle => const Color(0xFFCC79A7),
      ExpenseCategory.other => const Color(0xFF94A3B8),
    };

String assetTypeLabel(AssetType t) => switch (t) {
      AssetType.bank => 'Bank savings & cash',
      AssetType.fixedDeposit => 'Fixed / recurring deposits',
      AssetType.mutualFundsStocks => 'Mutual funds & stocks',
      AssetType.retirement => 'EPF / PPF / NPS',
      AssetType.gold => 'Gold',
      AssetType.property => 'Property (land, flat, house)',
      AssetType.other => 'Other assets',
    };

IconData assetTypeIcon(AssetType t) => switch (t) {
      AssetType.bank => Icons.account_balance_outlined,
      AssetType.fixedDeposit => Icons.lock_clock_outlined,
      AssetType.mutualFundsStocks => Icons.show_chart,
      AssetType.retirement => Icons.elderly_outlined,
      AssetType.gold => Icons.diamond_outlined,
      AssetType.property => Icons.home_work_outlined,
      AssetType.other => Icons.category_outlined,
    };

String loanTypeLabel(LoanType t) => switch (t) {
      LoanType.home => 'Home loan',
      LoanType.vehicle => 'Car / bike loan',
      LoanType.personal => 'Personal loan',
      LoanType.education => 'Education loan',
      LoanType.creditCard => 'Credit card dues',
      LoanType.gold => 'Gold loan',
      LoanType.other => 'Other loan',
    };

IconData loanTypeIcon(LoanType t) => switch (t) {
      LoanType.home => Icons.house_outlined,
      LoanType.vehicle => Icons.directions_car_outlined,
      LoanType.personal => Icons.person_outline,
      LoanType.education => Icons.school_outlined,
      LoanType.creditCard => Icons.credit_card,
      LoanType.gold => Icons.diamond_outlined,
      LoanType.other => Icons.request_quote_outlined,
    };

/// 150 -> "12 yrs 6 mo", 8 -> "8 mo".
String durationLabel(int months) {
  final y = months ~/ 12, m = months % 12;
  if (y == 0) return '$m mo';
  return m == 0 ? '$y yrs' : '$y yrs $m mo';
}
