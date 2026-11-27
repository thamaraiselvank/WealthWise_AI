import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

void main() {
  testWidgets('sample onboarding shows the dashboard and is saved', (tester) async {
    final repo = newTestRepository();
    await pumpApp(tester, repo);

    expect(find.text('About you'), findsOneWidget);
    await onboardWithSample(tester);

    expect(find.text('Financial health score'), findsOneWidget);
    expect(find.text('78'), findsOneWidget); // worked-example score
    expect(find.text('₹15,000'), findsOneWidget); // monthly surplus

    final saved = await repo.load();
    expect(saved.isOnboarded, isTrue);
    expect(saved.profile!.monthlyIncome, 40000);
    expect(saved.fiTargetAge, 45);
  });

  testWidgets('restarting the app skips onboarding', (tester) async {
    final repo = newTestRepository();
    await pumpApp(tester, repo);
    await onboardWithSample(tester);

    // Simulate an app restart with the same database.
    await pumpApp(tester, repo);
    expect(find.text('About you'), findsNothing);
    expect(find.text('Financial health score'), findsOneWidget);
  });

  testWidgets('goal detail shows the math', (tester) async {
    await pumpApp(tester, newTestRepository());
    await onboardWithSample(tester);

    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Financial independence at 45'));
    await tester.pumpAndSettle();
    expect(find.text('Show the math'), findsOneWidget);
  });

  testWidgets('editing assumptions changes plans and persists', (tester) async {
    final repo = newTestRepository();
    await pumpApp(tester, repo);
    await onboardWithSample(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Planning assumptions'));
    await tester.pumpAndSettle();
    expect(find.textContaining('corpus ₹2.4'), findsOneWidget);

    // Drag the inflation slider (the first one) all the way right: 10%.
    await tester.drag(find.byType(Slider).first, const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(find.text('10.0%'), findsWidgets);
    expect(find.textContaining('corpus ₹2.4'), findsNothing);
    expect((await repo.load()).assumptions.inflation, 0.10);

    await tester.tap(find.text('Reset all'));
    await tester.pumpAndSettle();
    expect(find.textContaining('corpus ₹2.4'), findsOneWidget);
    expect((await repo.load()).assumptions.isStandard, isTrue);
  });

  testWidgets('add, edit and delete a goal', (tester) async {
    final repo = newTestRepository();
    await pumpApp(tester, repo);
    await onboardWithSample(tester);
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();

    // Add
    await tester.tap(find.text('Add goal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, "Cost in today's money"), '1500000');
    await tester.enterText(find.widgetWithText(TextFormField, 'In how many years?'), '8');
    await tester.tap(find.widgetWithText(FilledButton, 'Add goal'));
    await tester.pumpAndSettle();
    expect(find.text('Buy a house'), findsOneWidget);
    expect((await repo.load()).goals.single.todayCost, 1500000);

    // Edit
    await tester.tap(find.text('Buy a house'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit goal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Goal name'), 'Dream home');
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Dream home'), findsWidgets);
    expect((await repo.load()).goals.single.name, 'Dream home');

    // Delete (with confirmation)
    await tester.tap(find.byTooltip('Delete goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Dream home'), findsNothing);
    expect((await repo.load()).goals, isEmpty);
  });

  testWidgets('editing the profile updates the health score', (tester) async {
    final repo = newTestRepository();
    await pumpApp(tester, repo);
    await onboardWithSample(tester);
    expect(find.text('78'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit financial details'));
    await tester.pumpAndSettle();

    // Turn on health insurance: +10 points.
    await tester.tap(find.text('I have health insurance'));
    await tester.scrollUntilVisible(find.text('Save changes'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('88'), findsOneWidget);
    expect((await repo.load()).profile!.hasHealthInsurance, isTrue);
  });

  testWidgets('retaking the risk quiz changes the profile', (tester) async {
    final repo = newTestRepository();
    await pumpApp(tester, repo);
    await onboardWithSample(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Currently Moderate'), findsOneWidget);
    await tester.tap(find.text('Retake risk questionnaire'));
    await tester.pumpAndSettle();

    for (final option in [
      'Invest more while prices are low',
      'Maximum long-term growth',
      'Several years in equity markets',
      'Very stable with growth',
      'After 7+ years',
      '-25% to +35%',
    ]) {
      await tester.scrollUntilVisible(find.text(option), 100,
          scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text(option));
      await tester.pump();
    }
    await tester.scrollUntilVisible(find.widgetWithText(FilledButton, 'Save'), 100,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Currently Aggressive'), findsOneWidget);
    expect((await repo.load()).riskAnswers['drop'], 2);
  });

  testWidgets('delete all data returns to onboarding and wipes storage', (tester) async {
    final repo = newTestRepository();
    await pumpApp(tester, repo);
    await onboardWithSample(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete all my data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete everything'));
    await tester.pumpAndSettle();

    expect(find.text('About you'), findsOneWidget);
    expect((await repo.load()).isOnboarded, isFalse);
  });

  testWidgets('expense breakdown sets expenses and shows insights', (tester) async {
    final repo = newTestRepository();
    await pumpApp(tester, repo);
    await onboardWithSample(tester);
    expect(find.text('Add expense breakdown'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit financial details'));
    await tester.pumpAndSettle();

    final top = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(find.text('Split my expenses by category'), 200, scrollable: top);
    await tester.tap(find.text('Split my expenses by category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Rent / housing'), '15000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Food & groceries'), '6000');
    await tester.scrollUntilVisible(find.widgetWithText(TextFormField, 'Shopping, eating out, fun'), 200,
        scrollable: top);
    await tester.enterText(find.widgetWithText(TextFormField, 'Shopping, eating out, fun'), '4000');
    await tester.pump();
    expect(find.text('Total monthly expenses: ₹25,000'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Save changes'), 200, scrollable: top);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    final saved = (await repo.load()).profile!;
    expect(saved.monthlyExpenses, 25000);
    expect(saved.expenseBreakdown!.total, 25000);

    await tester.scrollUntilVisible(find.text('Where your money goes'), 300,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Housing is 38% of income'), findsOneWidget);
  });

  testWidgets('onboarding blocks invalid age', (tester) async {
    await pumpApp(tester, newTestRepository());
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Please enter an age between 18 and 70.'), findsOneWidget);
  });
}
