import 'package:material_ui/material_ui.dart';

class ComingSoonScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String phase;

  const ComingSoonScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: cs.primary),
            const SizedBox(height: 16),
            Text(title, style: t.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Chip(label: Text('Coming in $phase')),
          ],
        ),
      ),
    );
  }
}
