import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';

/// What the user owns, owes, and the difference.
class NetWorthCard extends ConsumerWidget {
  final HealthReport report;
  const NetWorthCard({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(appStateProvider).profile!;
    final sheet = p.balanceSheet;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final owned = <(String, IconData, double)>[
      if (sheet != null)
        for (final type in AssetType.values)
          if (sheet.totalOf(type) > 0)
            (assetTypeLabel(type), assetTypeIcon(type), sheet.totalOf(type))
    ];

    return SectionCard(
      title: 'Net worth',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(inrShort(report.netWorth),
              style: t.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: report.netWorth < 0 ? cs.error : null)),
          Text('Everything you own minus everything you owe', style: t.bodySmall),
          const SizedBox(height: 12),
          _row(context, 'You own', inr(p.totalAssets), bold: true),
          for (final (label, icon, value) in owned)
            _row(context, label, inr(value), icon: icon),
          _row(context, 'You owe', inr(p.loanOutstanding), bold: true),
          if (p.totalAssets > 0 && p.loanOutstanding > 0)
            _row(context, 'Loans as a share of what you own', pct(report.debtToAssets)),
          if (sheet == null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.push('/settings/profile'),
              icon: const Icon(Icons.list_alt),
              label: const Text('List assets and loans one by one'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {IconData? icon, bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.w600) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 8),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// Loan-by-loan view in the order extra repayments are commonly directed.
class DebtCard extends StatelessWidget {
  final DebtReport debt;
  const DebtCard({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final months = debt.debtFreeInMonths;

    return SectionCard(
      title: 'Your loans',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            months != null && months > 0
                ? 'Debt-free in about ${durationLabel(months)} at your current EMIs.'
                : debt.missingRates
                    ? 'Add interest rates to your loans to see when you will be debt-free.'
                    : 'At current payments, at least one loan never gets paid off.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 8),
          for (final (i, l) in debt.payoffOrder.indexed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
              title: Text(loanTypeLabel(l.loan.type)),
              subtitle: Text([
                '${inr(l.loan.outstanding)} owed · EMI ${inr(l.loan.emi)}',
                if (l.loan.annualRate != null) '${pct(l.loan.annualRate!, 1)} a year',
                if (l.monthsLeft != null && l.monthsLeft! > 0)
                  'paid off in ${durationLabel(l.monthsLeft!)}, interest left ${inrShort(l.interestLeft!)}',
                if (l.emiTooLow) 'payment does not cover the interest',
                if (l.loan.annualRate == null) 'rate not entered',
              ].join(' · ')),
              trailing: l.isHighCost
                  ? Icon(Icons.priority_high, color: cs.error, semanticLabel: 'Costly debt')
                  : null,
            ),
          const SizedBox(height: 4),
          Text(
            'A common approach: keep paying every EMI, and put any extra money '
            'towards the loan at the top of this list (highest interest first).',
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}
