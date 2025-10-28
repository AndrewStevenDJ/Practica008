import 'package:hive/hive.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';

part 'pokemon_card_model.g.dart';

@HiveType(typeId: 0)
class PokemonCardModel {
  PokemonCardModel({
    required this.id,
    required this.name,
    required this.images,
    this.hp,
    this.supertype,
    this.types,
    this.rarity,
    this.set,
  });

  factory PokemonCardModel.fromJson(Map<String, dynamic> json) {
    return PokemonCardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      images: CardImagesModel.fromJson(json['images'] as Map<String, dynamic>),
      hp: json['hp'] as String?,
      supertype: json['supertype'] as String?,
      types: json['types'] != null
          ? (json['types'] as List).map((e) => e as String).toList()
          : null,
      rarity: json['rarity'] as String?,
      set: json['set'] != null ? json['set']['name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': {'small': images.small, 'large': images.large},
      'hp': hp,
      'supertype': supertype,
      'types': types,
      'rarity': rarity,
      'set': set,
    };
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final CardImagesModel images;
  @HiveField(3)
  final String? hp;
  @HiveField(4)
  final String? supertype;
  @HiveField(5)
  final List<String>? types;
  @HiveField(6)
  final String? rarity;
  @HiveField(7)
  final String? set;

  PokemonCard toEntity() {
    return PokemonCard(
      id: id,
      name: name,
      imageUrl: images.large,
      hp: hp,
      supertype: supertype,
      types: types,
      rarity: rarity,
      set: set,
    );
  }
}

@HiveType(typeId: 1)
class CardImagesModel {
  CardImagesModel({required this.small, required this.large});

  factory CardImagesModel.fromJson(Map<String, dynamic> json) {
    return CardImagesModel(
      small: json['small'] as String,
      large: json['large'] as String,
    );
  }

  @HiveField(0)
  final String small;
  @HiveField(1)
  final String large;
}
