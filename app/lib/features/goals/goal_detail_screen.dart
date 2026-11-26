import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';
import 'add_goal_sheet.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFi = goalId == fiGoalId;
    final plan = isFi
        ? ref.watch(fiPlanProvider)
        : ref
            .watch(goalPlansProvider)
            .where((p) => p.goal.id == goalId)
            .firstOrNull;

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Goal not found')),
      );
    }

    final state = ref.watch(appStateProvider);
    final profile = state.profile!;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final color = feasibilityColor(plan.feasibility, cs);
    const a = Assumptions.standard;

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.goal.name),
        actions: [
          if (!isFi) ...[
            IconButton(
              tooltip: 'Edit goal',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => AddGoalSheet(existing: plan.goal),
              ),
            ),
            IconButton(
              tooltip: 'Delete goal',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref, plan.goal),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isFi ? 'Corpus needed' : 'Future cost', style: t.bodyMedium),
                Text(inrShort(plan.futureCost),
                    style: t.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('in ${plan.goal.years.round()} years', style: t.bodySmall),
                const Divider(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: 'Fixed monthly SIP',
                        value: inr(plan.requiredSip),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricTile(
                        label: 'Starting SIP',
                        value: inr(plan.requiredSipWithStepUp),
                        caption: '+${pct(plan.stepUp)} every year',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${feasibilityLabel(plan.feasibility)}. '
                          'Your monthly surplus is ${inr(profile.monthlySurplus)}.',
                          style: TextStyle(color: color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isFi) _TargetAgeCard(currentAge: profile.age, targetAge: state.fiTargetAge),
          SectionCard(
            title: 'Show the math',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, s) in plan.steps.indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 24, child: Text('${i + 1}.')),
                        Expanded(child: Text(s)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SectionCard(
            title: 'Illustrative mix for this goal',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AllocationPie(allocation: plan.allocation),
                const SizedBox(height: 12),
                for (final r in plan.allocation.reasons)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• $r'),
                  ),
              ],
            ),
          ),
          SectionCard(
            title: 'Assumptions',
            child: Text(
              'Inflation ${pct(a.inflation, 1)} · Equity ${pct(a.equityReturn, 1)} · '
              'Debt ${pct(a.debtReturn, 1)} · Gold ${pct(a.goldReturn, 1)} · '
              'Cash ${pct(a.cashReturn, 1)} a year. SIP invested at the start of '
              'each month.${isFi ? ' Corpus = ${a.corpusMultiple.round()}× yearly expenses.' : ''}',
            ),
          ),
          const Disclaimer(),
        ],
      ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Goal goal) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Delete "${goal.name}"?'),
      content: const Text('This goal and its plan will be removed.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  Navigator.of(context).pop();
  await ref.read(appStateProvider.notifier).removeGoal(goal.id);
}

/// What-if slider: move the financial-independence age.
class _TargetAgeCard extends ConsumerWidget {
  final int currentAge;
  final int targetAge;
  const _TargetAgeCard({required this.currentAge, required this.targetAge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final min = currentAge + 1;
    const max = 75;
    return SectionCard(
      title: 'What if I aim for a different age?',
      trailing: Text('Age $targetAge',
          style: Theme.of(context).textTheme.titleMedium),
      child: Slider(
        value: targetAge.clamp(min, max).toDouble(),
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: max - min,
        label: '$targetAge',
        onChanged: (v) =>
            ref.read(appStateProvider.notifier).setFiTargetAge(v.round()),
      ),
    );
  }
}
