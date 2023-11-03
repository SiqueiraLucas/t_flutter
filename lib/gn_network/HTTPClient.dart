import 'dart:convert' show jsonDecode;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'Serializer.dart';
import 'RequestError.dart';
import 'HTTPRequest.dart';
import 'RequestResult.dart';
import 'HTTPClientInterface.dart';
import 'HTTPMethod.dart';

class HTTPClient implements HTTPClientInterface {
  final Uri _baseURL;
  final Map<String, String> _defaultHeaders;
  Function unauthorizedCallback = () {};

  HTTPClient({
    required Uri baseURL,
    required Map<String, String> defaultHeaders,
  }) : _baseURL = baseURL,
       _defaultHeaders = defaultHeaders;

  @override Future<void> send(HTTPRequest request, RequestResult result) async {
    try {
      final httpResponse = await sendRequest(request);
      final statusCode = httpResponse.statusCode;
      final jsonResponse = jsonDecode(httpResponse.body);
      final isList = jsonResponse is List<dynamic>;

      if (_isError(statusCode)) {
        handleError(jsonResponse, isList, statusCode, request.errorResponseSerializer, result);
      } else {
        handleSuccess(jsonResponse, isList, statusCode, request.responseSerializer, result);
      }
    } catch (error) {
      if (error is SocketException) {
        result.onError(RequestError(reason: RequestErrorReason.connection));
      } else {
        result.onError(RequestError(reason: RequestErrorReason.other));
      }
    } finally {
      result.onComplete();
    }
  }

  Future<http.Response> sendRequest(HTTPRequest request) async {
    final query = (request.queryParams.isNotEmpty ? '?${Uri(queryParameters: request.queryParams).query}' : '');
    final urlString = (request.url ?? _baseURL).toString() + request.path;
    final url = Uri.parse(urlString + query);
    final headers = request.headers.isNotEmpty ? request.headers : _defaultHeaders;
    final body = request.bodyParams;

    switch (request.method) {
      case HTTPMethod.get:
        return await sendGet(url, headers);
      case HTTPMethod.post:
        return await sendPost(url, headers, body);
      case HTTPMethod.put:
        return await sendPut(url, headers, body);
      case HTTPMethod.patch:
        return await sendPatch(url, headers, body);
      case HTTPMethod.delete:
        return await sendDelete(url, headers, body);
      case HTTPMethod.head:
        return await sendHead(url, headers, body);
      default:
        throw Exception("Unsupported HTTP method");
    }
  }

  Future<http.Response> sendGet(Uri url, Map<String, String> headers) async {
    return await http.get(
      url,
      headers: headers,
    );
  }

  Future<http.Response> sendPost(Uri url, Map<String, String> headers, Map<String, dynamic> body) async {
    return await http.post(
      url,
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> sendPut(Uri url, Map<String, String> headers, Map<String, dynamic> body) async {
    return await http.put(
      url,
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> sendPatch(Uri url, Map<String, String> headers, Map<String, dynamic> body) async {
    return await http.patch(
      url,
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> sendDelete(Uri url, Map<String, String> headers, Map<String, dynamic> body) async {
    return await http.delete(
      url,
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> sendHead(Uri url, Map<String, String> headers, Map<String, dynamic> body) async {
    return await http.delete(
      url,
      headers: headers,
      body: body,
    );
  }

  bool _isError(int statusCode) {
    return (statusCode < 200 || statusCode >= 400);
  }

  void handleSuccess(dynamic jsonResponse, bool isList, int statusCode, Serializer? serializer, RequestResult result) {
    if (jsonResponse != null && serializer != null) {
      try {
        final response = !isList
            ? serializer.serialize(jsonResponse)
            : serializer.serializeList(jsonResponse);

        result.onSuccess(response);
      } catch (_) {
        result.onError(RequestError(
            reason: RequestErrorReason.serialize
        ));
      }
    } else {
      result.onSuccess(null);
    }
  }

  void handleError(dynamic jsonResponse, bool isList, int statusCode, Serializer? errorSerializer, RequestResult result) {
    if (statusCode == 401) {
      unauthorizedCallback();
    }

    if (jsonResponse != null && errorSerializer != null) {
      try {
        final errorResponse = !isList
            ? errorSerializer.serialize(jsonResponse)
            : errorSerializer.serializeList(jsonResponse);

        result.onError(RequestError(
            reason: RequestErrorReason.statusCode,
            statusCode: statusCode,
            errorResponse: errorResponse
        ));
      } catch (_) {
        result.onError(RequestError(
          reason: RequestErrorReason.serializeError,
          statusCode: statusCode
        ));
      }
    } else {
      result.onError(RequestError(
          reason: RequestErrorReason.statusCode,
          statusCode: statusCode
      ));
    }
  }

  @override void addHeader(String header, String value) {
    _defaultHeaders[header] = value;
  }

  @override void removeHeader(String header, String value) {
    _defaultHeaders.remove(value);
  }
}