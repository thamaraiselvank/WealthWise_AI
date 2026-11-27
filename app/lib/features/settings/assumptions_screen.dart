import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';

/// Lets the user edit every planning assumption within safe ranges.
/// Changes apply to all plans immediately.
class AssumptionsScreen extends ConsumerWidget {
  const AssumptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(appStateProvider.select((s) => s.assumptions));
    final fi = ref.watch(fiPlanProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assumptions'),
        actions: [
          TextButton(
            onPressed: a.isStandard ? null : notifier.resetAssumptions,
            child: const Text('Reset all'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'These numbers drive every plan in the app. The defaults are common '
            'long-run averages for India. Change them if you want to see a more '
            'cautious or a different scenario.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (fi != null)
            SectionCard(
              title: 'Live preview',
              child: Text(
                '${fi.goal.name}: corpus ${inrShort(fi.futureCost)}, '
                'fixed SIP ${inr(fi.requiredSip)}/month.',
              ),
            ),
          for (final c in a.cautions)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: cs.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: cs.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(c, style: TextStyle(color: cs.onErrorContainer)),
                    ),
                  ],
                ),
              ),
            ),
          for (final spec in AssumptionSpec.all)
            _AssumptionTile(
              spec: spec,
              value: a.valueOf(spec.field),
              onChanged: (v) => notifier.setAssumptions(a.withValue(spec.field, v)),
            ),
          const Disclaimer(),
        ],
      ),
    );
  }
}

class _AssumptionTile extends StatelessWidget {
  final AssumptionSpec spec;
  final double value;
  final ValueChanged<double> onChanged;
  const _AssumptionTile(
      {required this.spec, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final def = Assumptions.standard.valueOf(spec.field);
    final changed = (value - def).abs() > 1e-9;

    return SectionCard(
      title: spec.label,
      trailing: Text(spec.format(value),
          style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.bold, color: changed ? cs.primary : null)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: spec.clamp(value),
            min: spec.min,
            max: spec.max,
            divisions: spec.divisions,
            label: spec.format(value),
            semanticFormatterCallback: spec.format,
            onChanged: onChanged,
          ),
          Text(spec.help, style: t.bodySmall),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                'Default ${spec.format(def)} · range ${spec.format(spec.min)}–${spec.format(spec.max)}',
                style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              if (changed)
                TextButton(
                  onPressed: () => onChanged(def),
                  child: const Text('Use default'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
