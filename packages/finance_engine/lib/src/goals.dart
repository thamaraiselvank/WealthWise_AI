import 'allocation.dart';
import 'assumptions.dart';
import 'money_math.dart';
import 'profile.dart';
import 'risk.dart';

enum GoalType {
  house,
  car,
  retirement,
  education,
  passiveIncome,
  wealthCreation,
  financialIndependence,
  other,
}

/// A user goal. For retirement / FI goals, [todayCost] is ignored and the
/// corpus is derived from expenses.
class Goal {
  final String id;
  final String name;
  final GoalType type;

  /// Cost in today's rupees.
  final double todayCost;

  /// Years from now until the goal.
  final double years;

  /// Amount already set aside for this goal.
  final double alreadySaved;

  const Goal({
    required this.id,
    required this.name,
    required this.type,
    required this.todayCost,
    required this.years,
    this.alreadySaved = 0,
  });
}

enum Feasibility { onTrack, stretch, notFeasible }

/// The full, explainable plan for one goal.
class GoalPlan {
  final Goal goal;
  final double futureCost;
  final Allocation allocation;
  final double assumedReturn;
  final double requiredSip;
  final double requiredSipWithStepUp;
  final double stepUp;
  final Feasibility feasibility;

  /// Plain-language steps of the calculation, shown under "Show the math".
  final List<String> steps;

  const GoalPlan({
    required this.goal,
    required this.futureCost,
    required this.allocation,
    required this.assumedReturn,
    required this.requiredSip,
    required this.requiredSipWithStepUp,
    required this.stepUp,
    required this.feasibility,
    required this.steps,
  });
}

class GoalPlanner {
  GoalPlanner._();

  /// Plans one goal. [availableMonthly] is how much the user can invest for
  /// this goal (used for the feasibility rating).
  static GoalPlan plan(
    Goal goal, {
    required RiskProfile risk,
    required double availableMonthly,
    Assumptions a = Assumptions.standard,
    double stepUp = 0.10,
  }) {
    final allocation = AllocationPlanner.suggest(risk, goal.years);
    final rate = allocation.expectedReturn(a);
    final futureCost = MoneyMath.inflate(goal.todayCost, a.inflation, goal.years);

    final sip = MoneyMath.requiredSip(futureCost, rate, goal.years,
        existingCorpus: goal.alreadySaved);
    final sipStep = MoneyMath.requiredSip(futureCost, rate, goal.years,
        existingCorpus: goal.alreadySaved, annualStepUp: stepUp);

    final steps = [
      'Cost today: ₹${_r(goal.todayCost)}',
      'After ${_y(goal.years)} years at ${_p(a.inflation)} inflation: ₹${_r(futureCost)}',
      if (goal.alreadySaved > 0)
        'Already saved ₹${_r(goal.alreadySaved)}, grows to ₹${_r(MoneyMath.futureValue(goal.alreadySaved, rate, goal.years))}',
      'Illustrative mix: ${allocation.equity}% equity, ${allocation.debt}% debt, ${allocation.gold}% gold, ${allocation.cash}% cash → assumed return ${_p(rate)} a year',
      'Monthly SIP needed (same amount every month): ₹${_r(sip)}',
      'Or start at ₹${_r(sipStep)} and increase it ${_p(stepUp)} every year',
    ];

    return GoalPlan(
      goal: goal,
      futureCost: futureCost,
      allocation: allocation,
      assumedReturn: rate,
      requiredSip: sip,
      requiredSipWithStepUp: sipStep,
      stepUp: stepUp,
      feasibility: _feasibility(sip, sipStep, availableMonthly),
      steps: steps,
    );
  }

  /// Financial independence / retirement plan derived from the profile.
  ///
  /// Corpus = annual expenses at [targetAge] (inflated) × corpus multiple.
  /// Existing investments count towards the corpus; savings are treated as
  /// the emergency fund and excluded.
  static GoalPlan planIndependence(
    FinancialProfile p, {
    required int targetAge,
    required RiskProfile risk,
    Assumptions a = Assumptions.standard,
    double stepUp = 0.10,
    GoalType type = GoalType.financialIndependence,
  }) {
    final years = (targetAge - p.age).toDouble();
    if (years <= 0) {
      throw ArgumentError('targetAge must be greater than current age');
    }
    final futureMonthly = MoneyMath.inflate(p.monthlyExpenses, a.inflation, years);
    final corpus = futureMonthly * 12 * a.corpusMultiple;
    final allocation = AllocationPlanner.suggest(risk, years);
    final rate = allocation.expectedReturn(a);

    final sip = MoneyMath.requiredSip(corpus, rate, years,
        existingCorpus: p.investments);
    final sipStep = MoneyMath.requiredSip(corpus, rate, years,
        existingCorpus: p.investments, annualStepUp: stepUp);

    final goal = Goal(
      id: type.name,
      name: type == GoalType.retirement
          ? 'Retire at $targetAge'
          : 'Financial independence at $targetAge',
      type: type,
      todayCost: p.monthlyExpenses * 12 * a.corpusMultiple,
      years: years,
      alreadySaved: p.investments,
    );

    final steps = [
      'Monthly expenses today: ₹${_r(p.monthlyExpenses)}',
      'At age $targetAge (${_y(years)} years, ${_p(a.inflation)} inflation): ₹${_r(futureMonthly)} a month',
      'Corpus needed = yearly expenses × ${a.corpusMultiple.toStringAsFixed(0)} = ₹${_r(corpus)}',
      if (p.investments > 0)
        'Current investments ₹${_r(p.investments)} grow to ₹${_r(MoneyMath.futureValue(p.investments, rate, years))}',
      'Illustrative mix: ${allocation.equity}% equity, ${allocation.debt}% debt, ${allocation.gold}% gold, ${allocation.cash}% cash → assumed return ${_p(rate)} a year',
      'Monthly SIP needed (same amount every month): ₹${_r(sip)}',
      'Or start at ₹${_r(sipStep)} and increase it ${_p(stepUp)} every year',
    ];

    return GoalPlan(
      goal: goal,
      futureCost: corpus,
      allocation: allocation,
      assumedReturn: rate,
      requiredSip: sip,
      requiredSipWithStepUp: sipStep,
      stepUp: stepUp,
      feasibility: _feasibility(sip, sipStep, p.monthlySurplus),
      steps: steps,
    );
  }

  static Feasibility _feasibility(double sip, double sipStep, double available) {
    if (sip <= available) return Feasibility.onTrack;
    if (sipStep <= available) return Feasibility.stretch;
    return Feasibility.notFeasible;
  }

  static String _r(double v) => v.round().toString();
  static String _p(double v) => '${(v * 100).toStringAsFixed(1)}%';
  static String _y(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
