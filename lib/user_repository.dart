import 'package:sample_state/api_extension.dart';
import 'package:sample_state/custom_state_view.dart';
import 'package:sample_state/remote_data_source.dart';
import 'package:sample_state/user.dart';

class UserRepository {
  final remote = RemoteDataSource();

  Future<ViewState<List<Datum>>> getUserList({required int page}) async {
    final response = await remote.getUserList(page: page);
    final result = response.toViewState<UserResponse>(UserResponse.fromJson);
    switch (result) {
      case Success():
        if (result.data.data.isNotEmpty) {
          return Success(result.data.data);
        } else {
          return Empty();
        }
      case Failed():
        return Failed();
      case NoInternet():
        return NoInternet();
      case Timeout():
        return Timeout();
      case SomethingWentWrong():
      default:
        return SomethingWentWrong("");
    }
  }
}
