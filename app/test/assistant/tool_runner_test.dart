import 'dart:convert';
import 'dart:io';

import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthwise_ai/features/assistant/profile_summary.dart';
import 'package:wealthwise_ai/features/assistant/tool_runner.dart';
import 'package:wealthwise_ai/state/app_state.dart';

final _state = AppState(
  profile: FinancialProfile.detailed(
    age: 30,
    monthlyIncome: 90000,
    monthlyExpenses: 40000,
    dependents: 1,
    sheet: const BalanceSheet(
      assets: [
        Asset(id: 'a', type: AssetType.bank, value: 200000, label: 'My salary account'),
        Asset(id: 'b', type: AssetType.mutualFundsStocks, value: 300000),
      ],
      loans: [
        Loan(id: 'l', type: LoanType.creditCard, outstanding: 40000, emi: 4000,
            annualRate: 0.36, label: 'Card ending 4242'),
      ],
    ),
  ),
  risk: RiskProfile.moderate,
  fiTargetAge: 50,
  goals: const [
    Goal(id: 'g', name: 'Villa for Priya', type: GoalType.house, todayCost: 5000000, years: 10),
  ],
);

/// Sample arguments for every function in the shared contract.
const _sampleArgs = <String, Map<String, Object?>>{
  'get_health_report': {},
  'get_assumptions': {},
  'plan_goal': {'today_cost': 1500000, 'years': 8, 'goal_type': 'car'},
  'plan_independence': {'target_age': 50},
  'suggest_allocation': {'horizon_years': 12},
  'sip_projection': {'monthly_amount': 10000, 'years': 15},
  'loan_payoff': {'outstanding': 500000, 'emi': 12000, 'annual_rate': 0.1, 'extra_monthly': 3000},
};

void main() {
  final contract = jsonDecode(File('../shared/assistant_tools.json').readAsStringSync())
      as Map<String, dynamic>;
  final contractNames = {for (final f in contract['functions'] as List) (f as Map)['name'] as String};

  test('the runner handles exactly the functions the backend declares', () {
    expect(ToolRunner.names, contractNames);
    expect(_sampleArgs.keys.toSet(), contractNames);
  });

  test('every function returns a small JSON result without errors', () {
    final runner = ToolRunner(_state);
    for (final name in contractNames) {
      final result = runner.run(name, _sampleArgs[name]!);
      expect(result.containsKey('error'), isFalse, reason: '$name: $result');
      final encoded = jsonEncode(result);
      expect(encoded.length, lessThan(8000), reason: name); // backend limit
    }
  });

  test('results come from the engine with the user assumptions', () {
    final s = AppState(
      profile: _state.profile,
      risk: _state.risk,
      assumptions: Assumptions.standard.withValue(AssumptionField.inflation, 0.08),
    );
    final r = ToolRunner(s).run('plan_independence', {'target_age': 50});
    final engine = GoalPlanner.planIndependence(s.profile!,
        targetAge: 50, risk: s.risk, a: s.assumptions);
    expect(r['monthly_sip_flat'], engine.requiredSip.round());
    expect(r['inflation'], 0.08);
    expect((r['steps'] as List).first, contains('Monthly expenses today'));
  });

  test('loan payoff reports the effect of an extra payment', () {
    final r = ToolRunner(_state).run('loan_payoff', _sampleArgs['loan_payoff']!);
    expect(r['months_saved'], greaterThan(0));
    expect(r['interest_saved'], greaterThan(0));
  });

  test('bad arguments become errors the model can explain', () {
    final runner = ToolRunner(_state);
    expect(runner.run('plan_independence', {'target_age': 25})['error'], contains('above'));
    expect(runner.run('plan_goal', {'years': 5})['error'], contains('today_cost'));
    expect(runner.run('sip_projection', {'monthly_amount': 'abc', 'years': 5})['error'], isNotNull);
    expect(runner.run('send_money', {})['error'], contains('Unknown'));
    expect(ToolRunner(const AppState()).run('get_health_report', {})['error'], isNotNull);
  });

  test('profile summary is numbers only: no names or labels leave the phone', () {
    final summary = buildProfileSummary(_state, null);
    final text = jsonEncode(summary);
    for (final secret in ['Villa', 'Priya', 'salary account', '4242']) {
      expect(text, isNot(contains(secret)));
    }
    // Every key is on the backend whitelist (backend/app/chat/schemas.py).
    const allowed = {
      'age', 'dependents', 'monthly_income', 'monthly_expenses', 'monthly_emi',
      'monthly_surplus', 'savings', 'investments', 'property_value', 'loans_total',
      'net_worth', 'has_health_insurance', 'has_term_insurance', 'risk_profile',
      'fi_target_age', 'health_score', 'goals', 'loans', 'assumptions',
    };
    expect(allowed.containsAll(summary.keys), isTrue);
    expect((summary['goals'] as List).single, {
      'type': 'house', 'today_cost': 5000000.0, 'years': 10.0, 'already_saved': 0.0,
    });
    expect((summary['loans'] as List).single, {
      'type': 'creditCard', 'outstanding': 40000.0, 'emi': 4000.0, 'annual_rate': 0.36,
    });
  });
}
