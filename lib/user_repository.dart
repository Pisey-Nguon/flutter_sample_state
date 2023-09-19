import 'package:sample_state/api_extension.dart';
import 'package:sample_state/base_service.dart';
import 'package:sample_state/custom_state_view.dart';
import 'package:sample_state/user.dart';

class UserRepository extends BaseService {
  Future<ViewState<UserResponse>> getUser() async {
    final response = await methodGet("https://reqres.in/api/users");
    return response.toViewState<UserResponse>(UserResponse.fromJson);
  }
}
