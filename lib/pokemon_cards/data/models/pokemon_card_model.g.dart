// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PokemonCardModelAdapter extends TypeAdapter<PokemonCardModel> {
  @override
  final int typeId = 0;

  @override
  PokemonCardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PokemonCardModel(
      id: fields[0] as String,
      name: fields[1] as String,
      images: fields[2] as CardImagesModel,
      hp: fields[3] as String?,
      supertype: fields[4] as String?,
      types: (fields[5] as List?)?.cast<String>(),
      rarity: fields[6] as String?,
      set: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PokemonCardModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.images)
      ..writeByte(3)
      ..write(obj.hp)
      ..writeByte(4)
      ..write(obj.supertype)
      ..writeByte(5)
      ..write(obj.types)
      ..writeByte(6)
      ..write(obj.rarity)
      ..writeByte(7)
      ..write(obj.set);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonCardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CardImagesModelAdapter extends TypeAdapter<CardImagesModel> {
  @override
  final int typeId = 1;

  @override
  CardImagesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardImagesModel(
      small: fields[0] as String,
      large: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CardImagesModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.small)
      ..writeByte(1)
      ..write(obj.large);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardImagesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
