import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pokecard_dex/pokemon_cards/data/datasources/pokemon_card_cache.dart';
import 'package:pokecard_dex/pokemon_cards/data/repositories/pokemon_card_repository_impl.dart';
import 'package:pokecard_dex/pokemon_cards/detail/bloc/pokemon_card_detail_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/detail/view/card_detail_view.dart';

class CardDetailPage extends StatelessWidget {
  const CardDetailPage({required this.cardId, super.key});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    final cacheBox = Hive.box<List<dynamic>>('pokemon_cards_cache');
    final cache = PokemonCardCache(box: cacheBox);
    
    return BlocProvider(
      create: (context) => PokemonCardDetailBloc(
        pokemonCardRepository: PokemonCardRepositoryImpl(cache: cache),
      )..add(CardDetailRequested(cardId)),
      child: const CardDetailView(),
    );
  }
}
