import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';
import 'learn_content.dart';

class InvestScreen extends ConsumerWidget {
  const InvestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStateProvider);
    final profile = s.profile;
    if (profile == null) return const SizedBox.shrink();

    final horizon = (s.fiTargetAge - profile.age).clamp(1, 60).toDouble();
    final allocation = AllocationPlanner.suggest(s.risk, horizon);
    final t = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Row(
            children: [
              Icon(Icons.speed, color: Theme.of(context).colorScheme.primary, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your risk profile', style: t.bodyMedium),
                    Text(riskLabel(s.risk), style: t.headlineSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Illustrative long-term mix',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'For money you will not need for ${horizon.round()} years, '
                'people with a ${riskLabel(s.risk).toLowerCase()} profile often consider:',
              ),
              const SizedBox(height: 16),
              AllocationPie(allocation: allocation),
              const SizedBox(height: 12),
              for (final r in allocation.reasons)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $r'),
                ),
              const SizedBox(height: 8),
              Text(
                'Short-term goals use a safer mix. Open any goal to see its own mix.',
                style: t.bodySmall,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text('Learn the basics', style: t.titleMedium),
        ),
        for (final topic in learnTopics)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: Icon(topic.icon),
              title: Text(topic.title),
              subtitle: Text(topic.tagline),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.body),
                const SizedBox(height: 8),
                Text('Risk: ${topic.risk}', style: t.labelLarge),
                Text('Often used for: ${topic.goodFor}', style: t.labelLarge),
              ],
            ),
          ),
        const Disclaimer(),
      ],
    );
  }
}
