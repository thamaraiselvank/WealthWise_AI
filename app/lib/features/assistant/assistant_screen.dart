import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../widgets/common.dart';
import 'chat_controller.dart';
import 'chat_models.dart';

const suggestedQuestions = [
  'How am I doing financially?',
  'What should I focus on first?',
  'Can I retire at 50?',
  'What is an index fund?',
  'Should I prepay my loan or invest?',
  'How much emergency fund do I need?',
];

String toolLabel(String name) => switch (name) {
      'get_health_report' => 'Your health score',
      'get_assumptions' => 'Your assumptions',
      'plan_goal' => 'Goal plan',
      'plan_independence' => 'Independence plan',
      'suggest_allocation' => 'Illustrative mix',
      'sip_projection' => 'SIP projection',
      'loan_payoff' => 'Loan payoff',
      _ => 'Calculation',
    };

class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(appStateProvider.select((s) => s.aiConsent));
    return consent ? const _ChatView() : const _ConsentView();
  }
}

class _ConsentView extends ConsumerWidget {
  const _ConsentView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(Icons.chat_bubble_outline, size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text('Ask questions about your money', style: t.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Ask things like "Can I retire at 50?" or "Should I prepay my loan?". '
          'The app calculates the answer on your phone and the AI explains it in plain words.',
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'What is shared, and what is not',
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Sent to the AI: your question and numbers such as age, income, '
                  'expenses, totals of savings and loans, goal amounts and your risk level.'),
              SizedBox(height: 6),
              Text('• Never sent: your name, phone, email, goal names, loan or account labels.'),
              SizedBox(height: 6),
              Text('• Our server does not store your questions or numbers. Answers are '
                  'produced by Google Gemini.'),
              SizedBox(height: 6),
              Text('• Your chat stays on this phone. You can withdraw this permission '
                  'in Settings at any time.'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => ref.read(appStateProvider.notifier).setAiConsent(true),
          child: const Text('I agree, start'),
        ),
        const Disclaimer(),
      ],
    );
  }
}

class _ChatView extends ConsumerStatefulWidget {
  const _ChatView();

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final q = text ?? _input.text;
    if (q.trim().isEmpty) return;
    _input.clear();
    ref.read(chatProvider.notifier).send(q);
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    ref.listen(chatProvider.select((s) => s.messages.length), (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        }
      });
    });

    final items = _bubbles(chat.messages);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<ChatMode>(
                segments: const [
                  ButtonSegment(value: ChatMode.chat, label: Text('My plan'), icon: Icon(Icons.calculate_outlined)),
                  ButtonSegment(value: ChatMode.research, label: Text('Research'), icon: Icon(Icons.travel_explore)),
                ],
                selected: {chat.mode},
                onSelectionChanged: chat.busy ? null : (s) => notifier.setMode(s.first),
              ),
              if (chat.messages.isNotEmpty)
                TextButton.icon(
                  onPressed: chat.busy ? null : notifier.newChat,
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('New chat'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            children: [
              if (items.isEmpty) ...[
                Text(
                  chat.mode == ChatMode.research
                      ? 'Research mode searches the web to explain news, rates and rules, with sources and dates.'
                      : 'Answers use your own numbers. Try one of these:',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final q in suggestedQuestions)
                      ActionChip(label: Text(q), onPressed: chat.busy ? null : () => _send(q)),
                  ],
                ),
              ],
              for (final b in items) _BubbleView(bubble: b),
              if (chat.busy)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(children: [
                    SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Flexible(child: Text('Working it out with your numbers…')),
                  ]),
                ),
              if (chat.error case final e?)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.message),
                        TextButton(onPressed: notifier.retry, child: const Text('Try again')),
                      ],
                    ),
                  ),
                ),
              if (chat.remainingQuestions != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${chat.remainingQuestions} questions left this month',
                      style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 1000,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textInputAction: TextInputAction.send,
                    onSubmitted: chat.busy ? null : (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Ask about your money…',
                      counterText: '',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Send',
                  onPressed: chat.busy ? null : _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A visible message plus the engine results it was built from.
class _Bubble {
  final ChatMessage message;
  final List<ToolResult> usedResults;
  const _Bubble(this.message, this.usedResults);
}

List<_Bubble> _bubbles(List<ChatMessage> messages) {
  final out = <_Bubble>[];
  var pending = <ToolResult>[];
  for (final m in messages) {
    if (m.role == ChatRole.user) pending = [];
    if (m.role == ChatRole.tool) pending = [...pending, ...m.toolResults];
    if (m.isVisible) {
      out.add(_Bubble(m, m.role == ChatRole.model ? pending : const []));
      if (m.role == ChatRole.model) pending = [];
    }
  }
  return out;
}

class _BubbleView extends StatelessWidget {
  final _Bubble bubble;
  const _BubbleView({required this.bubble});

  @override
  Widget build(BuildContext context) {
    final m = bubble.message;
    final isUser = m.role == ChatRole.user;
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.88),
        decoration: BoxDecoration(
          color: isUser ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(m.text!,
                style: TextStyle(color: isUser ? cs.onPrimaryContainer : cs.onSurface)),
            if (bubble.usedResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final r in bubble.usedResults)
                    ActionChip(
                      avatar: const Icon(Icons.functions, size: 18),
                      label: Text('Show the math: ${toolLabel(r.name)}'),
                      onPressed: () => _showMath(context, r),
                    ),
                ],
              ),
            ],
            if (m.sources.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Sources${m.asOf == null ? '' : ' (as of ${m.asOf})'}', style: t.labelMedium),
              for (final s in m.sources)
                Text('• ${s.title}: ${s.url}', style: t.bodySmall),
            ],
            if (m.disclaimer != null) ...[
              const SizedBox(height: 8),
              Text(m.disclaimer!, style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }

  void _showMath(BuildContext context, ToolResult r) {
    final steps = r.result['steps'];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (ctx, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(toolLabel(r.name), style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text('Calculated on your phone by the WealthWise engine.'),
            const SizedBox(height: 12),
            if (steps is List)
              for (final (i, s) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('${i + 1}. $s'),
                )
            else
              for (final e in r.result.entries)
                if (e.value is! List && e.value is! Map)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text('${e.key.replaceAll('_', ' ')}: ${e.value}'),
                  ),
            const Disclaimer(),
          ],
        ),
      ),
    );
  }
}
