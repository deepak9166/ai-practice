import 'package:freezed_annotation/freezed_annotation.dart';
import '../sign_in/sign_in_response.dart';

part 'sign_up_response.freezed.dart';
part 'sign_up_response.g.dart';

/// Sign Up Response Model
///
/// Freezed model representing the response from sign-up API.
@freezed
abstract class SignUpResponse with _$SignUpResponse {
  const factory SignUpResponse({
    required String token,
    required String refreshToken,
    required UserData user,
  }) = _SignUpResponse;

  factory SignUpResponse.fromJson(Map<String, dynamic> json) =>
      _$SignUpResponseFromJson(json);
}
