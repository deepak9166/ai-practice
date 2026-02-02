import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_request.freezed.dart';
part 'sign_up_request.g.dart';

/// Sign Up Request Model
///
/// Freezed model representing the request payload for sign-up API.
@freezed
abstract class SignUpRequest with _$SignUpRequest {
  const factory SignUpRequest({
    required String name,
    required String phoneNumber,
    required String email,
    required String password,
  }) = _SignUpRequest;

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);
}
