import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pokecard_dex/pokemon_cards/bloc/pokemon_card_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/data/datasources/pokemon_card_cache.dart';
import 'package:pokecard_dex/pokemon_cards/data/repositories/pokemon_card_repository_impl.dart';
import 'package:pokecard_dex/pokemon_cards/view/cards_view.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cacheBox = Hive.box<List<dynamic>>('pokemon_cards_cache');
    final cache = PokemonCardCache(box: cacheBox);
    
    return BlocProvider(
      create: (_) => PokemonCardBloc(
        pokemonCardRepository: PokemonCardRepositoryImpl(cache: cache),
      )..add(CardsFetched()),
      child: const CardsView(),
    );
  }
}
