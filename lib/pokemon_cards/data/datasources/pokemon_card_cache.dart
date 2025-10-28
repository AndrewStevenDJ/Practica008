import 'package:hive/hive.dart';
import 'package:pokecard_dex/pokemon_cards/data/models/pokemon_card_model.dart';

/// Servicio de caché local para cartas Pokémon usando Hive
class PokemonCardCache {
  PokemonCardCache({required this.box});

  final Box<List<dynamic>> box;

  /// Guarda las cartas en caché
  Future<void> saveCards(List<PokemonCardModel> cards, int page) async {
    final key = _getPageKey(page);
    // Convertir a JSON y luego a Map<String, dynamic> explícitamente
    final jsonList = cards.map((card) {
      final json = card.toJson();
      return Map<String, dynamic>.from(json);
    }).toList();
    await box.put(key, jsonList);
    await box.put('${key}_timestamp', [DateTime.now().toIso8601String()]);
  }

  /// Obtiene las cartas desde caché
  List<PokemonCardModel>? getCards(int page) {
    try {
      final key = _getPageKey(page);
      final jsonList = box.get(key);
      
      if (jsonList == null) {
        print('📦 No cache found for page $page');
        return null;
      }

      // Verificar si el caché expiró (24 horas)
      final timestamp = box.get('${key}_timestamp');
      if (timestamp != null && timestamp.isNotEmpty) {
        final lastUpdate = DateTime.parse(timestamp[0] as String);
        final now = DateTime.now();
        if (now.difference(lastUpdate).inHours > 24) {
          print('⏰ Cache expired for page $page');
          return null; // Caché expirado
        }
      }

      print('📦 Loading ${jsonList.length} cards from cache (page $page)');
      return jsonList
          .map((json) {
            final map = Map<String, dynamic>.from(json as Map);
            return PokemonCardModel.fromJson(map);
          })
          .toList();
    } catch (e) {
      print('❌ Error reading cache: $e');
      return null;
    }
  }

  /// Guarda resultados de búsqueda
  Future<void> saveSearchResults(
    List<PokemonCardModel> cards,
    String query,
    int page,
  ) async {
    final key = _getSearchKey(query, page);
    final jsonList = cards.map((card) {
      final json = card.toJson();
      return Map<String, dynamic>.from(json);
    }).toList();
    await box.put(key, jsonList);
    await box.put('${key}_timestamp', [DateTime.now().toIso8601String()]);
  }

  /// Obtiene resultados de búsqueda desde caché
  List<PokemonCardModel>? getSearchResults(String query, int page) {
    final key = _getSearchKey(query, page);
    final jsonList = box.get(key);
    
    if (jsonList == null) return null;

    // Verificar expiración (1 hora para búsquedas)
    final timestamp = box.get('${key}_timestamp');
    if (timestamp != null && timestamp.isNotEmpty) {
      final lastUpdate = DateTime.parse(timestamp[0] as String);
      final now = DateTime.now();
      if (now.difference(lastUpdate).inHours > 1) {
        return null;
      }
    }

    return jsonList
        .map((json) {
          final map = Map<String, dynamic>.from(json as Map);
          return PokemonCardModel.fromJson(map);
        })
        .toList();
  }

  /// Guarda resultados de filtros por tipo
  Future<void> saveTypeFilterResults(
    List<PokemonCardModel> cards,
    Set<String> types,
    int page,
  ) async {
    final key = _getTypeFilterKey(types, page);
    final jsonList = cards.map((card) {
      final json = card.toJson();
      return Map<String, dynamic>.from(json);
    }).toList();
    await box.put(key, jsonList);
    await box.put('${key}_timestamp', [DateTime.now().toIso8601String()]);
  }

  /// Obtiene resultados de filtros por tipo desde caché
  List<PokemonCardModel>? getTypeFilterResults(Set<String> types, int page) {
    final key = _getTypeFilterKey(types, page);
    final jsonList = box.get(key);
    
    if (jsonList == null) return null;

    // Verificar expiración (1 hora para filtros)
    final timestamp = box.get('${key}_timestamp');
    if (timestamp != null && timestamp.isNotEmpty) {
      final lastUpdate = DateTime.parse(timestamp[0] as String);
      final now = DateTime.now();
      if (now.difference(lastUpdate).inHours > 1) {
        return null;
      }
    }

    return jsonList
        .map((json) {
          final map = Map<String, dynamic>.from(json as Map);
          return PokemonCardModel.fromJson(map);
        })
        .toList();
  }

  /// Limpia todo el caché
  Future<void> clearCache() async {
    await box.clear();
  }

  /// Limpia el caché expirado
  Future<void> clearExpiredCache() async {
    final keysToDelete = <String>[];
    
    for (final key in box.keys) {
      if (key.toString().endsWith('_timestamp')) {
        final timestamp = box.get(key);
        if (timestamp != null && timestamp.isNotEmpty) {
          final lastUpdate = DateTime.parse(timestamp[0] as String);
          final now = DateTime.now();
          if (now.difference(lastUpdate).inHours > 24) {
            keysToDelete.add(key.toString());
            keysToDelete.add(key.toString().replaceAll('_timestamp', ''));
          }
        }
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  String _getPageKey(int page) => 'cards_page_$page';
  
  String _getSearchKey(String query, int page) => 
      'search_${query.toLowerCase()}_page_$page';
  
  String _getTypeFilterKey(Set<String> types, int page) {
    final sortedTypes = types.toList()..sort();
    return 'types_${sortedTypes.join('_')}_page_$page';
  }
}
