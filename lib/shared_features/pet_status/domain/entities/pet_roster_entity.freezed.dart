// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet_roster_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PetRosterEntity {

 List<PetEntity> get pets;/// `null` only before the first adoption.
 String? get activeId;
/// Create a copy of PetRosterEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PetRosterEntityCopyWith<PetRosterEntity> get copyWith => _$PetRosterEntityCopyWithImpl<PetRosterEntity>(this as PetRosterEntity, _$identity);

  /// Serializes this PetRosterEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PetRosterEntity&&const DeepCollectionEquality().equals(other.pets, pets)&&(identical(other.activeId, activeId) || other.activeId == activeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pets),activeId);

@override
String toString() {
  return 'PetRosterEntity(pets: $pets, activeId: $activeId)';
}


}

/// @nodoc
abstract mixin class $PetRosterEntityCopyWith<$Res>  {
  factory $PetRosterEntityCopyWith(PetRosterEntity value, $Res Function(PetRosterEntity) _then) = _$PetRosterEntityCopyWithImpl;
@useResult
$Res call({
 List<PetEntity> pets, String? activeId
});




}
/// @nodoc
class _$PetRosterEntityCopyWithImpl<$Res>
    implements $PetRosterEntityCopyWith<$Res> {
  _$PetRosterEntityCopyWithImpl(this._self, this._then);

  final PetRosterEntity _self;
  final $Res Function(PetRosterEntity) _then;

/// Create a copy of PetRosterEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pets = null,Object? activeId = freezed,}) {
  return _then(_self.copyWith(
pets: null == pets ? _self.pets : pets // ignore: cast_nullable_to_non_nullable
as List<PetEntity>,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PetRosterEntity].
extension PetRosterEntityPatterns on PetRosterEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PetRosterEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PetRosterEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PetRosterEntity value)  $default,){
final _that = this;
switch (_that) {
case _PetRosterEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PetRosterEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PetRosterEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PetEntity> pets,  String? activeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PetRosterEntity() when $default != null:
return $default(_that.pets,_that.activeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PetEntity> pets,  String? activeId)  $default,) {final _that = this;
switch (_that) {
case _PetRosterEntity():
return $default(_that.pets,_that.activeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PetEntity> pets,  String? activeId)?  $default,) {final _that = this;
switch (_that) {
case _PetRosterEntity() when $default != null:
return $default(_that.pets,_that.activeId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PetRosterEntity extends PetRosterEntity {
  const _PetRosterEntity({final  List<PetEntity> pets = const <PetEntity>[], this.activeId}): _pets = pets,super._();
  factory _PetRosterEntity.fromJson(Map<String, dynamic> json) => _$PetRosterEntityFromJson(json);

 final  List<PetEntity> _pets;
@override@JsonKey() List<PetEntity> get pets {
  if (_pets is EqualUnmodifiableListView) return _pets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pets);
}

/// `null` only before the first adoption.
@override final  String? activeId;

/// Create a copy of PetRosterEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PetRosterEntityCopyWith<_PetRosterEntity> get copyWith => __$PetRosterEntityCopyWithImpl<_PetRosterEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PetRosterEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PetRosterEntity&&const DeepCollectionEquality().equals(other._pets, _pets)&&(identical(other.activeId, activeId) || other.activeId == activeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pets),activeId);

@override
String toString() {
  return 'PetRosterEntity(pets: $pets, activeId: $activeId)';
}


}

/// @nodoc
abstract mixin class _$PetRosterEntityCopyWith<$Res> implements $PetRosterEntityCopyWith<$Res> {
  factory _$PetRosterEntityCopyWith(_PetRosterEntity value, $Res Function(_PetRosterEntity) _then) = __$PetRosterEntityCopyWithImpl;
@override @useResult
$Res call({
 List<PetEntity> pets, String? activeId
});




}
/// @nodoc
class __$PetRosterEntityCopyWithImpl<$Res>
    implements _$PetRosterEntityCopyWith<$Res> {
  __$PetRosterEntityCopyWithImpl(this._self, this._then);

  final _PetRosterEntity _self;
  final $Res Function(_PetRosterEntity) _then;

/// Create a copy of PetRosterEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pets = null,Object? activeId = freezed,}) {
  return _then(_PetRosterEntity(
pets: null == pets ? _self._pets : pets // ignore: cast_nullable_to_non_nullable
as List<PetEntity>,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
