import 'package:freezed_annotation/freezed_annotation.dart';

part 'mmg_level_response.freezed.dart';
part 'mmg_level_response.g.dart';

/// Sign In Response Model
///
/// Freezed model representing the response from sign-in API.
@freezed
abstract class MMGLevelResponse with _$MMGLevelResponse {
  const factory MMGLevelResponse({
    required String title,
    required String description,
    required String image,
  }) = _MMGLevelResponse;

  factory MMGLevelResponse.fromJson(Map<String, dynamic> json) =>
      _$MMGLevelResponseFromJson(json);
}
