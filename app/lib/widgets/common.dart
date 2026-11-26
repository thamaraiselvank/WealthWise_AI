import 'package:finance_engine/finance_engine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

/// Shown under every projection or allocation.
class Disclaimer extends StatelessWidget {
  const Disclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: style?.color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'For education only, not investment advice. Returns and inflation '
              'are assumptions, not guarantees. Consider a SEBI-registered '
              'investment adviser for personalised advice.',
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? trailing;
  const SectionCard({super.key, this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    ?trailing,
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

class AssetColors {
  static const equity = Color(0xFF0F766E);
  static const debt = Color(0xFF3B82F6);
  static const gold = Color(0xFFD4A017);
  static const cash = Color(0xFF94A3B8);
}

/// Donut chart + legend for an illustrative allocation.
class AllocationPie extends StatelessWidget {
  final Allocation allocation;
  const AllocationPie({super.key, required this.allocation});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Equity', allocation.equity, AssetColors.equity),
      ('Debt', allocation.debt, AssetColors.debt),
      ('Gold', allocation.gold, AssetColors.gold),
      ('Cash', allocation.cash, AssetColors.cash),
    ];
    return Row(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 34,
              sections: [
                for (final (_, value, color) in items)
                  if (value > 0)
                    PieChartSectionData(
                      value: value.toDouble(),
                      color: color,
                      radius: 28,
                      showTitle: false,
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value, color) in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: color, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(label)),
                      Text('$value%',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small label + value tile.
class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;
  final Color? valueColor;
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value,
              style: t.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600, color: valueColor)),
          if (caption != null)
            Text(caption!,
                style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
