import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:wealthwise_ai/app.dart';

void main() {
  testWidgets('sample data onboarding leads to the health dashboard',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    await tester.pumpWidget(const ProviderScope(child: WealthWiseApp()));
    await tester.pumpAndSettle();

    expect(find.text('About you'), findsOneWidget);

    await tester.tap(find.text('Just exploring? Try with sample data'));
    await tester.pumpAndSettle();

    expect(find.text('Financial health score'), findsOneWidget);
    expect(find.text('78'), findsOneWidget); // worked-example score
    expect(find.text('₹15,000'), findsOneWidget); // monthly surplus

    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    expect(find.text('Financial independence at 45'), findsOneWidget);

    await tester.tap(find.text('Financial independence at 45'));
    await tester.pumpAndSettle();
    expect(find.text('Show the math'), findsOneWidget);
  });

  testWidgets('onboarding blocks invalid age', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WealthWiseApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Please enter an age between 18 and 70.'), findsOneWidget);
  });
}
