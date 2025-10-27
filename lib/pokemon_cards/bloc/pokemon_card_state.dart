part of 'pokemon_card_bloc.dart';

enum PokemonCardStatus { initial, success, failure }

final class PokemonCardState extends Equatable {
  const PokemonCardState({
    this.status = PokemonCardStatus.initial,
    this.cards = const <PokemonCard>[],
    this.hasReachedMax = false,
    this.searchQuery = '',
  });

  final PokemonCardStatus status;
  final List<PokemonCard> cards;
  final bool hasReachedMax;
  final String searchQuery;

  PokemonCardState copyWith({
    PokemonCardStatus? status,
    List<PokemonCard>? cards,
    bool? hasReachedMax,
    String? searchQuery,
  }) {
    return PokemonCardState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [
        status,
        cards,
        hasReachedMax,
        searchQuery,
      ];
}
