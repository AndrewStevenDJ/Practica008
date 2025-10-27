import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';
import 'package:pokecard_dex/pokemon_cards/domain/repositories/pokemon_card_repository.dart';

part 'pokemon_card_detail_event.dart';
part 'pokemon_card_detail_state.dart';

class PokemonCardDetailBloc
    extends Bloc<PokemonCardDetailEvent, PokemonCardDetailState> {
  PokemonCardDetailBloc({
    required PokemonCardRepository pokemonCardRepository,
  })  : _pokemonCardRepository = pokemonCardRepository,
        super(const PokemonCardDetailState()) {
    on<CardDetailRequested>(_onCardDetailRequested);
  }

  final PokemonCardRepository _pokemonCardRepository;

  Future<void> _onCardDetailRequested(
    CardDetailRequested event,
    Emitter<PokemonCardDetailState> emit,
  ) async {
    emit(state.copyWith(status: PokemonCardDetailStatus.loading));
    try {
      final card = await _pokemonCardRepository.getCardById(event.cardId);
      emit(
        state.copyWith(
          status: PokemonCardDetailStatus.success,
          card: card,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: PokemonCardDetailStatus.failure));
    }
  }
}
