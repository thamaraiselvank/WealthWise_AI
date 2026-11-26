import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/export_service.dart';
import '../../state/app_state.dart';
import '../../util/format.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStateProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, color: cs.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your data is stored only on this phone, encrypted. '
                    'WealthWise AI has no account and no server copy of it.',
                    style: TextStyle(color: cs.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const _Header('Your profile'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit financial details'),
            subtitle: Text(s.profile == null
                ? ''
                : 'Age ${s.profile!.age} · Income ${inr(s.profile!.monthlyIncome)}/month'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Retake risk questionnaire'),
            subtitle: Text('Currently ${riskLabel(s.risk)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/risk'),
          ),
          const _Header('Your data'),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Export my data'),
            subtitle: const Text('Save or share a copy as a JSON file'),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: cs.error),
            title: Text('Delete all my data', style: TextStyle(color: cs.error)),
            subtitle: const Text('Permanently erase your profile and goals from this phone'),
            onTap: () => _confirmDelete(context, ref),
          ),
          const _Header('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About WealthWise AI'),
            subtitle: const Text('How it works, assumptions and disclaimer'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/about'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ExportService(ref.read(repositoryProvider)).shareExport();
    } catch (_) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not export your data. Please try again.')));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Delete all data?'),
        content: const Text(
          'This permanently erases your profile, risk answers and goals from this '
          'phone. It cannot be undone. Consider exporting your data first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(appStateProvider.notifier).deleteAllData();
      if (context.mounted) context.go('/onboarding');
      messenger.showSnackBar(const SnackBar(content: Text('All your data was deleted.')));
    } catch (_) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not delete data. Please try again.')));
    }
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
