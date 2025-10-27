import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';
import 'package:pokecard_dex/pokemon_cards/domain/repositories/pokemon_card_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'pokemon_card_event.dart';
part 'pokemon_card_state.dart';

const _throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PokemonCardBloc extends Bloc<PokemonCardEvent, PokemonCardState> {
  PokemonCardBloc({required PokemonCardRepository pokemonCardRepository})
      : _pokemonCardRepository = pokemonCardRepository,
        super(const PokemonCardState()) {
    on<CardsFetched>(
      _onCardsFetched,
      transformer: throttleDroppable(_throttleDuration),
    );
    on<CardsRefreshed>(_onCardsRefreshed);
    on<CardsSearched>(_onCardsSearched);
    on<TypeFilterChanged>(_onTypeFilterChanged);
  }

  final PokemonCardRepository _pokemonCardRepository;
  int _currentPage = 1;

  Future<void> _onCardsSearched(
    CardsSearched event,
    Emitter<PokemonCardState> emit,
  ) async {
    // Resetear estado y comenzar búsqueda
    _currentPage = 1;
    emit(
      state.copyWith(
        status: PokemonCardStatus.initial,
        cards: [],
        hasReachedMax: false,
        searchQuery: event.query,
      ),
    );

    try {
      final cards = await _pokemonCardRepository.getCards(
        page: _currentPage,
        searchQuery: event.query.isNotEmpty ? event.query : null,
        typeFilters: state.activeFilters.isNotEmpty ? state.activeFilters : null,
      );
      _currentPage++;
      emit(
        state.copyWith(
          status: PokemonCardStatus.success,
          cards: cards,
          hasReachedMax: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: PokemonCardStatus.failure));
    }
  }

  Future<void> _onTypeFilterChanged(
    TypeFilterChanged event,
    Emitter<PokemonCardState> emit,
  ) async {
    // Resetear estado y aplicar filtros
    _currentPage = 1;
    emit(
      state.copyWith(
        status: PokemonCardStatus.initial,
        cards: [],
        hasReachedMax: false,
        activeFilters: event.types,
      ),
    );

    try {
      final cards = await _pokemonCardRepository.getCards(
        page: _currentPage,
        searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        typeFilters: event.types.isNotEmpty ? event.types : null,
      );
      _currentPage++;
      emit(
        state.copyWith(
          status: PokemonCardStatus.success,
          cards: cards,
          hasReachedMax: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: PokemonCardStatus.failure));
    }
  }

  Future<void> _onCardsRefreshed(
    CardsRefreshed event,
    Emitter<PokemonCardState> emit,
  ) async {
    // Resetear el estado a inicial pero mantener el searchQuery y filtros
    final currentQuery = state.searchQuery;
    final currentFilters = state.activeFilters;
    _currentPage = 1;
    emit(
      PokemonCardState(
        searchQuery: currentQuery,
        activeFilters: currentFilters,
      ),
    );
    
    // Obtener la primera página de nuevo con el query y filtros actuales
    try {
      final cards = await _pokemonCardRepository.getCards(
        page: _currentPage,
        searchQuery: currentQuery.isNotEmpty ? currentQuery : null,
        typeFilters: currentFilters.isNotEmpty ? currentFilters : null,
      );
      _currentPage++;
      emit(
        state.copyWith(
          status: PokemonCardStatus.success,
          cards: cards,
          hasReachedMax: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: PokemonCardStatus.failure));
    }
  }

  Future<void> _onCardsFetched(
    CardsFetched event,
    Emitter<PokemonCardState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PokemonCardStatus.initial) {
        final cards = await _pokemonCardRepository.getCards(
          page: _currentPage,
          searchQuery:
              state.searchQuery.isNotEmpty ? state.searchQuery : null,
          typeFilters:
              state.activeFilters.isNotEmpty ? state.activeFilters : null,
        );
        _currentPage++;
        return emit(
          state.copyWith(
            status: PokemonCardStatus.success,
            cards: cards,
            hasReachedMax: false,
          ),
        );
      }

      final cards = await _pokemonCardRepository.getCards(
        page: _currentPage,
        searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        typeFilters:
            state.activeFilters.isNotEmpty ? state.activeFilters : null,
      );
      _currentPage++;
      if (cards.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: PokemonCardStatus.success,
            cards: List.of(state.cards)..addAll(cards),
            hasReachedMax: false,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: PokemonCardStatus.failure));
    }
  }
}
