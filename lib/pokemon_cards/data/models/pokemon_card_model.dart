import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';

class PokemonCardModel {
  const PokemonCardModel({
    required this.id,
    required this.name,
    required this.images,
    this.hp,
    this.supertype,
  });

  factory PokemonCardModel.fromJson(Map<String, dynamic> json) {
    return PokemonCardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      images: CardImagesModel.fromJson(json['images'] as Map<String, dynamic>),
      hp: json['hp'] as String?,
      supertype: json['supertype'] as String?,
    );
  }

  final String id;
  final String name;
  final CardImagesModel images;
  final String? hp;
  final String? supertype;

  PokemonCard toEntity() {
    return PokemonCard(
      id: id,
      name: name,
      imageUrl: images.large,
      hp: hp,
      supertype: supertype,
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
