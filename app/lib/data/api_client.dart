import 'package:dio/dio.dart';

import '../features/assistant/chat_models.dart';

/// Backend base URL. Debug default reaches a backend on the developer PC from
/// the Android emulator. Release builds pass the Cloud Run URL:
///   `flutter build appbundle --dart-define=WW_API_URL=https://SERVICE.run.app`
const apiBaseUrl =
    String.fromEnvironment('WW_API_URL', defaultValue: 'http://10.0.2.2:8080');

/// Supplies auth headers (Firebase ID token + App Check token once Firebase
/// is set up). Until then no headers are sent and the dev backend accepts it.
typedef AuthHeaders = Future<Map<String, String>> Function();

Future<Map<String, String>> noAuthHeaders() async => const {};

/// Problems the assistant screen explains to the user.
enum AssistantErrorKind { offline, quota, rejected, server }

class AssistantException implements Exception {
  final AssistantErrorKind kind;
  const AssistantException(this.kind);

  String get message => switch (kind) {
        AssistantErrorKind.offline =>
          "Can't reach the assistant. Check your internet connection and try again.",
        AssistantErrorKind.quota =>
          "You've used this month's AI questions. Everything else in the app still works.",
        AssistantErrorKind.rejected =>
          "That message couldn't be sent. Try a shorter question, or start a new chat.",
        AssistantErrorKind.server =>
          'The assistant is having trouble right now. Please try again in a moment.',
      };

  @override
  String toString() => 'AssistantException($kind)';
}

abstract interface class AssistantApi {
  Future<ChatReply> chat({
    required ChatMode mode,
    required Map<String, Object?> profile,
    required List<ChatMessage> messages,
  });
}

class HttpAssistantApi implements AssistantApi {
  HttpAssistantApi({Dio? dio, this.authHeaders = noAuthHeaders, String baseUrl = apiBaseUrl})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 60),
              contentType: Headers.jsonContentType,
            ));

  final Dio _dio;
  final AuthHeaders authHeaders;

  @override
  Future<ChatReply> chat({
    required ChatMode mode,
    required Map<String, Object?> profile,
    required List<ChatMessage> messages,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/v1/chat',
        data: {
          'mode': mode.name,
          'profile': profile,
          'messages': [for (final m in messages) m.toJson()],
        },
        options: Options(headers: await authHeaders()),
      );
      return ChatReply.fromJson(res.data!);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      throw AssistantException(switch (code) {
        null => AssistantErrorKind.offline,
        429 => AssistantErrorKind.quota,
        400 || 401 || 403 || 413 || 422 => AssistantErrorKind.rejected,
        _ => AssistantErrorKind.server,
      });
    }
  }
}
