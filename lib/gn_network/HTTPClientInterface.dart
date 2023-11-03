import 'HTTPRequest.dart';
import 'RequestResult.dart';

abstract class HTTPClientInterface {
  Future<void> send(HTTPRequest request, RequestResult result);
  void addHeader(String header, String value);
  void removeHeader(String header, String value);
}