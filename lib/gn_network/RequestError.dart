class RequestError<E> {
  final RequestErrorReason reason;
  final int? statusCode;
  final E? errorResponse;

  RequestError({
    required this.reason,
    this.statusCode,
    this.errorResponse
  });
}

enum RequestErrorReason {
  statusCode,
  connection,
  serialize,
  serializeError,
  other,
}