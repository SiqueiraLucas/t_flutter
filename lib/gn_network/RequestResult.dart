import "RequestError.dart";

typedef RequestOnSuccessFunction<T> = void Function(T);
typedef RequestOnErrorFunction<E> = void Function(RequestError<E>);
typedef RequestOnCompleteFunction = void Function();

class RequestResult {
  RequestOnSuccessFunction onSuccess;
  RequestOnErrorFunction onError;
  RequestOnCompleteFunction onComplete;

  RequestResult({
    required this.onSuccess,
    required this.onError,
    required this.onComplete
  });
}