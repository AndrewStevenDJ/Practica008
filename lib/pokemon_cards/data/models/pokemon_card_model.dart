import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';

class PokemonCardModel {
  const PokemonCardModel({
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

  final String id;
  final String name;
  final CardImagesModel images;
  final String? hp;
  final String? supertype;
  final List<String>? types;
  final String? rarity;
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

class CardImagesModel {
  const CardImagesModel({required this.small, required this.large});

  factory CardImagesModel.fromJson(Map<String, dynamic> json) {
    return CardImagesModel(
      small: json['small'] as String,
      large: json['large'] as String,
    );
  }

  final String small;
  final String large;
}
