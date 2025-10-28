import 'package:dio/dio.dart';
import 'package:pokecard_dex/pokemon_cards/data/datasources/pokemon_card_cache.dart';
import 'package:pokecard_dex/pokemon_cards/data/models/pokemon_card_model.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';
import 'package:pokecard_dex/pokemon_cards/domain/repositories/pokemon_card_repository.dart';

class PokemonCardRepositoryImpl implements PokemonCardRepository {
  PokemonCardRepositoryImpl({
    Dio? dio,
    required this.cache,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 90),
                receiveTimeout: const Duration(seconds: 90),
              ),
            );

  final Dio _dio;
  final PokemonCardCache cache;
  final String _baseUrl = 'https://api.pokemontcg.io/v2';

  @override
  Future<List<PokemonCard>> getCards({
    required int page,
    int pageSize = 10,
    String? searchQuery,
    Set<String>? typeFilters,
  }) async {
    print('🔵 getCards called - page: $page, search: $searchQuery, types: $typeFilters');
    
    // Intentar cargar desde caché primero
    List<PokemonCardModel>? cachedCards;
    
    try {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        cachedCards = cache.getSearchResults(searchQuery, page);
        if (cachedCards != null) {
          print('✅ Loaded ${cachedCards.length} cards from SEARCH CACHE');
          return cachedCards.map((model) => model.toEntity()).toList();
        }
      } else if (typeFilters != null && typeFilters.isNotEmpty) {
        cachedCards = cache.getTypeFilterResults(typeFilters, page);
        if (cachedCards != null) {
          print('✅ Loaded ${cachedCards.length} cards from TYPE FILTER CACHE');
          return cachedCards.map((model) => model.toEntity()).toList();
        }
      } else {
        cachedCards = cache.getCards(page);
        if (cachedCards != null) {
          print('✅ Loaded ${cachedCards.length} cards from CACHE (page $page)');
          return cachedCards.map((model) => model.toEntity()).toList();
        }
      }
    } catch (e) {
      print('⚠️ Error reading cache: $e');
      cachedCards = null;
    }

    // Si no hay caché, cargar desde API
    print('🌐 Loading from API...');
    
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'orderBy': 'name',
      };

      // Construir query combinando búsqueda y filtros
      final queryParts = <String>[];
      
      // Agregar query de búsqueda si existe
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Probamos sin comillas para búsquedas más rápidas
        queryParts.add('name:$searchQuery*');
      }
      
      // Agregar filtros de tipos si existen
      if (typeFilters != null && typeFilters.isNotEmpty) {
        // La API espera los tipos con la primera letra en mayúscula
        // Si hay un solo tipo, no usar paréntesis. Si hay múltiples, usar OR
        if (typeFilters.length == 1) {
          queryParts.add('types:${typeFilters.first}');
        } else {
          final typesQuery = typeFilters.join(' OR ');
          queryParts.add('types:($typesQuery)');
        }
      }
      
      // Combinar todas las partes del query con AND
      if (queryParts.isNotEmpty) {
        queryParameters['q'] = queryParts.join(' AND ');
      }

      print('🔍 Request URL: $_baseUrl/cards');
      print('🔍 Query params: $queryParameters');

      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/cards',
        queryParameters: queryParameters,
      );

      print('✅ Response status: ${response.statusCode}');
      print('✅ Data count: ${(response.data!['data'] as List).length}');

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data!['data'] as List;
        final cardModels = results
            .map(
              (cardData) => PokemonCardModel.fromJson(
                cardData as Map<String, dynamic>,
              ),
            )
            .toList();
        
        // Guardar en caché según el tipo de consulta
        if (searchQuery != null && searchQuery.isNotEmpty) {
          await cache.saveSearchResults(cardModels, searchQuery, page);
          print('💾 Saved search results to cache');
        } else if (typeFilters != null && typeFilters.isNotEmpty) {
          await cache.saveTypeFilterResults(cardModels, typeFilters, page);
          print('💾 Saved type filter results to cache');
        } else {
          await cache.saveCards(cardModels, page);
          print('💾 Saved cards to cache (page $page)');
        }
        
        final cards = cardModels.map((model) => model.toEntity()).toList();
        return cards;
      } else {
        throw Exception('Failed to load Pokémon cards');
      }
    } on DioException catch (e) {
      // Si falla la API pero hay caché antiguo, úsalo como fallback
      print('❌ Dio Error: ${e.type}');
      print('❌ Message: ${e.message}');
      
      // Intentar usar caché expirado como último recurso
      if (cachedCards == null) {
        if (searchQuery != null && searchQuery.isNotEmpty) {
          cachedCards = cache.getSearchResults(searchQuery, page);
        } else if (typeFilters != null && typeFilters.isNotEmpty) {
          cachedCards = cache.getTypeFilterResults(typeFilters, page);
        } else {
          cachedCards = cache.getCards(page);
        }
      }
      
      if (cachedCards != null) {
        print('⚠️ Using expired cache as fallback');
        return cachedCards.map((model) => model.toEntity()).toList();
      }
      
      throw Exception('Failed to load Pokémon cards: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to load Pokémon cards: $e');
    }
  }

  @override
  Future<PokemonCard> getCardById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/cards/$id',
      );

      if (response.statusCode == 200 && response.data != null) {
        final cardData = response.data!['data'] as Map<String, dynamic>;
        return PokemonCardModel.fromJson(cardData).toEntity();
      } else {
        throw Exception('Failed to load Pokémon card detail');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load Pokémon card detail: ${e.message}');
    }
  }
}
