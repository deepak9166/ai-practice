// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mmg_level_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MMGLevelResponse {

 String get title; String get description; String get image;
/// Create a copy of MMGLevelResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MMGLevelResponseCopyWith<MMGLevelResponse> get copyWith => _$MMGLevelResponseCopyWithImpl<MMGLevelResponse>(this as MMGLevelResponse, _$identity);

  /// Serializes this MMGLevelResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MMGLevelResponse&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,image);

@override
String toString() {
  return 'MMGLevelResponse(title: $title, description: $description, image: $image)';
}


}

/// @nodoc
abstract mixin class $MMGLevelResponseCopyWith<$Res>  {
  factory $MMGLevelResponseCopyWith(MMGLevelResponse value, $Res Function(MMGLevelResponse) _then) = _$MMGLevelResponseCopyWithImpl;
@useResult
$Res call({
 String title, String description, String image
});




}
/// @nodoc
class _$MMGLevelResponseCopyWithImpl<$Res>
    implements $MMGLevelResponseCopyWith<$Res> {
  _$MMGLevelResponseCopyWithImpl(this._self, this._then);

  final MMGLevelResponse _self;
  final $Res Function(MMGLevelResponse) _then;

/// Create a copy of MMGLevelResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? image = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MMGLevelResponse].
extension MMGLevelResponsePatterns on MMGLevelResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MMGLevelResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MMGLevelResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MMGLevelResponse value)  $default,){
final _that = this;
switch (_that) {
case _MMGLevelResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MMGLevelResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MMGLevelResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  String image)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MMGLevelResponse() when $default != null:
return $default(_that.title,_that.description,_that.image);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  String image)  $default,) {final _that = this;
switch (_that) {
case _MMGLevelResponse():
return $default(_that.title,_that.description,_that.image);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  String image)?  $default,) {final _that = this;
switch (_that) {
case _MMGLevelResponse() when $default != null:
return $default(_that.title,_that.description,_that.image);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MMGLevelResponse implements MMGLevelResponse {
  const _MMGLevelResponse({required this.title, required this.description, required this.image});
  factory _MMGLevelResponse.fromJson(Map<String, dynamic> json) => _$MMGLevelResponseFromJson(json);

@override final  String title;
@override final  String description;
@override final  String image;

/// Create a copy of MMGLevelResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MMGLevelResponseCopyWith<_MMGLevelResponse> get copyWith => __$MMGLevelResponseCopyWithImpl<_MMGLevelResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MMGLevelResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MMGLevelResponse&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,image);

@override
String toString() {
  return 'MMGLevelResponse(title: $title, description: $description, image: $image)';
}


}

/// @nodoc
abstract mixin class _$MMGLevelResponseCopyWith<$Res> implements $MMGLevelResponseCopyWith<$Res> {
  factory _$MMGLevelResponseCopyWith(_MMGLevelResponse value, $Res Function(_MMGLevelResponse) _then) = __$MMGLevelResponseCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String image
});




}
/// @nodoc
class __$MMGLevelResponseCopyWithImpl<$Res>
    implements _$MMGLevelResponseCopyWith<$Res> {
  __$MMGLevelResponseCopyWithImpl(this._self, this._then);

  final _MMGLevelResponse _self;
  final $Res Function(_MMGLevelResponse) _then;

/// Create a copy of MMGLevelResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? image = null,}) {
  return _then(_MMGLevelResponse(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
