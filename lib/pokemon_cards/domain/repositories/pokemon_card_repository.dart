import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';

abstract class PokemonCardRepository {
  Future<List<PokemonCard>> getCards({required int page, int pageSize = 20});
}
