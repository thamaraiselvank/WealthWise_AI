import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:wealthwise_ai/features/assistant/chat_controller.dart';
import 'package:wealthwise_ai/features/assistant/chat_models.dart';

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
    profile: FinancialProfile.detailed(
      age: 32,
      monthlyIncome: 85000,
      monthlyExpenses: 52000,
      sheet: const BalanceSheet(
        assets: [
          Asset(id: 'a1', type: AssetType.bank, value: 90000),
          Asset(id: 'a2', type: AssetType.fixedDeposit, value: 60000),
          Asset(id: 'a3', type: AssetType.mutualFundsStocks, value: 180000),
          Asset(id: 'a4', type: AssetType.retirement, value: 120000),
          Asset(id: 'a5', type: AssetType.property, value: 2500000),
        ],
        loans: [
          Loan(id: 'l1', type: LoanType.home, outstanding: 850000, emi: 13000, annualRate: 0.0875),
          Loan(id: 'l2', type: LoanType.creditCard, outstanding: 50000, emi: 5000, annualRate: 0.36),
          Loan(id: 'l3', type: LoanType.vehicle, outstanding: 120000, emi: 4000),
        ],
      ),
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
  final api = FakeAssistantApi([
    const ChatReply(isToolCalls: true, asOf: '2026-11-27', toolCalls: [
      ToolCall(id: 'c1', name: 'get_health_report'),
      ToolCall(id: 'c2', name: 'plan_independence', args: {'target_age': 50}),
    ]),
    const ChatReply(
      isToolCalls: false,
      asOf: '2026-11-27',
      text: 'Your health score is fair. The biggest lever is clearing the credit card '
          'first, then building the emergency fund, then raising your SIP every year.',
      sources: [Source('Reserve Bank of India: monetary policy statement', 'https://rbi.org.in/x')],
      disclaimer: 'For education only, not investment advice.',
      remainingQuestions: 99,
    ),
  ]);
  await pumpApp(tester, repo,
      size: size,
      textScale: textScale,
      themeMode: themeMode,
      overrides: [assistantApiProvider.overrideWithValue(api)]);

  Future<void> scrollThrough() async {
    if (pageScrollable().evaluate().isEmpty) return;
    final scrollable = pageScrollable();
    for (var i = 0; i < 12; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    // Back to the top so later lookups start from a known position.
    for (var i = 0; i < 12; i++) {
      await tester.drag(scrollable, const Offset(0, 600));
      await tester.pumpAndSettle();
    }
  }

  for (final tab in ['Health', 'Goals', 'Invest', 'Ask AI', 'Progress']) {
    await tester.tap(find.text(tab).last);
    await tester.pumpAndSettle();
    await scrollThrough();
  }

  // Ask AI: consent, then a tool-backed answer with sources and the math sheet.
  await tester.tap(find.text('Ask AI').last);
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text('I agree, start'));
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text('How am I doing financially?'));
  await tester.pumpAndSettle();
  await scrollThrough();
  await tapVisible(tester, find.text('Show the math: Independence plan'));
  await tester.pumpAndSettle();
  await tester.drag(find.byType(DraggableScrollableSheet), const Offset(0, -500));
  await tester.pumpAndSettle();
  await tester.tapAt(const Offset(10, 10)); // dismiss the sheet
  await tester.pumpAndSettle();

  // Goal details: the FI goal and the custom goal.
  await tester.tap(find.text('Goals').last);
  await tester.pumpAndSettle();
  for (final name in ['Financial independence at 50', "Children's higher education abroad"]) {
    await tester.scrollUntilVisible(find.text(name), 200, scrollable: pageScrollable());
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
  for (final item in [
    'Edit financial details',
    'Retake risk questionnaire',
    'Planning assumptions',
    'About WealthWise AI',
  ]) {
    await tester.scrollUntilVisible(find.text(item), 200, scrollable: pageScrollable());
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
  await tester.scrollUntilVisible(field, 150, scrollable: pageScrollable());
  await tester.enterText(field, text);
}

/// Scrolls [target] fully into view before tapping, so a half-visible item at
/// the screen edge (common at large text sizes) is not missed.
Future<void> tapVisible(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 150, scrollable: pageScrollable());
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pump();
}
