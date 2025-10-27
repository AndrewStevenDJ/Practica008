part of 'pokemon_card_detail_bloc.dart';

enum PokemonCardDetailStatus { initial, loading, success, failure }

final class PokemonCardDetailState extends Equatable {
  const PokemonCardDetailState({
    this.status = PokemonCardDetailStatus.initial,
    this.card,
  });

  final PokemonCardDetailStatus status;
  final PokemonCard? card;

  PokemonCardDetailState copyWith({
    PokemonCardDetailStatus? status,
    PokemonCard? card,
  }) {
    return PokemonCardDetailState(
      status: status ?? this.status,
      card: card ?? this.card,
    );
  }

  @override
  List<Object?> get props => [status, card];
}
