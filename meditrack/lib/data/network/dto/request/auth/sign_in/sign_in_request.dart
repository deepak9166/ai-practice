import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_request.freezed.dart';
part 'sign_in_request.g.dart';

/// Sign In Request Model
///
/// Freezed model representing the request payload for sign-in API.
@freezed
abstract class SignInRequest with _$SignInRequest {
  const factory SignInRequest({
    required String email,
    required String password,
  }) = _SignInRequest;

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
}
