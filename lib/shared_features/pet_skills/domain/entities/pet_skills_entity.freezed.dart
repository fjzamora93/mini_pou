// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet_skills_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PetSkillsEntity {

@JsonKey(unknownEnumValue: PetElement.air) PetElement get element;@JsonKey(unknownEnumValue: PetType.elemental) PetType get type; int get level;/// Experience accumulated towards the next level (resets on level-up).
 int get xp;
/// Create a copy of PetSkillsEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PetSkillsEntityCopyWith<PetSkillsEntity> get copyWith => _$PetSkillsEntityCopyWithImpl<PetSkillsEntity>(this as PetSkillsEntity, _$identity);

  /// Serializes this PetSkillsEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PetSkillsEntity&&(identical(other.element, element) || other.element == element)&&(identical(other.type, type) || other.type == type)&&(identical(other.level, level) || other.level == level)&&(identical(other.xp, xp) || other.xp == xp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,element,type,level,xp);

@override
String toString() {
  return 'PetSkillsEntity(element: $element, type: $type, level: $level, xp: $xp)';
}


}

/// @nodoc
abstract mixin class $PetSkillsEntityCopyWith<$Res>  {
  factory $PetSkillsEntityCopyWith(PetSkillsEntity value, $Res Function(PetSkillsEntity) _then) = _$PetSkillsEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: PetElement.air) PetElement element,@JsonKey(unknownEnumValue: PetType.elemental) PetType type, int level, int xp
});




}
/// @nodoc
class _$PetSkillsEntityCopyWithImpl<$Res>
    implements $PetSkillsEntityCopyWith<$Res> {
  _$PetSkillsEntityCopyWithImpl(this._self, this._then);

  final PetSkillsEntity _self;
  final $Res Function(PetSkillsEntity) _then;

/// Create a copy of PetSkillsEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? element = null,Object? type = null,Object? level = null,Object? xp = null,}) {
  return _then(_self.copyWith(
element: null == element ? _self.element : element // ignore: cast_nullable_to_non_nullable
as PetElement,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PetType,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PetSkillsEntity].
extension PetSkillsEntityPatterns on PetSkillsEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PetSkillsEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PetSkillsEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PetSkillsEntity value)  $default,){
final _that = this;
switch (_that) {
case _PetSkillsEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PetSkillsEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PetSkillsEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: PetElement.air)  PetElement element, @JsonKey(unknownEnumValue: PetType.elemental)  PetType type,  int level,  int xp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PetSkillsEntity() when $default != null:
return $default(_that.element,_that.type,_that.level,_that.xp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: PetElement.air)  PetElement element, @JsonKey(unknownEnumValue: PetType.elemental)  PetType type,  int level,  int xp)  $default,) {final _that = this;
switch (_that) {
case _PetSkillsEntity():
return $default(_that.element,_that.type,_that.level,_that.xp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: PetElement.air)  PetElement element, @JsonKey(unknownEnumValue: PetType.elemental)  PetType type,  int level,  int xp)?  $default,) {final _that = this;
switch (_that) {
case _PetSkillsEntity() when $default != null:
return $default(_that.element,_that.type,_that.level,_that.xp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PetSkillsEntity implements PetSkillsEntity {
  const _PetSkillsEntity({@JsonKey(unknownEnumValue: PetElement.air) required this.element, @JsonKey(unknownEnumValue: PetType.elemental) required this.type, this.level = 0, this.xp = 0});
  factory _PetSkillsEntity.fromJson(Map<String, dynamic> json) => _$PetSkillsEntityFromJson(json);

@override@JsonKey(unknownEnumValue: PetElement.air) final  PetElement element;
@override@JsonKey(unknownEnumValue: PetType.elemental) final  PetType type;
@override@JsonKey() final  int level;
/// Experience accumulated towards the next level (resets on level-up).
@override@JsonKey() final  int xp;

/// Create a copy of PetSkillsEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PetSkillsEntityCopyWith<_PetSkillsEntity> get copyWith => __$PetSkillsEntityCopyWithImpl<_PetSkillsEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PetSkillsEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PetSkillsEntity&&(identical(other.element, element) || other.element == element)&&(identical(other.type, type) || other.type == type)&&(identical(other.level, level) || other.level == level)&&(identical(other.xp, xp) || other.xp == xp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,element,type,level,xp);

@override
String toString() {
  return 'PetSkillsEntity(element: $element, type: $type, level: $level, xp: $xp)';
}


}

/// @nodoc
abstract mixin class _$PetSkillsEntityCopyWith<$Res> implements $PetSkillsEntityCopyWith<$Res> {
  factory _$PetSkillsEntityCopyWith(_PetSkillsEntity value, $Res Function(_PetSkillsEntity) _then) = __$PetSkillsEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: PetElement.air) PetElement element,@JsonKey(unknownEnumValue: PetType.elemental) PetType type, int level, int xp
});




}
/// @nodoc
class __$PetSkillsEntityCopyWithImpl<$Res>
    implements _$PetSkillsEntityCopyWith<$Res> {
  __$PetSkillsEntityCopyWithImpl(this._self, this._then);

  final _PetSkillsEntity _self;
  final $Res Function(_PetSkillsEntity) _then;

/// Create a copy of PetSkillsEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? element = null,Object? type = null,Object? level = null,Object? xp = null,}) {
  return _then(_PetSkillsEntity(
element: null == element ? _self.element : element // ignore: cast_nullable_to_non_nullable
as PetElement,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PetType,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
