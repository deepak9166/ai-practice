// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mmg_level_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MMGLevelResponse _$MMGLevelResponseFromJson(Map<String, dynamic> json) {
  return _MMGLevelResponse.fromJson(json);
}

/// @nodoc
mixin _$MMGLevelResponse {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;

  /// Serializes this MMGLevelResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MMGLevelResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MMGLevelResponseCopyWith<MMGLevelResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MMGLevelResponseCopyWith<$Res> {
  factory $MMGLevelResponseCopyWith(
    MMGLevelResponse value,
    $Res Function(MMGLevelResponse) then,
  ) = _$MMGLevelResponseCopyWithImpl<$Res, MMGLevelResponse>;
  @useResult
  $Res call({String title, String description, String image});
}

/// @nodoc
class _$MMGLevelResponseCopyWithImpl<$Res, $Val extends MMGLevelResponse>
    implements $MMGLevelResponseCopyWith<$Res> {
  _$MMGLevelResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MMGLevelResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? image = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            image: null == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MMGLevelResponseImplCopyWith<$Res>
    implements $MMGLevelResponseCopyWith<$Res> {
  factory _$$MMGLevelResponseImplCopyWith(
    _$MMGLevelResponseImpl value,
    $Res Function(_$MMGLevelResponseImpl) then,
  ) = __$$MMGLevelResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String description, String image});
}

/// @nodoc
class __$$MMGLevelResponseImplCopyWithImpl<$Res>
    extends _$MMGLevelResponseCopyWithImpl<$Res, _$MMGLevelResponseImpl>
    implements _$$MMGLevelResponseImplCopyWith<$Res> {
  __$$MMGLevelResponseImplCopyWithImpl(
    _$MMGLevelResponseImpl _value,
    $Res Function(_$MMGLevelResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MMGLevelResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? image = null,
  }) {
    return _then(
      _$MMGLevelResponseImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        image: null == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MMGLevelResponseImpl implements _MMGLevelResponse {
  const _$MMGLevelResponseImpl({
    required this.title,
    required this.description,
    required this.image,
  });

  factory _$MMGLevelResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MMGLevelResponseImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final String image;

  @override
  String toString() {
    return 'MMGLevelResponse(title: $title, description: $description, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MMGLevelResponseImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, description, image);

  /// Create a copy of MMGLevelResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MMGLevelResponseImplCopyWith<_$MMGLevelResponseImpl> get copyWith =>
      __$$MMGLevelResponseImplCopyWithImpl<_$MMGLevelResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MMGLevelResponseImplToJson(this);
  }
}

abstract class _MMGLevelResponse implements MMGLevelResponse {
  const factory _MMGLevelResponse({
    required final String title,
    required final String description,
    required final String image,
  }) = _$MMGLevelResponseImpl;

  factory _MMGLevelResponse.fromJson(Map<String, dynamic> json) =
      _$MMGLevelResponseImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  String get image;

  /// Create a copy of MMGLevelResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MMGLevelResponseImplCopyWith<_$MMGLevelResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
