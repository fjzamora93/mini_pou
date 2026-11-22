// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PetEntity {

 String get id; String get name;@JsonKey(unknownEnumValue: PetSpecies.fallback) PetSpecies get species; PetStatusEntity get status; PetSkillsEntity get skills;
/// Create a copy of PetEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PetEntityCopyWith<PetEntity> get copyWith => _$PetEntityCopyWithImpl<PetEntity>(this as PetEntity, _$identity);

  /// Serializes this PetEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PetEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.status, status) || other.status == status)&&(identical(other.skills, skills) || other.skills == skills));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,species,status,skills);

@override
String toString() {
  return 'PetEntity(id: $id, name: $name, species: $species, status: $status, skills: $skills)';
}


}

/// @nodoc
abstract mixin class $PetEntityCopyWith<$Res>  {
  factory $PetEntityCopyWith(PetEntity value, $Res Function(PetEntity) _then) = _$PetEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: PetSpecies.fallback) PetSpecies species, PetStatusEntity status, PetSkillsEntity skills
});


$PetStatusEntityCopyWith<$Res> get status;$PetSkillsEntityCopyWith<$Res> get skills;

}
/// @nodoc
class _$PetEntityCopyWithImpl<$Res>
    implements $PetEntityCopyWith<$Res> {
  _$PetEntityCopyWithImpl(this._self, this._then);

  final PetEntity _self;
  final $Res Function(PetEntity) _then;

/// Create a copy of PetEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? species = null,Object? status = null,Object? skills = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PetStatusEntity,skills: null == skills ? _self.skills : skills // ignore: cast_nullable_to_non_nullable
as PetSkillsEntity,
  ));
}
/// Create a copy of PetEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PetStatusEntityCopyWith<$Res> get status {
  
  return $PetStatusEntityCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of PetEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PetSkillsEntityCopyWith<$Res> get skills {
  
  return $PetSkillsEntityCopyWith<$Res>(_self.skills, (value) {
    return _then(_self.copyWith(skills: value));
  });
}
}


/// Adds pattern-matching-related methods to [PetEntity].
extension PetEntityPatterns on PetEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PetEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PetEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PetEntity value)  $default,){
final _that = this;
switch (_that) {
case _PetEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PetEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PetEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: PetSpecies.fallback)  PetSpecies species,  PetStatusEntity status,  PetSkillsEntity skills)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PetEntity() when $default != null:
return $default(_that.id,_that.name,_that.species,_that.status,_that.skills);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: PetSpecies.fallback)  PetSpecies species,  PetStatusEntity status,  PetSkillsEntity skills)  $default,) {final _that = this;
switch (_that) {
case _PetEntity():
return $default(_that.id,_that.name,_that.species,_that.status,_that.skills);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(unknownEnumValue: PetSpecies.fallback)  PetSpecies species,  PetStatusEntity status,  PetSkillsEntity skills)?  $default,) {final _that = this;
switch (_that) {
case _PetEntity() when $default != null:
return $default(_that.id,_that.name,_that.species,_that.status,_that.skills);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PetEntity implements PetEntity {
  const _PetEntity({required this.id, required this.name, @JsonKey(unknownEnumValue: PetSpecies.fallback) required this.species, required this.status, required this.skills});
  factory _PetEntity.fromJson(Map<String, dynamic> json) => _$PetEntityFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(unknownEnumValue: PetSpecies.fallback) final  PetSpecies species;
@override final  PetStatusEntity status;
@override final  PetSkillsEntity skills;

/// Create a copy of PetEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PetEntityCopyWith<_PetEntity> get copyWith => __$PetEntityCopyWithImpl<_PetEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PetEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PetEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.status, status) || other.status == status)&&(identical(other.skills, skills) || other.skills == skills));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,species,status,skills);

@override
String toString() {
  return 'PetEntity(id: $id, name: $name, species: $species, status: $status, skills: $skills)';
}


}

/// @nodoc
abstract mixin class _$PetEntityCopyWith<$Res> implements $PetEntityCopyWith<$Res> {
  factory _$PetEntityCopyWith(_PetEntity value, $Res Function(_PetEntity) _then) = __$PetEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: PetSpecies.fallback) PetSpecies species, PetStatusEntity status, PetSkillsEntity skills
});


@override $PetStatusEntityCopyWith<$Res> get status;@override $PetSkillsEntityCopyWith<$Res> get skills;

}
/// @nodoc
class __$PetEntityCopyWithImpl<$Res>
    implements _$PetEntityCopyWith<$Res> {
  __$PetEntityCopyWithImpl(this._self, this._then);

  final _PetEntity _self;
  final $Res Function(_PetEntity) _then;

/// Create a copy of PetEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? species = null,Object? status = null,Object? skills = null,}) {
  return _then(_PetEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PetStatusEntity,skills: null == skills ? _self.skills : skills // ignore: cast_nullable_to_non_nullable
as PetSkillsEntity,
  ));
}

/// Create a copy of PetEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PetStatusEntityCopyWith<$Res> get status {
  
  return $PetStatusEntityCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of PetEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PetSkillsEntityCopyWith<$Res> get skills {
  
  return $PetSkillsEntityCopyWith<$Res>(_self.skills, (value) {
    return _then(_self.copyWith(skills: value));
  });
}
}

// dart format on
