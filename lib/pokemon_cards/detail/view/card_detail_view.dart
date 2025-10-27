import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokecard_dex/pokemon_cards/detail/bloc/pokemon_card_detail_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';

class CardDetailView extends StatelessWidget {
  const CardDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PokemonCardDetailBloc, PokemonCardDetailState>(
        builder: (context, state) {
          return switch (state.status) {
            PokemonCardDetailStatus.initial ||
            PokemonCardDetailStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            PokemonCardDetailStatus.failure => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Error al cargar el detalle'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            PokemonCardDetailStatus.success =>
              _DetailContent(card: state.card!),
          };
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.card});

  final PokemonCard card;

  Color _getTypeColor(String? type) {
    if (type == null) return Colors.grey;
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow.shade700;
      case 'psychic':
        return Colors.purple;
      case 'fighting':
        return Colors.red.shade900;
      case 'darkness':
        return Colors.grey.shade800;
      case 'metal':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pink;
      case 'dragon':
        return Colors.indigo;
      case 'colorless':
        return Colors.grey.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryType = card.types?.first;
    final backgroundColor = _getTypeColor(primaryType);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor,
                    backgroundColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Hero(
                tag: 'card-${card.id}',
                child: Image.network(
                  card.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (card.types != null && card.types!.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    children: card.types!
                        .map(
                          (type) => Chip(
                            label: Text(type),
                            backgroundColor: _getTypeColor(type),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                _InfoRow(
                  label: 'HP',
                  value: card.hp ?? 'N/A',
                ),
                _InfoRow(
                  label: 'Supertipo',
                  value: card.supertype ?? 'N/A',
                ),
                if (card.rarity != null)
                  _InfoRow(
                    label: 'Rareza',
                    value: card.rarity!,
                  ),
                if (card.set != null)
                  _InfoRow(
                    label: 'Set',
                    value: card.set!,
                  ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver a la lista'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
