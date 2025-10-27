import 'package:equatable/equatable.dart';

class PokemonCard extends Equatable {
  const PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.hp,
    this.supertype,
    this.types,
    this.rarity,
    this.set,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String? hp;
  final String? supertype;
  final List<String>? types;
  final String? rarity;
  final String? set;

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        hp,
        supertype,
        types,
        rarity,
        set,
      ];
}
