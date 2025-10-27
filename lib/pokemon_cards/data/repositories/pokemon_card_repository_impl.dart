import 'package:dio/dio.dart';
import 'package:pokecard_dex/pokemon_cards/data/models/pokemon_card_model.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';
import 'package:pokecard_dex/pokemon_cards/domain/repositories/pokemon_card_repository.dart';

class PokemonCardRepositoryImpl implements PokemonCardRepository {
  PokemonCardRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final String _baseUrl = 'https://api.pokemontcg.io/v2';

  @override
  Future<List<PokemonCard>> getCards({
    required int page,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'orderBy': 'name',
      };

      // Agregar query de búsqueda si existe
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['q'] = 'name:$searchQuery*';
      }

      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/cards',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data!['data'] as List;
        final cards = results
            .map(
              (cardData) => PokemonCardModel.fromJson(
                cardData as Map<String, dynamic>,
              ).toEntity(),
            )
            .toList();
        return cards;
      } else {
        throw Exception('Failed to load Pokémon cards');
      }
    } on DioException catch (e) {
      // Manejar errores específicos de Dio (ej. problemas de red)
      throw Exception('Failed to load Pokémon cards: ${e.message}');
    }
  }
}
