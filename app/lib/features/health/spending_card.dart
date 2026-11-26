import 'package:finance_engine/finance_engine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';

/// "Where your money goes": expense pie + rule-of-thumb insights, or a
/// prompt to add a breakdown.
class SpendingCard extends ConsumerWidget {
  const SpendingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appStateProvider).profile;
    if (profile == null) return const SizedBox.shrink();
    final breakdown = profile.expenseBreakdown;

    if (breakdown == null || breakdown.isEmpty) {
      return SectionCard(
        title: 'Where your money goes',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Split your expenses into categories like rent, food and shopping to '
              'see where your money goes and where you could save.',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/settings/profile'),
              icon: const Icon(Icons.pie_chart_outline),
              label: const Text('Add expense breakdown'),
            ),
          ],
        ),
      );
    }

    final analysis = ExpenseAnalyzer.analyze(breakdown, profile.monthlyIncome);
    final t = Theme.of(context).textTheme;

    return SectionCard(
      title: 'Where your money goes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Semantics(
                label: 'Expense breakdown chart',
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      for (final line in analysis.lines)
                        PieChartSectionData(
                          value: line.amount,
                          color: expenseColor(line.category),
                          radius: 30,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final line in analysis.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(expenseIcon(line.category), size: 18, color: expenseColor(line.category)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(expenseLabel(line.category))),
                  const SizedBox(width: 8),
                  Text(inr(line.amount)),
                  SizedBox(
                    width: 48,
                    child: Text(pct(line.shareOfSpending),
                        textAlign: TextAlign.end, style: t.bodySmall),
                  ),
                ],
              ),
            ),
          if (analysis.total != profile.monthlyExpenses)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Categories add up to ${inr(analysis.total)}, but your monthly '
                'expenses are ${inr(profile.monthlyExpenses)}. Update your profile to match.',
                style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const Divider(height: 24),
          for (final i in analysis.insights)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(i.title),
              subtitle: Text(i.detail),
            ),
        ],
      ),
    );
  }
}
