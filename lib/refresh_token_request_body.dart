class RefreshTokenRequestBody {
  final String refreshToken;

  RefreshTokenRequestBody({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      "refreshToken":refreshToken
    };
  }
}
