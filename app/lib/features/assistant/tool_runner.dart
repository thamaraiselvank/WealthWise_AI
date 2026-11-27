import 'package:finance_engine/finance_engine.dart';

import '../../state/app_state.dart';

/// Runs the functions Gemini asks for, on the phone, with the Dart finance
/// engine. This is the only place answers get their numbers from.
///
/// Contract: shared/assistant_tools.json (the backend declares the same
/// names; test/assistant/tool_runner_test.dart checks every one is handled).
/// This class only converts arguments and results; all math is in the engine.
class ToolRunner {
  ToolRunner(this.state);

  final AppState state;

  static const names = {
    'get_health_report',
    'get_assumptions',
    'plan_goal',
    'plan_independence',
    'suggest_allocation',
    'sip_projection',
    'loan_payoff',
  };

  Assumptions get _a => state.assumptions;

  Map<String, Object?> run(String name, Map<String, Object?> args) {
    final p = state.profile;
    if (p == null) return _error('The user has not set up a profile yet.');
    try {
      return switch (name) {
        'get_health_report' => _health(p),
        'get_assumptions' => _assumptions(),
        'plan_goal' => _planGoal(p, args),
        'plan_independence' => _planIndependence(p, args),
        'suggest_allocation' => _allocation(args),
        'sip_projection' => _sip(args),
        'loan_payoff' => _loan(args),
        _ => _error('Unknown function $name.'),
      };
    } on ArgumentError catch (e) {
      return _error(e.message.toString());
    }
  }

  // --- argument helpers ------------------------------------------------------

  static double _num(Map<String, Object?> args, String key,
      {double? fallback, double min = 0, double max = 1e11}) {
    final v = args[key];
    final d = v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null);
    if (d == null || !d.isFinite) {
      if (fallback != null) return fallback;
      throw ArgumentError('Missing or invalid "$key".');
    }
    if (d < min || d > max) throw ArgumentError('"$key" must be between $min and $max.');
    return d;
  }

  static Map<String, Object?> _error(String message) => {'error': message};

  static int _r(double v) => v.isFinite ? v.round() : 0;
  static double _p(double v) => double.parse(v.toStringAsFixed(4));

  // --- functions -------------------------------------------------------------

  Map<String, Object?> _health(FinancialProfile p) {
    final h = HealthAnalyzer.analyze(p, a: _a);
    return {
      'score': h.score,
      'band': h.band.name,
      'parts': [
        for (final x in h.parts) {'label': x.label, 'points': _r(x.points), 'max': _r(x.max)},
      ],
      'monthly_surplus': _r(h.monthlySurplus),
      'savings_rate': _p(h.savingsRate),
      'emergency_fund_target': _r(h.emergencyTarget),
      'emergency_fund_gap': _r(h.emergencyGap),
      'emergency_months_covered': double.parse(h.emergencyMonthsCovered.toStringAsFixed(1)),
      'emergency_target_months': h.emergencyTargetMonths,
      'emi_to_income': _p(h.debtToIncome),
      'net_worth': _r(h.netWorth),
      'loans_to_assets': _p(h.debtToAssets),
      'actions': [for (final x in h.actions) {'title': x.title, 'detail': x.detail}],
      if (h.debt case final d?) ...{
        'debt_free_in_months': d.debtFreeInMonths,
        'loans_highest_interest_first': [
          for (final i in d.payoffOrder)
            {
              'type': i.loan.type.name,
              'outstanding': _r(i.loan.outstanding),
              'emi': _r(i.loan.emi),
              'annual_rate': i.loan.annualRate,
              'months_left': i.monthsLeft,
              'interest_left': i.interestLeft == null ? null : _r(i.interestLeft!),
              'high_cost': i.isHighCost,
              'payment_below_interest': i.emiTooLow,
            },
        ],
      },
    };
  }

  Map<String, Object?> _assumptions() => {
        'values': _a.toJson(),
        'changed_by_user': _a.describeChanges(),
        'cautions': _a.cautions,
        'note': 'Illustrative long-run averages, not predictions.',
      };

  Map<String, Object?> _plan(GoalPlan plan) => {
        'goal': plan.goal.name,
        'years': plan.goal.years,
        'future_cost': _r(plan.futureCost),
        'assumed_return': _p(plan.assumedReturn),
        'inflation': _p(_a.inflation),
        'mix': {
          'equity': plan.allocation.equity,
          'debt': plan.allocation.debt,
          'gold': plan.allocation.gold,
          'cash': plan.allocation.cash,
        },
        'monthly_sip_flat': _r(plan.requiredSip),
        'monthly_sip_with_step_up': _r(plan.requiredSipWithStepUp),
        'step_up': _p(plan.stepUp),
        'feasibility': plan.feasibility.name,
        'monthly_surplus': _r(state.profile!.monthlySurplus),
        'steps': plan.steps,
      };

  Map<String, Object?> _planGoal(FinancialProfile p, Map<String, Object?> args) {
    final typeName = args['goal_type'];
    final type = GoalType.values.where((t) => t.name == typeName).firstOrNull ?? GoalType.other;
    final goal = Goal(
      id: 'assistant',
      name: 'This goal',
      type: type,
      todayCost: _num(args, 'today_cost', min: 1),
      years: _num(args, 'years', min: 0.1, max: 60),
      alreadySaved: _num(args, 'already_saved', fallback: 0),
    );
    return _plan(GoalPlanner.plan(goal,
        risk: state.risk, availableMonthly: p.monthlySurplus, a: _a));
  }

  Map<String, Object?> _planIndependence(FinancialProfile p, Map<String, Object?> args) {
    final age = _num(args, 'target_age', min: 0, max: 100).round();
    if (age <= p.age) {
      return _error('Target age $age must be above the current age ${p.age}.');
    }
    return _plan(GoalPlanner.planIndependence(p, targetAge: age, risk: state.risk, a: _a));
  }

  Map<String, Object?> _allocation(Map<String, Object?> args) {
    final years = _num(args, 'horizon_years', min: 0, max: 60);
    final x = AllocationPlanner.suggest(state.risk, years);
    return {
      'risk_profile': state.risk.name,
      'horizon_years': years,
      'equity': x.equity,
      'debt': x.debt,
      'gold': x.gold,
      'cash': x.cash,
      'illustrative_return': _p(x.expectedReturn(_a)),
      'reasons': x.reasons,
      'note': 'Illustrative categories only, not a recommendation of any product.',
    };
  }

  Map<String, Object?> _sip(Map<String, Object?> args) {
    final monthly = _num(args, 'monthly_amount', min: 1, max: 1e8);
    final years = _num(args, 'years', min: 0.1, max: 60);
    final stepUp = _num(args, 'annual_step_up', fallback: _a.sipStepUp, min: 0, max: 0.5);
    final mix = AllocationPlanner.suggest(state.risk, years);
    final rate = mix.expectedReturn(_a);
    final fv = MoneyMath.sipFutureValue(monthly, rate, years, annualStepUp: stepUp);
    return {
      'monthly_amount': _r(monthly),
      'years': years,
      'annual_step_up': _p(stepUp),
      'assumed_return': _p(rate),
      'mix': {'equity': mix.equity, 'debt': mix.debt, 'gold': mix.gold, 'cash': mix.cash},
      'total_invested': _r(MoneyMath.totalContributed(monthly, years, annualStepUp: stepUp)),
      'future_value': _r(fv),
      'future_value_in_todays_money': _r(MoneyMath.toTodaysMoney(fv, _a.inflation, years)),
      'inflation': _p(_a.inflation),
      'note': 'Illustrative: real returns vary and can be negative in some years.',
    };
  }

  Map<String, Object?> _loan(Map<String, Object?> args) {
    final outstanding = _num(args, 'outstanding', min: 1);
    final emi = _num(args, 'emi', min: 0, max: 1e9);
    final rate = _num(args, 'annual_rate', min: 0, max: 0.6);
    final extra = _num(args, 'extra_monthly', fallback: 0, max: 1e9);
    final e = PrepaymentEffect.of(outstanding, emi, rate, extra);
    return {
      'months_to_repay': e.monthsBefore,
      'interest_left': e.interestBefore == null ? null : _r(e.interestBefore!),
      'payment_covers_interest': e.monthsBefore != null,
      if (extra > 0) ...{
        'extra_monthly': _r(extra),
        'months_with_extra': e.monthsAfter,
        'interest_with_extra': e.interestAfter == null ? null : _r(e.interestAfter!),
        'months_saved': e.monthsSaved,
        'interest_saved': e.interestSaved == null ? null : _r(e.interestSaved!),
      },
    };
  }
}
