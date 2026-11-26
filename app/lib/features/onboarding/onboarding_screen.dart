import 'dart:math' as math;

import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/forms.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepTitles = [
    'About you',
    'Monthly money',
    'What you have',
    'Your comfort with risk',
    'Your big goal',
  ];

  int _step = 0;
  bool _saving = false;

  final _age = TextEditingController();
  int _dependents = 0;
  final _income = TextEditingController();
  final _expenses = TextEditingController();
  final _emi = TextEditingController();
  final _savings = TextEditingController();
  final _investments = TextEditingController();
  final _loans = TextEditingController();
  bool _health = false;
  bool _term = false;
  final Map<String, int> _risk = {};
  int? _targetAge;

  int get _ageValue => int.tryParse(_age.text) ?? 0;

  @override
  void dispose() {
    for (final c in [_age, _income, _expenses, _emi, _savings, _investments, _loans]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate() => switch (_step) {
        0 => validAge(_age.text),
        1 => parseAmount(_income.text) <= 0
            ? 'Please enter your monthly income.'
            : parseAmount(_expenses.text) <= 0
                ? 'Please enter your monthly expenses.'
                : null,
        3 => _risk.length < RiskQuestionnaire.questions.length
            ? 'Please answer all the questions.'
            : null,
        _ => null,
      };

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _next() {
    final error = _validate();
    if (error != null) return _showError(error);
    if (_step < _stepTitles.length - 1) {
      setState(() {
        _step++;
        if (_step == 4) {
          _targetAge ??= math.min(_ageValue + 20, 60).clamp(_ageValue + 1, 75);
        }
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final profile = FinancialProfile(
      age: _ageValue,
      monthlyIncome: parseAmount(_income.text),
      monthlyExpenses: parseAmount(_expenses.text),
      monthlyEmi: parseAmount(_emi.text),
      savings: parseAmount(_savings.text),
      investments: parseAmount(_investments.text),
      loanOutstanding: parseAmount(_loans.text),
      dependents: _dependents,
      hasHealthInsurance: _health,
      hasTermInsurance: _term,
    );
    try {
      await ref.read(appStateProvider.notifier).completeOnboarding(
            profile: profile,
            riskAnswers: Map.of(_risk),
            fiTargetAge: _targetAge!,
          );
      if (mounted) context.go('/');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Could not save your details. Please try again.');
    }
  }

  void _useSample() {
    _age.text = '25';
    _dependents = 0;
    _income.text = '40000';
    _expenses.text = '25000';
    _emi.text = '0';
    _savings.text = '80000';
    _investments.text = '20000';
    _loans.text = '0';
    _health = false;
    _term = false;
    for (final q in RiskQuestionnaire.questions) {
      _risk[q.id] = 1;
    }
    _targetAge = 45;
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final last = _step == _stepTitles.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('WealthWise AI'),
        leading: _step > 0
            ? IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _stepTitles.length),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Step ${_step + 1} of ${_stepTitles.length}', style: t.labelLarge),
                  const SizedBox(height: 4),
                  Text(_stepTitles[_step], style: t.headlineSmall),
                  const SizedBox(height: 20),
                  ..._buildStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _next,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(last ? 'See my financial plan' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStep() => switch (_step) {
        0 => _aboutYou(),
        1 => _monthly(),
        2 => _assets(),
        3 => [
            RiskQuestionList(
              answers: _risk,
              onAnswer: (id, i) => setState(() => _risk[id] = i),
            ),
          ],
        _ => _goalStep(),
      };

  List<Widget> _aboutYou() => [
        const _PrivacyBanner(),
        const SizedBox(height: 20),
        NumberField(controller: _age, label: 'Your age', money: false),
        const SizedBox(height: 16),
        CounterField(
          label: 'People who depend on your income',
          value: _dependents,
          onChanged: (v) => setState(() => _dependents = v),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: _saving ? null : _useSample,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Just exploring? Try with sample data'),
          ),
        ),
      ];

  List<Widget> _monthly() => [
        NumberField(controller: _income, label: 'Monthly take-home income'),
        const SizedBox(height: 16),
        NumberField(
          controller: _expenses,
          label: 'Monthly expenses',
          helper: 'Rent, food, bills, travel, shopping. Do not include EMIs.',
        ),
        const SizedBox(height: 16),
        NumberField(controller: _emi, label: 'Monthly loan EMIs (if any)'),
      ];

  List<Widget> _assets() => [
        NumberField(
          controller: _savings,
          label: 'Savings (bank balance, FDs)',
          helper: 'Money you can access quickly in an emergency.',
        ),
        const SizedBox(height: 16),
        NumberField(
          controller: _investments,
          label: 'Investments (mutual funds, stocks, PPF, etc.)',
        ),
        const SizedBox(height: 16),
        NumberField(controller: _loans, label: 'Total loans outstanding'),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('I have health insurance'),
          subtitle: const Text('Personal or family cover, not only from employer'),
          value: _health,
          onChanged: (v) => setState(() => _health = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('I have term life insurance'),
          value: _term,
          onChanged: (v) => setState(() => _term = v),
        ),
      ];

  List<Widget> _goalStep() {
    final t = Theme.of(context).textTheme;
    final minAge = _ageValue + 1;
    final maxAge = math.max(75, minAge + 1);
    final target = _targetAge!.clamp(minAge, maxAge);
    return [
      const Text('At what age would you like to be financially independent, '
          'meaning work becomes optional?'),
      const SizedBox(height: 24),
      Center(child: Text('Age $target', style: t.displaySmall)),
      Slider(
        value: target.toDouble(),
        min: minAge.toDouble(),
        max: maxAge.toDouble(),
        divisions: maxAge - minAge,
        label: '$target',
        onChanged: (v) => setState(() => _targetAge = v.round()),
      ),
      Center(child: Text('${target - _ageValue} years from now')),
      const SizedBox(height: 24),
      Text(
        'You can add more goals, like a house, car or education, after this.',
        style: t.bodySmall,
      ),
    ];
  }
}

class _PrivacyBanner extends StatelessWidget {
  const _PrivacyBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: cs.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your financial details stay on this phone, encrypted. Approximate numbers are fine.',
              style: TextStyle(color: cs.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
