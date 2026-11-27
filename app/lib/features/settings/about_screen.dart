import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';

import '../../util/format.dart';
import '../../widgets/common.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final a = ref.watch(appStateProvider.select((s) => s.assumptions));
    final rows = [
      ('Inflation', pct(a.inflation, 1)),
      ('Emergency fund', '${a.emergencyFundMonths} months of expenses + EMIs'),
      ('Independence corpus', '${a.corpusMultiple.round()} × yearly expenses'),
      ('Equity return', pct(a.equityReturn, 1)),
      ('Debt return', pct(a.debtReturn, 1)),
      ('Gold return', pct(a.goldReturn, 1)),
      ('Cash return', pct(a.cashReturn, 1)),
      ('Yearly SIP step-up', pct(a.sipStepUp)),
      ('SIP timing', 'Start of each month'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('WealthWise AI', style: t.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'A personal financial planning and education app for people who are new '
            'to saving and investing. It helps you understand where you stand, what '
            'your goals will cost, and which types of investments people commonly '
            'consider for them.',
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'What this app does not do',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• It does not sell financial products or earn commissions.'),
                Text('• It does not recommend specific funds, stocks or schemes.'),
                Text('• It does not hold or move your money.'),
                Text('• It does not send your financial details to any server.'),
              ],
            ),
          ),
          SectionCard(
            title: 'Assumptions used in every plan',
            child: Column(
              children: [
                for (final (k, v) in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(k)),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(v,
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Returns are long-run illustrative averages, not predictions. Real '
                  'returns vary year to year and can be negative. You can change '
                  'these in Settings → Planning assumptions.',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
          const Disclaimer(),
        ],
      ),
    );
  }
}
