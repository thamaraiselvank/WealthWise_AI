import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'data/app_repository.dart';
import 'data/database_opener.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Bootstrap());
}

/// Opens the encrypted database and loads saved data before showing the app.
/// The native splash screen covers the (short) loading time.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<(AppRepository, AppState)> _loading = _load();

  Future<(AppRepository, AppState)> _load() async {
    final db = await openAppDatabase();
    final repo = AppRepository(db);
    return (repo, await repo.load());
  }

  Future<void> _resetAndRetry() async {
    await resetLocalData();
    setState(() => _loading = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StartupErrorApp(
            onRetry: () => setState(() => _loading = _load()),
            onReset: _resetAndRetry,
          );
        }
        if (!snapshot.hasData) return const _LoadingApp();
        final (repo, initial) = snapshot.data!;
        return ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            initialAppStateProvider.overrideWithValue(initial),
          ],
          child: const WealthWiseApp(),
        );
      },
    );
  }
}

class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
}

/// Shown if the encrypted database cannot be opened (for example the
/// device key was lost after a phone restore).
class StartupErrorApp extends StatelessWidget {
  final VoidCallback onRetry;
  final Future<void> Function() onReset;
  const StartupErrorApp({super.key, required this.onRetry, required this.onReset});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.lock_reset,
                        size: 56, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text("We couldn't open your saved data",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      'Your data is encrypted with a key stored on this phone. If the '
                      'key is missing, the data cannot be read. You can try again, or '
                      'start fresh (this erases the saved data).',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: onRetry, child: const Text('Try again')),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _confirmReset(context),
                      child: const Text('Start fresh'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start fresh?'),
        content: const Text('Saved data on this phone will be erased.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Erase')),
        ],
      ),
    );
    if (ok == true) await onReset();
  }
}
