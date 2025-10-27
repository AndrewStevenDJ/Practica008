import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/data/repositories/pokemon_card_repository_impl.dart';
import 'package:pokecard_dex/pokemon_cards/detail/bloc/pokemon_card_detail_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/detail/view/card_detail_view.dart';

class CardDetailPage extends StatelessWidget {
  const CardDetailPage({required this.cardId, super.key});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PokemonCardDetailBloc(
        pokemonCardRepository: PokemonCardRepositoryImpl(),
      )..add(CardDetailRequested(cardId)),
      child: const CardDetailView(),
    );
  }
}
