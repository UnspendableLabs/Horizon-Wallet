import 'package:dio/dio.dart';

/// Network error utility for parsing and formatting DioExceptions
class NetworkError extends Error {
  final DioExceptionType type;
  final int? statusCode;
  final String? originalMessage;
  final String userMessage;
  final String? endpoint; // e.g., "GET /api/v2/node_info"
  final String? fullUrl; // full URL if available

  NetworkError({
    required this.type,
    this.statusCode,
    this.originalMessage,
    required this.userMessage,
    this.endpoint,
    this.fullUrl,
  });

  String get message => userMessage;

  /// Extract error message from response data if available
  /// Checks if response data (typically a Map) contains an 'error' field
  static String? _extractErrorFromResponse(dynamic responseData) {
    if (responseData == null) return null;

    // Check if it's a Map with 'error' field
    // Dio typically returns response data as Map<String, dynamic>
    if (responseData is Map) {
      final error = responseData['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }

    return null;
  }

  /// Create NetworkError from DioException
  factory NetworkError.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;

    // Extract error message from response data if available (takes precedence)
    final responseError = _extractErrorFromResponse(error.response?.data);
    final defaultMessage = _formatUserMessage(error.type, statusCode);
    final userMessage = responseError ?? defaultMessage;

    // Extract endpoint information
    final method = error.requestOptions.method;
    final path = error.requestOptions.path;
    final endpoint = '$method $path';
    final fullUrl = error.requestOptions.uri.toString();

    return NetworkError(
      type: error.type,
      statusCode: statusCode,
      originalMessage: error.message,
      userMessage: userMessage,
      endpoint: endpoint,
      fullUrl: fullUrl,
    );
  }

  /// Create NetworkError from any error
  factory NetworkError.fromError(Object error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      return NetworkError.fromDioException(error);
    }
    return NetworkError(
      type: DioExceptionType.unknown,
      originalMessage: error.toString(),
      userMessage: 'An unexpected error occurred: ${error.toString()}',
    );
  }

  /// Convert to String for TaskEither<String, T>
  String toErrorString() => userMessage;

  /// Debug string with detailed error information
  String toDebugString() {
    final parts = <String>[];

    // Add endpoint first (most important for debugging)
    if (endpoint != null) {
      parts.add('endpoint="$endpoint"');
    }

    parts.add('type=${type.name}');

    if (statusCode != null) {
      parts.add('status=$statusCode');
    }

    if (originalMessage != null && originalMessage!.isNotEmpty) {
      final msg = originalMessage!.length > 100
          ? originalMessage!.substring(0, 100) + "..."
          : originalMessage;
      parts.add('message="$msg"');
    }

    return parts.join(', ');
  }

  /// Format user-friendly message based on error type
  static String _formatUserMessage(DioExceptionType type, int? statusCode) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';

      case DioExceptionType.badResponse:
        if (statusCode != null) {
          if (statusCode >= 500) {
            return 'Server error ($statusCode). Please try again later.';
          } else if (statusCode == 401 || statusCode == 403) {
            return 'Authentication failed. Please check your credentials.';
          } else if (statusCode == 404) {
            return 'Resource not found.';
          } else if (statusCode == 429) {
            return 'Too many requests. Please wait a moment and try again.';
          } else if (statusCode >= 400) {
            return 'Request error ($statusCode). Please check your input.';
          }
        }
        return 'Network error. Please try again.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'Connection failed. Please check your internet connection.';

      case DioExceptionType.badCertificate:
        return 'Security certificate error. Cannot establish secure connection.';

      case DioExceptionType.unknown:
        return 'An unknown network error occurred. Please try again.';
    }
  }

  /// Check if error is retryable
  bool get isRetryable {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError ||
        (type == DioExceptionType.badResponse &&
            statusCode != null &&
            statusCode! >= 500);
  }

  /// Check if error is authentication related
  bool get isAuthError {
    return statusCode == 401 || statusCode == 403;
  }

  /// Check if error is rate limiting
  bool get isRateLimitError {
    return statusCode == 429;
  }

  @override
  String toString() => userMessage;
}
