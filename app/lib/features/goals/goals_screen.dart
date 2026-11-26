import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';
import 'add_goal_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fi = ref.watch(fiPlanProvider);
    final plans = ref.watch(goalPlansProvider);
    final surplus = ref.watch(appStateProvider).profile?.monthlySurplus ?? 0;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => const AddGoalSheet(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add goal'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text('You can invest up to ${inr(surplus)} a month (your monthly surplus). '
              'Each goal shows what it needs on its own.'),
          const SizedBox(height: 16),
          if (fi != null) _GoalCard(plan: fi, id: fiGoalId),
          for (final p in plans) _GoalCard(plan: p, id: p.goal.id),
          if (plans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Add goals like a house, car or children\'s education to see how much to set aside for each.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          const Disclaimer(),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalPlan plan;
  final String id;
  const _GoalCard({required this.plan, required this.id});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final color = feasibilityColor(plan.feasibility, cs);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/goal/$id'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(goalTypeIcon(plan.goal.type), color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(plan.goal.name, style: t.titleMedium)),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Kv('Target', inrShort(plan.futureCost),
                        '${plan.goal.years.round()} yrs'),
                  ),
                  Expanded(
                    child: _Kv('Monthly SIP', inr(plan.requiredSip),
                        'or ${inr(plan.requiredSipWithStepUp)} + step-up'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.circle, size: 10, color: color),
                  const SizedBox(width: 6),
                  Text(feasibilityLabel(plan.feasibility),
                      style: t.labelLarge?.copyWith(color: color)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kv extends StatelessWidget {
  final String k;
  final String v;
  final String sub;
  const _Kv(this.k, this.v, this.sub);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: t.bodySmall?.copyWith(color: muted)),
        Text(v, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        Text(sub, style: t.bodySmall?.copyWith(color: muted)),
      ],
    );
  }
}
