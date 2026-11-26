import 'package:finance_engine/finance_engine.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Whole-number input, optionally prefixed with ₹.
class NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helper;
  final bool money;
  final String? Function(String?)? validator;

  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
    this.money = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
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

/// Minus / value / plus row.
class CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const CounterField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          tooltip: 'Decrease',
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$value', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          tooltip: 'Increase',
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

/// All risk questions with single-choice answers.
class RiskQuestionList extends StatelessWidget {
  final Map<String, int> answers;
  final void Function(String questionId, int optionIndex) onAnswer;

  const RiskQuestionList({super.key, required this.answers, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final q in RiskQuestionnaire.questions) ...[
          Text(q.text, style: t.titleSmall),
          const SizedBox(height: 4),
          for (var i = 0; i < q.options.length; i++)
            Semantics(
              selected: answers[q.id] == i,
              inMutuallyExclusiveGroup: true,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(answers[q.id] == i
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked),
                title: Text(q.options[i].label),
                onTap: () => onAnswer(q.id, i),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

String? requiredPositive(String? v) =>
    (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Please enter an amount' : null;

String? validAge(String? v) {
  final a = int.tryParse(v ?? '') ?? 0;
  return (a < 18 || a > 70) ? 'Please enter an age between 18 and 70.' : null;
}
