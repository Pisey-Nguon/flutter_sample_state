import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sample_state/base_service.dart';

class RemoteDataSource extends BaseService{
    static final RemoteDataSource _singleton = RemoteDataSource._internal();

  factory RemoteDataSource() {
    return _singleton;
  }
  RemoteDataSource._internal();

    Future<Response<dynamic>> getUserList({required int page}) async{
        final query = {"page": "$page", "per_page": "1"};
    return await methodGet("https://reqres.in/api/users", query: query);
  }
}