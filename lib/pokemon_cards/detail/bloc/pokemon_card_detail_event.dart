part of 'pokemon_card_detail_bloc.dart';

sealed class PokemonCardDetailEvent extends Equatable {
  const PokemonCardDetailEvent();

  @override
  List<Object> get props => [];
}

final class CardDetailRequested extends PokemonCardDetailEvent {
  const CardDetailRequested(this.cardId);

  final String cardId;

  @override
  List<Object> get props => [cardId];
}
