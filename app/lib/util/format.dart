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
