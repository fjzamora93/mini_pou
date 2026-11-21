// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pet {

 String get name; double get satiety; double get energy; double get happiness; double get hygiene; bool get isSleeping;// Saves from before species existed (or with a removed one) fall back
// to the default bird instead of being discarded as unreadable.
@JsonKey(unknownEnumValue: PetSpecies.fallback) PetSpecies get species;@UtcEpochMillisConverter() DateTime get lastUpdatedAt;
/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PetCopyWith<Pet> get copyWith => _$PetCopyWithImpl<Pet>(this as Pet, _$identity);

  /// Serializes this Pet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pet&&(identical(other.name, name) || other.name == name)&&(identical(other.satiety, satiety) || other.satiety == satiety)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.happiness, happiness) || other.happiness == happiness)&&(identical(other.hygiene, hygiene) || other.hygiene == hygiene)&&(identical(other.isSleeping, isSleeping) || other.isSleeping == isSleeping)&&(identical(other.species, species) || other.species == species)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,satiety,energy,happiness,hygiene,isSleeping,species,lastUpdatedAt);

@override
String toString() {
  return 'Pet(name: $name, satiety: $satiety, energy: $energy, happiness: $happiness, hygiene: $hygiene, isSleeping: $isSleeping, species: $species, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $PetCopyWith<$Res>  {
  factory $PetCopyWith(Pet value, $Res Function(Pet) _then) = _$PetCopyWithImpl;
@useResult
$Res call({
 String name, double satiety, double energy, double happiness, double hygiene, bool isSleeping,@JsonKey(unknownEnumValue: PetSpecies.fallback) PetSpecies species,@UtcEpochMillisConverter() DateTime lastUpdatedAt
});




}
/// @nodoc
class _$PetCopyWithImpl<$Res>
    implements $PetCopyWith<$Res> {
  _$PetCopyWithImpl(this._self, this._then);

  final Pet _self;
  final $Res Function(Pet) _then;

/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? satiety = null,Object? energy = null,Object? happiness = null,Object? hygiene = null,Object? isSleeping = null,Object? species = null,Object? lastUpdatedAt = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,satiety: null == satiety ? _self.satiety : satiety // ignore: cast_nullable_to_non_nullable
as double,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as double,happiness: null == happiness ? _self.happiness : happiness // ignore: cast_nullable_to_non_nullable
as double,hygiene: null == hygiene ? _self.hygiene : hygiene // ignore: cast_nullable_to_non_nullable
as double,isSleeping: null == isSleeping ? _self.isSleeping : isSleeping // ignore: cast_nullable_to_non_nullable
as bool,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Pet].
extension PetPatterns on Pet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pet value)  $default,){
final _that = this;
switch (_that) {
case _Pet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pet value)?  $default,){
final _that = this;
switch (_that) {
case _Pet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double satiety,  double energy,  double happiness,  double hygiene,  bool isSleeping, @JsonKey(unknownEnumValue: PetSpecies.fallback)  PetSpecies species, @UtcEpochMillisConverter()  DateTime lastUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pet() when $default != null:
return $default(_that.name,_that.satiety,_that.energy,_that.happiness,_that.hygiene,_that.isSleeping,_that.species,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double satiety,  double energy,  double happiness,  double hygiene,  bool isSleeping, @JsonKey(unknownEnumValue: PetSpecies.fallback)  PetSpecies species, @UtcEpochMillisConverter()  DateTime lastUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _Pet():
return $default(_that.name,_that.satiety,_that.energy,_that.happiness,_that.hygiene,_that.isSleeping,_that.species,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double satiety,  double energy,  double happiness,  double hygiene,  bool isSleeping, @JsonKey(unknownEnumValue: PetSpecies.fallback)  PetSpecies species, @UtcEpochMillisConverter()  DateTime lastUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Pet() when $default != null:
return $default(_that.name,_that.satiety,_that.energy,_that.happiness,_that.hygiene,_that.isSleeping,_that.species,_that.lastUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pet implements Pet {
  const _Pet({required this.name, required this.satiety, required this.energy, required this.happiness, required this.hygiene, this.isSleeping = false, @JsonKey(unknownEnumValue: PetSpecies.fallback) this.species = PetSpecies.fallback, @UtcEpochMillisConverter() required this.lastUpdatedAt});
  factory _Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);

@override final  String name;
@override final  double satiety;
@override final  double energy;
@override final  double happiness;
@override final  double hygiene;
@override@JsonKey() final  bool isSleeping;
// Saves from before species existed (or with a removed one) fall back
// to the default bird instead of being discarded as unreadable.
@override@JsonKey(unknownEnumValue: PetSpecies.fallback) final  PetSpecies species;
@override@UtcEpochMillisConverter() final  DateTime lastUpdatedAt;

/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PetCopyWith<_Pet> get copyWith => __$PetCopyWithImpl<_Pet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pet&&(identical(other.name, name) || other.name == name)&&(identical(other.satiety, satiety) || other.satiety == satiety)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.happiness, happiness) || other.happiness == happiness)&&(identical(other.hygiene, hygiene) || other.hygiene == hygiene)&&(identical(other.isSleeping, isSleeping) || other.isSleeping == isSleeping)&&(identical(other.species, species) || other.species == species)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,satiety,energy,happiness,hygiene,isSleeping,species,lastUpdatedAt);

@override
String toString() {
  return 'Pet(name: $name, satiety: $satiety, energy: $energy, happiness: $happiness, hygiene: $hygiene, isSleeping: $isSleeping, species: $species, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$PetCopyWith<$Res> implements $PetCopyWith<$Res> {
  factory _$PetCopyWith(_Pet value, $Res Function(_Pet) _then) = __$PetCopyWithImpl;
@override @useResult
$Res call({
 String name, double satiety, double energy, double happiness, double hygiene, bool isSleeping,@JsonKey(unknownEnumValue: PetSpecies.fallback) PetSpecies species,@UtcEpochMillisConverter() DateTime lastUpdatedAt
});




}
/// @nodoc
class __$PetCopyWithImpl<$Res>
    implements _$PetCopyWith<$Res> {
  __$PetCopyWithImpl(this._self, this._then);

  final _Pet _self;
  final $Res Function(_Pet) _then;

/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? satiety = null,Object? energy = null,Object? happiness = null,Object? hygiene = null,Object? isSleeping = null,Object? species = null,Object? lastUpdatedAt = null,}) {
  return _then(_Pet(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,satiety: null == satiety ? _self.satiety : satiety // ignore: cast_nullable_to_non_nullable
as double,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as double,happiness: null == happiness ? _self.happiness : happiness // ignore: cast_nullable_to_non_nullable
as double,hygiene: null == hygiene ? _self.hygiene : hygiene // ignore: cast_nullable_to_non_nullable
as double,isSleeping: null == isSleeping ? _self.isSleeping : isSleeping // ignore: cast_nullable_to_non_nullable
as bool,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
