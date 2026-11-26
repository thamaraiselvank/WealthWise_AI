import 'package:finance_engine/finance_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';

/// Goal types the user can add manually. FI / retirement is built in.
const _addableTypes = [
  GoalType.house,
  GoalType.car,
  GoalType.education,
  GoalType.wealthCreation,
  GoalType.passiveIncome,
  GoalType.other,
];

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  GoalType _type = GoalType.house;
  final _name = TextEditingController(text: goalTypeLabel(GoalType.house));
  final _cost = TextEditingController();
  final _years = TextEditingController();
  final _saved = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _cost, _years, _saved]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(appStateProvider.notifier).addGoal(Goal(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _name.text.trim(),
          type: _type,
          todayCost: parseAmount(_cost.text),
          years: parseAmount(_years.text),
          alreadySaved: parseAmount(_saved.text),
        ));
    Navigator.of(context).pop();
  }

  String? _positive(String? v) =>
      parseAmount(v ?? '') <= 0 ? 'Enter a value greater than 0' : null;

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add a goal', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in _addableTypes)
                    ChoiceChip(
                      avatar: Icon(goalTypeIcon(type), size: 18),
                      label: Text(goalTypeLabel(type)),
                      selected: _type == type,
                      onSelected: (_) => setState(() {
                        _type = type;
                        _name.text = goalTypeLabel(type);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: 'Goal name', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cost,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                decoration: const InputDecoration(
                  labelText: 'Cost in today\'s money',
                  prefixText: '₹ ',
                  helperText: 'We adjust this for inflation automatically.',
                  border: OutlineInputBorder(),
                ),
                validator: _positive,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _years,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                decoration: const InputDecoration(
                    labelText: 'In how many years?', border: OutlineInputBorder()),
                validator: (v) {
                  final y = parseAmount(v ?? '');
                  return (y < 1 || y > 50) ? 'Enter 1 to 50 years' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _saved,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                decoration: const InputDecoration(
                  labelText: 'Already saved for this (optional)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _save, child: const Text('Add goal')),
            ],
          ),
        ),
      ),
    );
  }
}
