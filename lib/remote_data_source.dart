import 'package:sample_state/base_service.dart';

class RemoteDataSource extends BaseService{
    static final RemoteDataSource _singleton = RemoteDataSource._internal();

  factory RemoteDataSource() {
    return _singleton;
  }
  RemoteDataSource._internal();

  
}