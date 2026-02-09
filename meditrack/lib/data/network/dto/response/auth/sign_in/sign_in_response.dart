import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_response.freezed.dart';
part 'sign_in_response.g.dart';

/// Sign In Response Model
///
/// Freezed model representing the response from sign-in API.
@freezed
abstract class SignInResponse with _$SignInResponse {
  const factory SignInResponse({
    required String token,
    required String refreshToken,
    required UserData user,
  }) = _SignInResponse;

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}

/// User Data Model
@freezed
abstract class UserData with _$UserData {
  const factory UserData({
    required String id,
    required String name,
    required String email,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
