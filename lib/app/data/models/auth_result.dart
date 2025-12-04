
class AuthResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });


  factory AuthResult.success(T data) {
    return AuthResult._(
      isSuccess: true,
      data: data,
    );
  }


  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return isSuccess
        ? 'AuthResult.success(data: $data)'
        : 'AuthResult.failure(error: $errorMessage)';
  }
}
