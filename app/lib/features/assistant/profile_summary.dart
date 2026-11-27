import 'package:finance_engine/finance_engine.dart';

import '../../state/app_state.dart';

/// The only user data sent to the AI: numbers and fixed choices. No names,
/// goal titles, loan labels or anything typed as free text. The backend
/// rejects any field not on its whitelist (backend/app/chat/schemas.py).
Map<String, Object?> buildProfileSummary(AppState s, HealthReport? health) {
  final p = s.profile;
  if (p == null) return const {};
  double money(double v) => v.isFinite ? v.clamp(-1e10, 1e10).roundToDouble() : 0;

  return {
    'age': p.age,
    'dependents': p.dependents,
    'monthly_income': money(p.monthlyIncome),
    'monthly_expenses': money(p.monthlyExpenses),
    'monthly_emi': money(p.monthlyEmi),
    'monthly_surplus': money(p.monthlySurplus),
    'savings': money(p.savings),
    'investments': money(p.investments),
    'property_value': money(p.propertyValue),
    'loans_total': money(p.loanOutstanding),
    'net_worth': money(p.netWorth),
    'has_health_insurance': p.hasHealthInsurance,
    'has_term_insurance': p.hasTermInsurance,
    'risk_profile': s.risk.name,
    if (s.fiTargetAge > p.age) 'fi_target_age': s.fiTargetAge,
    if (health != null) 'health_score': health.score,
    'goals': [
      for (final g in s.goals.take(20))
        {
          'type': g.type.name,
          'today_cost': money(g.todayCost),
          'years': g.years.clamp(0, 80),
          'already_saved': money(g.alreadySaved),
        },
    ],
    'loans': [
      for (final l in (p.balanceSheet?.loans ?? const <Loan>[]).take(20))
        {
          'type': l.type.name,
          'outstanding': money(l.outstanding),
          'emi': money(l.emi),
          if (l.annualRate != null) 'annual_rate': l.annualRate,
        },
    ],
    'assumptions': s.assumptions.toJson(),
  };
}
