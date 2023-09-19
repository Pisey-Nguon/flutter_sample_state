import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get_connect/connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:sample_state/refresh_token_request_body.dart';

import 'api_helper.dart';
import 'app_credential_shared_pref.dart';
import 'config.dart';
import 'login_response.dart';

class BaseService extends GetConnect {
  final _box = GetStorage();
  final _logger = Logger();
  String? _token;

  @override
  void onInit() {
    // add your local storage here to load for every request
    _token = _box.read(AppConstants.keyToken);

    httpClient.baseUrl = ConfigEnvironments.getEnvironments()[BaseApi.baseUrl];
    httpClient.defaultContentType = "application/json";
    httpClient.timeout = const Duration(seconds: 8);

    httpClient.addResponseModifier((request, response) async {
      if (kDebugMode) {
        _logger.i(
            "Url service:\n${request.url}\nHeader: ${request.headers}\nResponse: \n${_getPrettyJSONString(response.body)}");
      }
      return response;
    });

    super.onInit();
  }

  String _getPrettyJSONString(jsonObject) {
    var encoder = const JsonEncoder.withIndent(" ");
    return encoder.convert(jsonObject);
  }

  void printQuery(Map<String, dynamic> query) {
    if (kDebugMode) _logger.i("Query Param\n${_getPrettyJSONString(query)}");
  }

  void printBody(Map<String, dynamic> body) {
    if (kDebugMode) _logger.i("Body Param\n${_getPrettyJSONString(body)}");
  }

  void printErrorService(String e) {
    if (kDebugMode) _logger.i("Error Service \n$e");
  }

  void printErrorRequest({required dynamic e, required dynamic stack}) {
    if (kDebugMode) _logger.e("Error Service \n$e \n$stack");
  }

  Future<Response<dynamic>> _requestRefreshToken() async {
    final refreshToken = AppCredentialSharedPref().getRefreshToken;
    final refreshTokenBody =
        RefreshTokenRequestBody(refreshToken: refreshToken!);
    return await post("auth/refresh-token", refreshTokenBody.toJson());
  }

  Map<String, String> _getAuthorization() {
    if (_token != null) {
      return {"Authorization": "Bearer $_token"};
    } else {
      var token = _box.read(AppConstants.keyToken);
      if (token != null) {
        return {"Authorization": "Bearer $token"};
      } else {
        return {};
      }
    }
  }

  Future<Response<dynamic>> methodGet(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<dynamic>? decoder,
  }) async {
    var currentHeaders = <String, String>{};
    if (headers != null) {
      currentHeaders = headers;
    } else {
      currentHeaders = _getAuthorization();
    }
    var response = await get(
      url,
      headers: currentHeaders,
      contentType: contentType,
      query: query,
      decoder: decoder,
    );
    if (response.unauthorized) {
      var newTokenResponse = await _requestRefreshToken();
      var requestStatus = ApiHelper.errorHandler(apiResponse: newTokenResponse);
      if (requestStatus == RequestStatus.success) {
        final successResponse = LoginResponse.fromJson(newTokenResponse.body);
        _box.write(AppConstants.keyToken, successResponse.token);
        _box.write(AppConstants.keyRefreshToken, successResponse.token);
        _token = successResponse.token;
        final newHeaders = {"Authorization": "Bearer $_token"};
        methodGet(url,
            headers: newHeaders,
            contentType: contentType,
            query: query,
            decoder: decoder);
      } else {
        return newTokenResponse;
      }
      return response;
    } else {
      return response;
    }
  }

  Future<Response<dynamic>> methodPost(
    String? url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<dynamic>? decoder,
    Progress? uploadProgress,
  }) async {
    if (kDebugMode) _logger.i("Body Param\n${_getPrettyJSONString(body)}");
    var currentHeaders = <String, String>{};
    if (headers != null) {
      currentHeaders = headers;
    } else {
      currentHeaders = _getAuthorization();
    }
    var response = await post(
      url,
      body,
      contentType: contentType,
      headers: currentHeaders,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
    if (response.unauthorized) {
      var newTokenResponse = await _requestRefreshToken();
      var requestStatus = ApiHelper.errorHandler(apiResponse: newTokenResponse);
      if (requestStatus == RequestStatus.success) {
        final successResponse = LoginResponse.fromJson(newTokenResponse.body);
        _box.write(AppConstants.keyToken, successResponse.token);
        _box.write(AppConstants.keyRefreshToken, successResponse.token);
        _token = successResponse.token;
        final newHeaders = {"Authorization": "Bearer $_token"};
        methodPost(url, body,
            contentType: contentType,
            headers: newHeaders,
            query: query,
            decoder: decoder,
            uploadProgress: uploadProgress);
      } else {
        return newTokenResponse;
      }
      return response;
    } else {
      return response;
    }
  }

  Future<Response<dynamic>> methodPut(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<dynamic>? decoder,
    Progress? uploadProgress,
  }) async {
    var currentHeaders = <String, String>{};
    if (headers != null) {
      currentHeaders = headers;
    } else {
      currentHeaders = _getAuthorization();
    }
    var response = await put(url, body,
        contentType: contentType,
        headers: currentHeaders,
        query: query,
        decoder: decoder,
        uploadProgress: uploadProgress,);
    if (response.unauthorized) {
      var newTokenResponse = await _requestRefreshToken();
      var requestStatus = ApiHelper.errorHandler(apiResponse: newTokenResponse);
      if (requestStatus == RequestStatus.success) {
        final successResponse = LoginResponse.fromJson(newTokenResponse.body);
        _box.write(AppConstants.keyToken, successResponse.token);
        _box.write(AppConstants.keyRefreshToken, successResponse.token);
        _token = successResponse.token;
        final newHeaders = {"Authorization": "Bearer $_token"};
        methodPut(url, body,
            contentType: contentType,
            headers: newHeaders,
            query: query,
            decoder: decoder,
            uploadProgress: uploadProgress);
      } else {
        return newTokenResponse;
      }
      return response;
    } else {
      return response;
    }
  }

  Future<Response<dynamic>> methodDelete(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<dynamic>? decoder,
  }) async {
    var currentHeaders = <String, String>{};
    if (headers != null) {
      currentHeaders = headers;
    } else {
      currentHeaders = _getAuthorization();
    }
    var response = await delete(url,
        headers: currentHeaders,
        contentType: contentType,
        query: query,
        decoder: decoder);
    if (response.unauthorized) {
      var newTokenResponse = await _requestRefreshToken();
      var requestStatus = ApiHelper.errorHandler(apiResponse: newTokenResponse);
      if (requestStatus == RequestStatus.success) {
        final successResponse = LoginResponse.fromJson(newTokenResponse.body);
        _box.write(AppConstants.keyToken, successResponse.token);
        _box.write(AppConstants.keyRefreshToken, successResponse.token);
        _token = successResponse.token;
        final newHeaders = {"Authorization": "Bearer $_token"};
        methodDelete(url,
            headers: newHeaders,
            contentType: contentType,
            query: query,
            decoder: decoder);
      } else {
        return newTokenResponse;
      }
      return response;
    } else {
      return response;
    }
  }
}

class AppConstants {
  static const keyToken = "keyToken";
  static const keyRefreshToken = "keyRefreshToken";
}

enum RequestStatus { success, failed, noInternet }
