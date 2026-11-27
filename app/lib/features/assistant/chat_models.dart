/// Messages exchanged with the backend's /v1/chat (see backend/app/chat/schemas.py).
library;

enum ChatRole { user, model, tool }

class ToolCall {
  final String id;
  final String name;
  final Map<String, Object?> args;

  /// Opaque Gemini thought signature, echoed back unchanged.
  final String? signature;

  const ToolCall({required this.id, required this.name, this.args = const {}, this.signature});

  factory ToolCall.fromJson(Map<String, dynamic> j) => ToolCall(
        id: j['id'] as String,
        name: j['name'] as String,
        args: Map<String, Object?>.from(j['args'] as Map? ?? const {}),
        signature: j['signature'] as String?,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'args': args,
        if (signature != null) 'signature': signature,
      };
}

class ToolResult {
  final String id;
  final String name;
  final Map<String, Object?> result;
  const ToolResult({required this.id, required this.name, required this.result});

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'result': result};
}

class Source {
  final String title;
  final String url;
  const Source(this.title, this.url);
}

class ChatMessage {
  final ChatRole role;
  final String? text;
  final List<ToolCall> toolCalls;
  final List<ToolResult> toolResults;

  // Shown with model answers only (never sent back to the server).
  final List<Source> sources;
  final String? disclaimer;
  final String? asOf;

  const ChatMessage({
    required this.role,
    this.text,
    this.toolCalls = const [],
    this.toolResults = const [],
    this.sources = const [],
    this.disclaimer,
    this.asOf,
  });

  /// True for messages the user sees as bubbles.
  bool get isVisible =>
      (role == ChatRole.user || role == ChatRole.model) && (text?.isNotEmpty ?? false);

  Map<String, Object?> toJson() => {
        'role': role.name,
        if (text != null) 'text': text,
        if (toolCalls.isNotEmpty) 'tool_calls': [for (final c in toolCalls) c.toJson()],
        if (toolResults.isNotEmpty) 'tool_results': [for (final r in toolResults) r.toJson()],
      };
}

/// What the server returned for one request.
class ChatReply {
  final bool isToolCalls;
  final String? text;
  final List<ToolCall> toolCalls;
  final List<Source> sources;
  final String? disclaimer;
  final String asOf;
  final int? remainingQuestions;

  const ChatReply({
    required this.isToolCalls,
    this.text,
    this.toolCalls = const [],
    this.sources = const [],
    this.disclaimer,
    required this.asOf,
    this.remainingQuestions,
  });

  factory ChatReply.fromJson(Map<String, dynamic> j) => ChatReply(
        isToolCalls: j['type'] == 'tool_calls',
        text: j['text'] as String?,
        toolCalls: [
          for (final c in (j['tool_calls'] as List? ?? const []))
            ToolCall.fromJson(Map<String, dynamic>.from(c as Map)),
        ],
        sources: [
          for (final s in (j['sources'] as List? ?? const []))
            Source((s as Map)['title'] as String, s['url'] as String),
        ],
        disclaimer: j['disclaimer'] as String?,
        asOf: j['as_of'] as String? ?? '',
        remainingQuestions: j['remaining_questions'] as int?,
      );
}

enum ChatMode { chat, research }
