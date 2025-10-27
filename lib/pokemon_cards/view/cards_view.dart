import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/bloc/pokemon_card_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/widgets/bottom_loader.dart';
import 'package:pokecard_dex/pokemon_cards/widgets/card_list_item.dart';
import 'package:pokecard_dex/pokemon_cards/widgets/type_filter_drawer.dart';

class CardsView extends StatefulWidget {
  const CardsView({super.key});

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PokéCard Dex'),
        actions: [
          BlocBuilder<PokemonCardBloc, PokemonCardState>(
            builder: (context, state) {
              final hasFilters = state.activeFilters.isNotEmpty;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    tooltip: 'Filtrar por tipo',
                  ),
                  if (hasFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${state.activeFilters.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PokemonCardBloc>().add(
                          const CardsSearched(''),
                        );
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (query) {
                context.read<PokemonCardBloc>().add(
                      CardsSearched(query.trim()),
                    );
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<PokemonCardBloc, PokemonCardState>(
        builder: (context, state) {
          switch (state.status) {
            case PokemonCardStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Fallo al obtener las cartas'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<PokemonCardBloc>()
                          .add(CardsRefreshed()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            case PokemonCardStatus.success:
              if (state.cards.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<PokemonCardBloc>().add(CardsRefreshed());
                    // Esperar un poco para que la animación se vea bien
                    await Future<void>.delayed(const Duration(seconds: 1));
                  },
                  child: const Center(
                    child: Text('No se encontraron cartas'),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PokemonCardBloc>().add(CardsRefreshed());
                  // Esperar a que se complete el refresh
                  await Future<void>.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.hasReachedMax
                      ? state.cards.length
                      : state.cards.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    return index >= state.cards.length
                        ? const BottomLoader()
                        : CardListItem(card: state.cards[index]);
                  },
                ),
              );
            case PokemonCardStatus.initial:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      endDrawer: const TypeFilterDrawer(),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<PokemonCardBloc>().add(CardsFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }
}
