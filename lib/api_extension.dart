import 'package:get/get_connect/http/src/response/response.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';

import 'custom_state_view.dart';

extension ResponseExtension on Response {
  ViewState<T> toViewState<T>(T Function(Map<String, dynamic>) fromJson) {
    try {
      final status = HttpStatus(statusCode);
      if (status.isOk) {
        return Success<T>(fromJson(body));
      } else if (status.isServerError) {
        return Failed();
      } else if (status.isForbidden) {
        return Failed();
      } else if (status.isNotFound) {
        return Failed();
      } else if (status.isUnauthorized) {
        return Failed();
      } else if (status.connectionError) {
        return NoInternet();
      } else {
        return Failed();
      }
    } on Exception catch (e) {
      print(e);
      return SomethingWentWrong<T>(e);
    }
  }
}
