import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wealthwise_ai/data/api_client.dart';
import 'package:wealthwise_ai/features/assistant/chat_controller.dart';
import 'package:wealthwise_ai/features/assistant/chat_models.dart';

import '../helpers.dart';

Future<void> openAskAi(WidgetTester tester) async {
  await tester.tap(find.text('Ask AI').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('consent is required, remembered, and can be withdrawn', (tester) async {
    final repo = newTestRepository();
    final api = FakeAssistantApi([]);
    await pumpApp(tester, repo, overrides: [assistantApiProvider.overrideWithValue(api)]);
    await onboardWithSample(tester);
    await openAskAi(tester);

    expect(find.text('What is shared, and what is not'), findsOneWidget);
    await tapVisible(tester, find.text('I agree, start'));
    await tester.pumpAndSettle();
    expect(find.text('How am I doing financially?'), findsOneWidget);
    expect((await repo.load()).aiConsent, isTrue);
    expect(api.requests, isEmpty); // nothing sent before a question

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI assistant'));
    await tester.pumpAndSettle();
    expect((await repo.load()).aiConsent, isFalse);
  });

  testWidgets('question -> engine tool call on the phone -> explained answer', (tester) async {
    final api = FakeAssistantApi([
      const ChatReply(isToolCalls: true, asOf: '2026-11-27', toolCalls: [
        ToolCall(id: 'c1', name: 'plan_independence', args: {'target_age': 50}, signature: 'c2ln'),
      ]),
      const ChatReply(
        isToolCalls: false,
        asOf: '2026-11-27',
        text: 'Retiring at 50 needs a bigger SIP than your surplus allows today.',
        disclaimer: 'For education only, not investment advice.',
        remainingQuestions: 4,
      ),
    ]);
    final repo = newTestRepository();
    await pumpApp(tester, repo, overrides: [assistantApiProvider.overrideWithValue(api)]);
    await onboardWithSample(tester);
    await openAskAi(tester);
    await tapVisible(tester, find.text('I agree, start'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Can I retire at 50?'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Retiring at 50 needs'), findsOneWidget);
    expect(find.text('4 questions left this month'), findsOneWidget);

    // Second request carried the engine result and echoed the signature.
    expect(api.requests, hasLength(2));
    final sent = api.requests[1].messages;
    expect(sent.map((m) => m.role), [ChatRole.user, ChatRole.model, ChatRole.tool]);
    expect(sent[1].toolCalls.single.signature, 'c2ln');
    final result = sent[2].toolResults.single.result;
    expect(result['monthly_sip_flat'], isA<int>());
    expect(result.containsKey('error'), isFalse);
    // Profile is numbers only.
    expect(api.requests.first.profile['monthly_income'], 40000);
    expect(api.requests.first.profile.containsKey('name'), isFalse);

    // "Show the math" opens the engine's steps.
    await tester.tap(find.text('Show the math: Independence plan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Corpus needed = yearly expenses'), findsOneWidget);
  });

  testWidgets('offline error shows a message and retry works', (tester) async {
    final api = FakeAssistantApi([
      const AssistantException(AssistantErrorKind.offline),
      const ChatReply(isToolCalls: false, asOf: '2026-11-27', text: 'An index fund tracks a market index.'),
    ]);
    await pumpApp(tester, newTestRepository(),
        overrides: [assistantApiProvider.overrideWithValue(api)]);
    await onboardWithSample(tester);
    await openAskAi(tester);
    await tapVisible(tester, find.text('I agree, start'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'What is an index fund?');
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Can't reach the assistant"), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('An index fund tracks a market index.'), findsOneWidget);
    expect(find.textContaining("Can't reach"), findsNothing);
    // The retried request resent the same single user question.
    expect(api.requests[1].messages.single.text, 'What is an index fund?');
  });
}

Future<void> tapVisible(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 150, scrollable: pageScrollable());
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
}
