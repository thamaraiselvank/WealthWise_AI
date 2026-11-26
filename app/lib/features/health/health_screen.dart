import 'package:finance_engine/finance_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';
import 'spending_card.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(healthReportProvider);
    if (report == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ScoreCard(report: report),
        _TwoColumn(
          children: [
            MetricTile(
              label: 'Left each month',
              value: inr(report.monthlySurplus),
              valueColor: report.monthlySurplus < 0 ? cs.error : null,
            ),
            MetricTile(
              label: 'Savings rate',
              value: pct(report.savingsRate, 1),
              caption: 'Aim for 20%+',
            ),
            MetricTile(
              label: 'Emergency cover',
              value: '${report.emergencyMonthsCovered.toStringAsFixed(1)} mo',
              caption: 'Target 6 months',
            ),
            MetricTile(
              label: 'EMI / income',
              value: pct(report.debtToIncome, 0),
              caption: 'Keep under 40%',
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'What to do next',
          child: Column(
            children: [
              for (final (i, a) in report.actions.indexed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                  title: Text(a.title),
                  subtitle: Text(a.detail),
                ),
            ],
          ),
        ),
        const SpendingCard(),
        SectionCard(
          title: 'Emergency fund',
          child: _EmergencyFund(report: report),
        ),
        SectionCard(
          title: 'How your score is calculated',
          child: Column(
            children: [
              for (final part in report.parts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(part.label)),
                          Text('${part.points.round()} / ${part.max.round()}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: part.points / part.max,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Disclaimer(),
      ],
    );
  }
}

/// Two tiles per row, each row as tall as its tallest tile (no fixed height,
/// so large system fonts never overflow).
class _TwoColumn extends StatelessWidget {
  final List<Widget> children;
  const _TwoColumn({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: children[i]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: i + 1 < children.length
                        ? children[i + 1]
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final HealthReport report;
  const _ScoreCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final (label, color) = switch (report.band) {
      HealthBand.excellent => ('Excellent', Colors.green.shade600),
      HealthBand.good => ('Good', Colors.teal),
      HealthBand.fair => ('Fair', Colors.orange.shade700),
      HealthBand.needsAttention => ('Needs attention', Theme.of(context).colorScheme.error),
    };
    return SectionCard(
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: report.score / 100,
                  strokeWidth: 10,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
                Center(
                  child: Text('${report.score}',
                      style: t.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Financial health score', style: t.bodyMedium),
                const SizedBox(height: 4),
                Text(label, style: t.headlineSmall?.copyWith(color: color)),
                const SizedBox(height: 4),
                Text('out of 100', style: t.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyFund extends StatelessWidget {
  final HealthReport report;
  const _EmergencyFund({required this.report});

  @override
  Widget build(BuildContext context) {
    final have = report.emergencyTarget - report.emergencyGap;
    final progress =
        report.emergencyTarget <= 0 ? 1.0 : (have / report.emergencyTarget).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Text('${inr(have)} of ${inr(report.emergencyTarget)}'),
        const SizedBox(height: 4),
        Text(
          report.emergencyGap > 0
              ? 'Build this first, before investing for goals. Keep it in a savings account, sweep FD or liquid fund.'
              : 'Your emergency fund is complete.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
