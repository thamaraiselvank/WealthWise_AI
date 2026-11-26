import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

/// Visits every screen. Any layout overflow throws and fails the test, so
/// this guards large system fonts, small phones and dark mode.
Future<void> visitAllScreens(
  WidgetTester tester, {
  Size size = const Size(420, 900),
  double textScale = 1.0,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final repo = newTestRepository();
  // A profile with every optional section filled in, plus a custom goal.
  await repo.saveOnboarding(
    profile: FinancialProfile(
      age: 32,
      monthlyIncome: 85000,
      monthlyExpenses: 52000,
      monthlyEmi: 18000,
      savings: 150000,
      investments: 300000,
      loanOutstanding: 900000,
      dependents: 2,
      expenseBreakdown: ExpenseBreakdown({
        ExpenseCategory.housing: 22000,
        ExpenseCategory.food: 12000,
        ExpenseCategory.transport: 5000,
        ExpenseCategory.utilities: 3000,
        ExpenseCategory.lifestyle: 10000,
      }),
    ),
    riskAnswers: {for (final q in RiskQuestionnaire.questions) q.id: 2},
    fiTargetAge: 50,
  );
  await repo.upsertGoal(const Goal(
    id: 'g1',
    name: "Children's higher education abroad",
    type: GoalType.education,
    todayCost: 4500000,
    years: 14,
    alreadySaved: 200000,
  ));
  await pumpApp(tester, repo, size: size, textScale: textScale, themeMode: themeMode);

  Future<void> scrollThrough() async {
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isEmpty) return;
    for (var i = 0; i < 12; i++) {
      await tester.drag(scrollable.last, const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    // Back to the top so later lookups start from a known position.
    for (var i = 0; i < 12; i++) {
      await tester.drag(scrollable.last, const Offset(0, 600));
      await tester.pumpAndSettle();
    }
  }

  for (final tab in ['Health', 'Goals', 'Invest', 'Ask AI', 'Progress']) {
    await tester.tap(find.text(tab).last);
    await tester.pumpAndSettle();
    await scrollThrough();
  }

  // Goal details: the FI goal and the custom goal.
  await tester.tap(find.text('Goals').last);
  await tester.pumpAndSettle();
  for (final name in ['Financial independence at 50', "Children's higher education abroad"]) {
    await tester.scrollUntilVisible(find.text(name), 200, scrollable: find.byType(Scrollable).last);
    // Bring it to the top so the floating "Add goal" button cannot cover it.
    await tester.ensureVisible(find.text(name));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
    await scrollThrough();
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  // Settings and every sub-page.
  await tester.tap(find.byTooltip('Settings'));
  await tester.pumpAndSettle();
  await scrollThrough();
  for (final item in ['Edit financial details', 'Retake risk questionnaire', 'About WealthWise AI']) {
    await tester.scrollUntilVisible(find.text(item), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
    await scrollThrough();
    await tester.pageBack();
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('large text (200%) on a small phone', (tester) async {
    await visitAllScreens(tester, size: const Size(360, 740), textScale: 2.0);
  });

  testWidgets('dark mode', (tester) async {
    await visitAllScreens(tester, themeMode: ThemeMode.dark);
  });

  testWidgets('onboarding at 200% text on a small phone', (tester) async {
    await pumpApp(tester, newTestRepository(), size: const Size(360, 740), textScale: 2.0);
    for (var step = 0; step < 4; step++) {
      // Fill what each step needs, then continue.
      if (step == 0) await enterInto(tester, 'Your age', '30');
      if (step == 1) {
        await enterInto(tester, 'Monthly take-home income', '50000');
        await enterInto(tester, 'Monthly expenses', '30000');
      }
      if (step == 3) {
        for (final q in RiskQuestionnaire.questions) {
          await tapVisible(tester, find.text(q.options[1].label));
        }
      }
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Your big goal'), findsOneWidget);
  });
}

/// Scrolls a labelled field into view (needed at large text sizes) and types.
Future<void> enterInto(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.scrollUntilVisible(field, 150, scrollable: find.byType(Scrollable).last);
  await tester.enterText(field, text);
}

/// Scrolls [target] fully into view before tapping, so a half-visible item at
/// the screen edge (common at large text sizes) is not missed.
Future<void> tapVisible(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 150, scrollable: find.byType(Scrollable).last);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pump();
}
