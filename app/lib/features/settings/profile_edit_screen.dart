import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/forms.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FinancialProfile _original;
  late final TextEditingController _age, _income, _expenses, _emi, _savings,
      _investments, _loans;
  late int _dependents;
  late bool _health, _term;
  bool _saving = false;

  TextEditingController _c(num v) => TextEditingController(text: v.round().toString());

  @override
  void initState() {
    super.initState();
    _original = ref.read(appStateProvider).profile!;
    final p = _original;
    _age = _c(p.age);
    _income = _c(p.monthlyIncome);
    _expenses = _c(p.monthlyExpenses);
    _emi = _c(p.monthlyEmi);
    _savings = _c(p.savings);
    _investments = _c(p.investments);
    _loans = _c(p.loanOutstanding);
    _dependents = p.dependents;
    _health = p.hasHealthInsurance;
    _term = p.hasTermInsurance;
  }

  @override
  void dispose() {
    for (final c in [_age, _income, _expenses, _emi, _savings, _investments, _loans]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(appStateProvider.notifier).updateProfile(FinancialProfile(
            age: int.parse(_age.text),
            monthlyIncome: parseAmount(_income.text),
            monthlyExpenses: parseAmount(_expenses.text),
            monthlyEmi: parseAmount(_emi.text),
            savings: parseAmount(_savings.text),
            investments: parseAmount(_investments.text),
            loanOutstanding: parseAmount(_loans.text),
            dependents: _dependents,
            hasHealthInsurance: _health,
            hasTermInsurance: _term,
          ));
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (_) {
      setState(() => _saving = false);
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(title: const Text('Financial details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            NumberField(controller: _age, label: 'Age', money: false, validator: validAge),
            CounterField(
              label: 'People who depend on your income',
              value: _dependents,
              onChanged: (v) => setState(() => _dependents = v),
            ),
            gap,
            NumberField(
                controller: _income,
                label: 'Monthly take-home income',
                validator: requiredPositive),
            gap,
            NumberField(
              controller: _expenses,
              label: 'Monthly expenses (excluding EMIs)',
              validator: requiredPositive,
            ),
            gap,
            NumberField(controller: _emi, label: 'Monthly loan EMIs'),
            gap,
            NumberField(controller: _savings, label: 'Savings (bank balance, FDs)'),
            gap,
            NumberField(controller: _investments, label: 'Investments'),
            gap,
            NumberField(controller: _loans, label: 'Total loans outstanding'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('I have health insurance'),
              value: _health,
              onChanged: (v) => setState(() => _health = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('I have term life insurance'),
              value: _term,
              onChanged: (v) => setState(() => _term = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
