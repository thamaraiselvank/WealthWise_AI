import 'package:finance_engine/finance_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../util/format.dart';
import 'forms.dart';

/// Optional "split my expenses by category" section, shared by onboarding
/// and profile editing. Reports the breakdown (or null when switched off).
class ExpenseBreakdownEditor extends StatefulWidget {
  final ExpenseBreakdown? initial;
  final ValueChanged<ExpenseBreakdown?> onChanged;

  const ExpenseBreakdownEditor({super.key, this.initial, required this.onChanged});

  @override
  State<ExpenseBreakdownEditor> createState() => _ExpenseBreakdownEditorState();
}

class _ExpenseBreakdownEditorState extends State<ExpenseBreakdownEditor> {
  late bool _enabled = widget.initial != null;
  late final Map<ExpenseCategory, TextEditingController> _controllers = {
    for (final c in ExpenseCategory.values)
      c: TextEditingController(
        text: (widget.initial?[c] ?? 0) > 0 ? widget.initial![c].round().toString() : '',
      )..addListener(_report),
  };

  ExpenseBreakdown get _current => ExpenseBreakdown({
        for (final e in _controllers.entries) e.key: parseAmount(e.value.text),
      });

  void _report() {
    setState(() {});
    widget.onChanged(_enabled ? _current : null);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Split my expenses by category'),
          subtitle: const Text('Optional. Shows where your money goes.'),
          value: _enabled,
          onChanged: (v) {
            setState(() => _enabled = v);
            _report();
          },
        ),
        if (_enabled) ...[
          for (final c in ExpenseCategory.values)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(expenseIcon(c), color: expenseColor(c)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberField(controller: _controllers[c]!, label: expenseLabel(c)),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Total monthly expenses: ${inr(_current.total)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ],
    );
  }
}
