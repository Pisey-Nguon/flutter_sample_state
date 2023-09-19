class Environments {
  static const String production = 'prod';
  static const String dev = 'dev';
  static const String local = 'local';
}

class BaseApi {
  static const String baseUrl = "baseUrl";
  static const String baseMediaUrl = "baseMediaUrl";
  static const String baseAuthority = "baseAuthority";
}

class ConfigEnvironments {
  static const String _currentEnvironments = Environments.dev;
  static final List<Map<String, String>> _availableEnvironments = [
    {
      'env': Environments.local,
      BaseApi.baseUrl: 'http://localhost:8080/api/',
      BaseApi.baseMediaUrl:
          'https://eec-dev.obs.ap-southeast-3.myhuaweicloud.com/',
      BaseApi.baseAuthority: "94.74.80.84:3005",
    },
    {
      'env': Environments.dev,
      BaseApi.baseUrl: 'http://94.74.81.121:3005/api/client/',
      BaseApi.baseMediaUrl:
          'https://eec-dev.obs.ap-southeast-3.myhuaweicloud.com/',
      BaseApi.baseAuthority: "94.74.81.121:3005",
    },
    {
      'env': Environments.production,
      BaseApi.baseUrl: '',
      BaseApi.baseMediaUrl:
          'https://eec-dev.obs.ap-southeast-3.myhuaweicloud.com/',
      BaseApi.baseAuthority: "94.74.80.84:3005",
    },
  ];

  static Map<String, String> getEnvironments() {
    return _availableEnvironments.firstWhere(
      (d) => d['env'] == _currentEnvironments,
    );
  }
}
