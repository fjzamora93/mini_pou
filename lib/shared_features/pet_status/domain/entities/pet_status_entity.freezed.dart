// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet_status_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PetStatusEntity {

 double get satiety; double get energy; double get happiness; double get hygiene; bool get isSleeping;@UtcEpochMillisConverter() DateTime get lastUpdatedAt;
/// Create a copy of PetStatusEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PetStatusEntityCopyWith<PetStatusEntity> get copyWith => _$PetStatusEntityCopyWithImpl<PetStatusEntity>(this as PetStatusEntity, _$identity);

  /// Serializes this PetStatusEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PetStatusEntity&&(identical(other.satiety, satiety) || other.satiety == satiety)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.happiness, happiness) || other.happiness == happiness)&&(identical(other.hygiene, hygiene) || other.hygiene == hygiene)&&(identical(other.isSleeping, isSleeping) || other.isSleeping == isSleeping)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,satiety,energy,happiness,hygiene,isSleeping,lastUpdatedAt);

@override
String toString() {
  return 'PetStatusEntity(satiety: $satiety, energy: $energy, happiness: $happiness, hygiene: $hygiene, isSleeping: $isSleeping, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $PetStatusEntityCopyWith<$Res>  {
  factory $PetStatusEntityCopyWith(PetStatusEntity value, $Res Function(PetStatusEntity) _then) = _$PetStatusEntityCopyWithImpl;
@useResult
$Res call({
 double satiety, double energy, double happiness, double hygiene, bool isSleeping,@UtcEpochMillisConverter() DateTime lastUpdatedAt
});




}
/// @nodoc
class _$PetStatusEntityCopyWithImpl<$Res>
    implements $PetStatusEntityCopyWith<$Res> {
  _$PetStatusEntityCopyWithImpl(this._self, this._then);

  final PetStatusEntity _self;
  final $Res Function(PetStatusEntity) _then;

/// Create a copy of PetStatusEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? satiety = null,Object? energy = null,Object? happiness = null,Object? hygiene = null,Object? isSleeping = null,Object? lastUpdatedAt = null,}) {
  return _then(_self.copyWith(
satiety: null == satiety ? _self.satiety : satiety // ignore: cast_nullable_to_non_nullable
as double,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as double,happiness: null == happiness ? _self.happiness : happiness // ignore: cast_nullable_to_non_nullable
as double,hygiene: null == hygiene ? _self.hygiene : hygiene // ignore: cast_nullable_to_non_nullable
as double,isSleeping: null == isSleeping ? _self.isSleeping : isSleeping // ignore: cast_nullable_to_non_nullable
as bool,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PetStatusEntity].
extension PetStatusEntityPatterns on PetStatusEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PetStatusEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PetStatusEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PetStatusEntity value)  $default,){
final _that = this;
switch (_that) {
case _PetStatusEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PetStatusEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PetStatusEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double satiety,  double energy,  double happiness,  double hygiene,  bool isSleeping, @UtcEpochMillisConverter()  DateTime lastUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PetStatusEntity() when $default != null:
return $default(_that.satiety,_that.energy,_that.happiness,_that.hygiene,_that.isSleeping,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double satiety,  double energy,  double happiness,  double hygiene,  bool isSleeping, @UtcEpochMillisConverter()  DateTime lastUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _PetStatusEntity():
return $default(_that.satiety,_that.energy,_that.happiness,_that.hygiene,_that.isSleeping,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double satiety,  double energy,  double happiness,  double hygiene,  bool isSleeping, @UtcEpochMillisConverter()  DateTime lastUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PetStatusEntity() when $default != null:
return $default(_that.satiety,_that.energy,_that.happiness,_that.hygiene,_that.isSleeping,_that.lastUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PetStatusEntity implements PetStatusEntity {
  const _PetStatusEntity({required this.satiety, required this.energy, required this.happiness, required this.hygiene, this.isSleeping = false, @UtcEpochMillisConverter() required this.lastUpdatedAt});
  factory _PetStatusEntity.fromJson(Map<String, dynamic> json) => _$PetStatusEntityFromJson(json);

@override final  double satiety;
@override final  double energy;
@override final  double happiness;
@override final  double hygiene;
@override@JsonKey() final  bool isSleeping;
@override@UtcEpochMillisConverter() final  DateTime lastUpdatedAt;

/// Create a copy of PetStatusEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PetStatusEntityCopyWith<_PetStatusEntity> get copyWith => __$PetStatusEntityCopyWithImpl<_PetStatusEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PetStatusEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PetStatusEntity&&(identical(other.satiety, satiety) || other.satiety == satiety)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.happiness, happiness) || other.happiness == happiness)&&(identical(other.hygiene, hygiene) || other.hygiene == hygiene)&&(identical(other.isSleeping, isSleeping) || other.isSleeping == isSleeping)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,satiety,energy,happiness,hygiene,isSleeping,lastUpdatedAt);

@override
String toString() {
  return 'PetStatusEntity(satiety: $satiety, energy: $energy, happiness: $happiness, hygiene: $hygiene, isSleeping: $isSleeping, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$PetStatusEntityCopyWith<$Res> implements $PetStatusEntityCopyWith<$Res> {
  factory _$PetStatusEntityCopyWith(_PetStatusEntity value, $Res Function(_PetStatusEntity) _then) = __$PetStatusEntityCopyWithImpl;
@override @useResult
$Res call({
 double satiety, double energy, double happiness, double hygiene, bool isSleeping,@UtcEpochMillisConverter() DateTime lastUpdatedAt
});




}
/// @nodoc
class __$PetStatusEntityCopyWithImpl<$Res>
    implements _$PetStatusEntityCopyWith<$Res> {
  __$PetStatusEntityCopyWithImpl(this._self, this._then);

  final _PetStatusEntity _self;
  final $Res Function(_PetStatusEntity) _then;

/// Create a copy of PetStatusEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? satiety = null,Object? energy = null,Object? happiness = null,Object? hygiene = null,Object? isSleeping = null,Object? lastUpdatedAt = null,}) {
  return _then(_PetStatusEntity(
satiety: null == satiety ? _self.satiety : satiety // ignore: cast_nullable_to_non_nullable
as double,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as double,happiness: null == happiness ? _self.happiness : happiness // ignore: cast_nullable_to_non_nullable
as double,hygiene: null == hygiene ? _self.hygiene : hygiene // ignore: cast_nullable_to_non_nullable
as double,isSleeping: null == isSleeping ? _self.isSleeping : isSleeping // ignore: cast_nullable_to_non_nullable
as bool,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
