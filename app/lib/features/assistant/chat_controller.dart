import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_client.dart';
import '../../state/app_state.dart';
import 'chat_models.dart';
import 'profile_summary.dart';
import 'tool_runner.dart';

final assistantApiProvider = Provider<AssistantApi>((ref) => HttpAssistantApi());

@immutable
class ChatState {
  final List<ChatMessage> messages;
  final bool busy;
  final AssistantException? error;
  final ChatMode mode;
  final int? remainingQuestions;

  const ChatState({
    this.messages = const [],
    this.busy = false,
    this.error,
    this.mode = ChatMode.chat,
    this.remainingQuestions,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? busy,
    AssistantException? Function()? error,
    ChatMode? mode,
    int? remainingQuestions,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        busy: busy ?? this.busy,
        error: error != null ? error() : this.error,
        mode: mode ?? this.mode,
        remainingQuestions: remainingQuestions ?? this.remainingQuestions,
      );
}

/// Runs one question end to end: send → (server asks for engine functions →
/// run them here → send results)* → answer.
class ChatController extends Notifier<ChatState> {
  /// Server round trips per question (the backend also caps tool rounds).
  static const maxRoundTrips = 6;

  /// The backend accepts at most 30 messages; send a recent window.
  static const historyWindow = 24;

  @override
  ChatState build() => const ChatState();

  void setMode(ChatMode mode) => state = state.copyWith(mode: mode);

  void newChat() => state = ChatState(mode: state.mode, remainingQuestions: state.remainingQuestions);

  Future<void> send(String text) async {
    final q = text.trim();
    if (q.isEmpty || state.busy) return;
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(role: ChatRole.user, text: q)],
      busy: true,
      error: () => null,
    );
    await _run();
  }

  /// Retries after an error (the user's question is already in the list).
  Future<void> retry() async {
    if (state.busy || state.messages.isEmpty || state.messages.last.role == ChatRole.model) return;
    state = state.copyWith(busy: true, error: () => null);
    await _run();
  }

  Future<void> _run() async {
    final api = ref.read(assistantApiProvider);
    try {
      for (var i = 0; i < maxRoundTrips; i++) {
        final app = ref.read(appStateProvider);
        final reply = await api.chat(
          mode: state.mode,
          profile: buildProfileSummary(app, ref.read(healthReportProvider)),
          messages: _window(state.messages),
        );
        if (!ref.mounted) return;

        if (!reply.isToolCalls) {
          state = state.copyWith(
            messages: [
              ...state.messages,
              ChatMessage(
                role: ChatRole.model,
                text: reply.text,
                sources: reply.sources,
                disclaimer: reply.disclaimer,
                asOf: reply.asOf,
              ),
            ],
            busy: false,
            remainingQuestions: reply.remainingQuestions,
          );
          return;
        }

        final runner = ToolRunner(app);
        state = state.copyWith(messages: [
          ...state.messages,
          ChatMessage(role: ChatRole.model, toolCalls: reply.toolCalls),
          ChatMessage(role: ChatRole.tool, toolResults: [
            for (final c in reply.toolCalls)
              ToolResult(id: c.id, name: c.name, result: runner.run(c.name, c.args)),
          ]),
        ]);
      }
      state = state.copyWith(busy: false, error: () => const AssistantException(AssistantErrorKind.server));
    } on AssistantException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(busy: false, error: () => e);
    }
  }

  /// The most recent messages, starting at a user message so tool calls and
  /// their results are never split.
  static List<ChatMessage> _window(List<ChatMessage> all) {
    if (all.length <= historyWindow) return all;
    var start = all.length - historyWindow;
    while (start < all.length && all[start].role != ChatRole.user) {
      start++;
    }
    return all.sublist(start);
  }
}

final chatProvider = NotifierProvider<ChatController, ChatState>(ChatController.new);
