import 'Serializer.dart';
import 'HTTPMethod.dart';

mixin HTTPRequest<T, E> {
  Uri? get url => null;
  String get path => "";
  Map<String, dynamic> get bodyParams => {};
  Map<String, dynamic> get queryParams => {};
  Map<String, String> get headers => {};
  HTTPMethod get method => HTTPMethod.get;
  Serializer<T>? get responseSerializer;
  Serializer<E>? get errorResponseSerializer => null;
}