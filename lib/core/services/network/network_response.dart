class NetworkResponse {
  final int statusCode;
  final Map<String, dynamic>? responseData;
  final String? errorMessage;
  final bool isSuccess;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.responseData,
    this.errorMessage,
  });

  /// Check if response is successful (2xx status codes)
  bool get isSuccessful => isSuccess && (statusCode >= 200 && statusCode < 300);

  /// Check if response is client error (4xx status codes)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Check if response is server error (5xx status codes)
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  /// Get data as specific type
  T? getData<T>() {
    if (responseData != null) {
      return responseData as T?;
    }
    return null;
  }

  /// Get specific field from response data
  dynamic getField(String key) {
    return responseData?[key];
  }

  /// Get error message or default
  String getErrorMessage({String defaultMsg = 'Something went wrong'}) {
    return errorMessage ?? defaultMsg;
  }

  @override
  String toString() {
    return 'NetworkResponse(isSuccess: $isSuccess, statusCode: $statusCode, errorMessage: $errorMessage)';
  }
}
