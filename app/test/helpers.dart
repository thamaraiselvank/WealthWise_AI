import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wealthwise_ai/app.dart';
import 'package:wealthwise_ai/data/app_repository.dart';
import 'package:wealthwise_ai/data/database.dart';
import 'package:wealthwise_ai/state/app_state.dart';

/// A fresh in-memory (unencrypted) database for tests.
AppRepository newTestRepository() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return AppRepository(db);
}

/// Pumps the full app the same way main() does, with saved state loaded.
Future<void> pumpApp(
  WidgetTester tester,
  AppRepository repo, {
  Size size = const Size(420, 900),
  double textScale = 1.0,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final initial = await repo.load();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      repositoryProvider.overrideWithValue(repo),
      initialAppStateProvider.overrideWithValue(initial),
    ],
    child: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
        platformBrightness:
            themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      ),
      child: const WealthWiseApp(),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> onboardWithSample(WidgetTester tester) async {
  await tester.tap(find.text('Just exploring? Try with sample data'));
  await tester.pumpAndSettle();
}

/// The page's main vertical scroll view. (Text fields contain their own
/// horizontal Scrollable, so `find.byType(Scrollable).last` can pick one.)
Finder pageScrollable() => find
    .byWidgetPredicate((w) =>
        w is Scrollable && axisDirectionToAxis(w.axisDirection) == Axis.vertical)
    .last;
