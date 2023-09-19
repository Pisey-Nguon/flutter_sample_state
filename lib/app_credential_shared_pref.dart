import 'package:get_storage/get_storage.dart';

import 'base_service.dart';

class AppCredentialSharedPref {
  static final _box = GetStorage();

  String? get getToken {
    return _box.read(AppConstants.keyToken);
  }

  String? get getRefreshToken {
    return _box.read(AppConstants.keyRefreshToken);
  }

  set token(String token) {
    _box.write(AppConstants.keyToken, token);
  }

  set refreshToken(String refreshToken) {
    _box.write(AppConstants.keyRefreshToken, refreshToken);
  }

  void removeAllCredential() {
    _box.remove(AppConstants.keyToken);
    _box.remove(AppConstants.keyRefreshToken);
  }
}
