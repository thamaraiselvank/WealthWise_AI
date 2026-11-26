import 'dart:math' as math;

import 'package:finance_engine/finance_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';

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

  String? _validate() {
    switch (_step) {
      case 0:
        if (_ageValue < 18 || _ageValue > 70) return 'Please enter an age between 18 and 70.';
      case 1:
        if (parseAmount(_income.text) <= 0) return 'Please enter your monthly income.';
        if (parseAmount(_expenses.text) <= 0) return 'Please enter your monthly expenses.';
      case 3:
        if (_risk.length < RiskQuestionnaire.questions.length) {
          return 'Please answer all the questions.';
        }
    }
    return null;
  }

  void _next() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_step < _stepTitles.length - 1) {
      setState(() {
        _step++;
        if (_step == 4) _targetAge ??= math.min(_ageValue + 20, 60).clamp(_ageValue + 1, 75);
      });
    } else {
      _finish();
    }
  }

  void _finish() {
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
    ref.read(appStateProvider.notifier).completeOnboarding(
          profile: profile,
          riskAnswers: Map.of(_risk),
          fiTargetAge: _targetAge!,
        );
    context.go('/');
  }

  void _useSample() {
    setState(() {
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
    });
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('WealthWise AI'),
        leading: _step > 0
            ? IconButton(
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
                  Text('Step ${_step + 1} of ${_stepTitles.length}',
                      style: t.labelLarge),
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
                  onPressed: _next,
                  child: Text(_step == _stepTitles.length - 1
                      ? 'See my financial plan'
                      : 'Continue'),
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
        3 => _riskStep(),
        _ => _goalStep(),
      };

  List<Widget> _aboutYou() => [
        const _PrivacyBanner(),
        const SizedBox(height: 20),
        _NumberField(controller: _age, label: 'Your age', money: false),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Text('People who depend on your income')),
            IconButton(
              onPressed: _dependents > 0 ? () => setState(() => _dependents--) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_dependents', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              onPressed: () => setState(() => _dependents++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: _useSample,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Just exploring? Try with sample data'),
          ),
        ),
      ];

  List<Widget> _monthly() => [
        _NumberField(controller: _income, label: 'Monthly take-home income'),
        const SizedBox(height: 16),
        _NumberField(
          controller: _expenses,
          label: 'Monthly expenses',
          helper: 'Rent, food, bills, travel, shopping. Do not include EMIs.',
        ),
        const SizedBox(height: 16),
        _NumberField(controller: _emi, label: 'Monthly loan EMIs (if any)'),
      ];

  List<Widget> _assets() => [
        _NumberField(
          controller: _savings,
          label: 'Savings (bank balance, FDs)',
          helper: 'Money you can access quickly in an emergency.',
        ),
        const SizedBox(height: 16),
        _NumberField(
          controller: _investments,
          label: 'Investments (mutual funds, stocks, PPF, etc.)',
        ),
        const SizedBox(height: 16),
        _NumberField(controller: _loans, label: 'Total loans outstanding'),
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

  List<Widget> _riskStep() => [
        for (final q in RiskQuestionnaire.questions) ...[
          Text(q.text, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          for (var i = 0; i < q.options.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(_risk[q.id] == i
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked),
              title: Text(q.options[i].label),
              onTap: () => setState(() => _risk[q.id] = i),
            ),
          const SizedBox(height: 12),
        ],
      ];

  List<Widget> _goalStep() {
    final t = Theme.of(context).textTheme;
    final minAge = _ageValue + 1;
    final maxAge = math.max(75, minAge + 1);
    final target = _targetAge!.clamp(minAge, maxAge);
    return [
      Text('At what age would you like to be financially independent, '
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
              'Your financial details stay on this phone. Approximate numbers are fine.',
              style: TextStyle(color: cs.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helper;
  final bool money;

  const _NumberField({
    required this.controller,
    required this.label,
    this.helper,
    this.money = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 2,
        prefixText: money ? '₹ ' : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
