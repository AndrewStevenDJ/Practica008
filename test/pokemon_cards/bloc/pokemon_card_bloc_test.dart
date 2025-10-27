import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokecard_dex/pokemon_cards/bloc/pokemon_card_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';
import 'package:pokecard_dex/pokemon_cards/domain/repositories/pokemon_card_repository.dart';

class MockPokemonCardRepository extends Mock
    implements PokemonCardRepository {}

void main() {
  group('PokemonCardBloc', () {
    late PokemonCardRepository mockRepository;

    setUp(() {
      mockRepository = MockPokemonCardRepository();
    });

    // Datos de prueba
    final mockCards = [
      const PokemonCard(
        id: 'xy1-1',
        name: 'Pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        hp: '60',
        supertype: 'Pokémon',
        types: ['Lightning'],
        rarity: 'Common',
        set: 'XY Base Set',
      ),
      const PokemonCard(
        id: 'xy1-2',
        name: 'Charizard',
        imageUrl: 'https://example.com/charizard.png',
        hp: '150',
        supertype: 'Pokémon',
        types: ['Fire'],
        rarity: 'Rare Holo',
        set: 'XY Base Set',
      ),
    ];

    test('initial state is PokemonCardState with initial status', () {
      final bloc = PokemonCardBloc(pokemonCardRepository: mockRepository);
      expect(bloc.state, const PokemonCardState());
      expect(bloc.state.status, PokemonCardStatus.initial);
      expect(bloc.state.cards, isEmpty);
      expect(bloc.state.hasReachedMax, false);
    });

    group('CardsFetched', () {
      blocTest<PokemonCardBloc, PokemonCardState>(
        'emits [success] when cards are fetched successfully on initial state',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => mockCards);
        },
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(CardsFetched()),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having((s) => s.cards, 'cards', mockCards)
              .having((s) => s.hasReachedMax, 'hasReachedMax', false),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: null,
              typeFilters: null,
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'emits [failure] when fetching cards throws an exception',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenThrow(Exception('Failed to load cards'));
        },
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(CardsFetched()),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.failure),
        ],
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'appends cards when more cards are fetched',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => mockCards);
        },
        seed: () => PokemonCardState(
          status: PokemonCardStatus.success,
          cards: mockCards,
          hasReachedMax: false,
        ),
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(CardsFetched()),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having(
                (s) => s.cards.length,
                'cards length',
                mockCards.length * 2,
              )
              .having((s) => s.hasReachedMax, 'hasReachedMax', false),
        ],
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'sets hasReachedMax to true when empty list is returned',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => []);
        },
        seed: () => PokemonCardState(
          status: PokemonCardStatus.success,
          cards: mockCards,
          hasReachedMax: false,
        ),
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(CardsFetched()),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.hasReachedMax, 'hasReachedMax', true)
              .having((s) => s.cards, 'cards', mockCards),
        ],
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'does not fetch when hasReachedMax is true',
        seed: () => PokemonCardState(
          status: PokemonCardStatus.success,
          cards: mockCards,
          hasReachedMax: true,
        ),
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(CardsFetched()),
        expect: () => <PokemonCardState>[],
        verify: (_) {
          verifyNever(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          );
        },
      );
    });

    group('CardsRefreshed', () {
      blocTest<PokemonCardBloc, PokemonCardState>(
        'resets state and fetches first page again',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => mockCards);
        },
        seed: () => PokemonCardState(
          status: PokemonCardStatus.success,
          cards: mockCards,
          hasReachedMax: true,
        ),
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(CardsRefreshed()),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.initial)
              .having((s) => s.cards, 'cards', isEmpty),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having((s) => s.cards, 'cards', mockCards)
              .having((s) => s.hasReachedMax, 'hasReachedMax', false),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: null,
              typeFilters: null,
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'maintains searchQuery during refresh',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => mockCards);
        },
        seed: () => const PokemonCardState(
          status: PokemonCardStatus.success,
          cards: [],
          searchQuery: 'pikachu',
        ),
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(CardsRefreshed()),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.searchQuery, 'searchQuery', 'pikachu'),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having((s) => s.searchQuery, 'searchQuery', 'pikachu'),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: 'pikachu',
              typeFilters: null,
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'maintains activeFilters during refresh',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => mockCards);
        },
        seed: () => const PokemonCardState(
          status: PokemonCardStatus.success,
          cards: [],
          activeFilters: {'Fire', 'Water'},
        ),
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(CardsRefreshed()),
        expect: () => [
          isA<PokemonCardState>()
              .having(
                (s) => s.activeFilters,
                'activeFilters',
                {'Fire', 'Water'},
              ),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having(
                (s) => s.activeFilters,
                'activeFilters',
                {'Fire', 'Water'},
              ),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: null,
              typeFilters: {'Fire', 'Water'},
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'emits [failure] when refresh fails',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenThrow(Exception('Failed to refresh'));
        },
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(CardsRefreshed()),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.initial),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.failure),
        ],
      );
    });

    group('CardsSearched', () {
      blocTest<PokemonCardBloc, PokemonCardState>(
        'resets state and fetches cards with search query',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => [mockCards[0]]);
        },
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(const CardsSearched('pikachu')),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.initial)
              .having((s) => s.searchQuery, 'searchQuery', 'pikachu')
              .having((s) => s.cards, 'cards', isEmpty),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having((s) => s.searchQuery, 'searchQuery', 'pikachu')
              .having((s) => s.cards.length, 'cards length', 1),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: 'pikachu',
              typeFilters: null,
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'handles empty search query',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => mockCards);
        },
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(const CardsSearched('')),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.searchQuery, 'searchQuery', ''),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having((s) => s.cards, 'cards', mockCards),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: null,
              typeFilters: null,
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'maintains activeFilters during search',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => [mockCards[1]]);
        },
        seed: () => const PokemonCardState(
          activeFilters: {'Fire'},
        ),
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(const CardsSearched('charizard')),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.searchQuery, 'searchQuery', 'charizard')
              .having((s) => s.activeFilters, 'activeFilters', {'Fire'}),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having((s) => s.searchQuery, 'searchQuery', 'charizard')
              .having((s) => s.activeFilters, 'activeFilters', {'Fire'}),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: 'charizard',
              typeFilters: {'Fire'},
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'emits [failure] when search fails',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenThrow(Exception('Failed to search'));
        },
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(const CardsSearched('pikachu')),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.initial)
              .having((s) => s.searchQuery, 'searchQuery', 'pikachu'),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.failure),
        ],
      );
    });

    group('TypeFilterChanged', () {
      blocTest<PokemonCardBloc, PokemonCardState>(
        'resets state and fetches cards with type filters',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => [mockCards[1]]);
        },
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(const TypeFilterChanged({'Fire'})),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.initial)
              .having((s) => s.activeFilters, 'activeFilters', {'Fire'})
              .having((s) => s.cards, 'cards', isEmpty),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having((s) => s.activeFilters, 'activeFilters', {'Fire'})
              .having((s) => s.cards.length, 'cards length', 1),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: null,
              typeFilters: {'Fire'},
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'handles multiple type filters',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => mockCards);
        },
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) =>
            bloc.add(const TypeFilterChanged({'Fire', 'Water', 'Grass'})),
        expect: () => [
          isA<PokemonCardState>().having(
            (s) => s.activeFilters,
            'activeFilters',
            {'Fire', 'Water', 'Grass'},
          ),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having(
                (s) => s.activeFilters,
                'activeFilters',
                {'Fire', 'Water', 'Grass'},
              ),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: null,
              typeFilters: {'Fire', 'Water', 'Grass'},
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'clears filters when empty set is provided',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => mockCards);
        },
        seed: () => const PokemonCardState(
          status: PokemonCardStatus.success,
          activeFilters: {'Fire'},
        ),
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(const TypeFilterChanged({})),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.activeFilters, 'activeFilters', isEmpty),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having((s) => s.activeFilters, 'activeFilters', isEmpty),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: null,
              typeFilters: null,
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'maintains searchQuery during filter change',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenAnswer((_) async => [mockCards[1]]);
        },
        seed: () => const PokemonCardState(
          searchQuery: 'charizard',
        ),
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(const TypeFilterChanged({'Fire'})),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.searchQuery, 'searchQuery', 'charizard')
              .having((s) => s.activeFilters, 'activeFilters', {'Fire'}),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.success)
              .having((s) => s.searchQuery, 'searchQuery', 'charizard')
              .having((s) => s.activeFilters, 'activeFilters', {'Fire'}),
        ],
        verify: (_) {
          verify(
            () => mockRepository.getCards(
              page: 1,
              pageSize: 20,
              searchQuery: 'charizard',
              typeFilters: {'Fire'},
            ),
          ).called(1);
        },
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'emits [failure] when filter change fails',
        setUp: () {
          when(
            () => mockRepository.getCards(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              searchQuery: any(named: 'searchQuery'),
              typeFilters: any(named: 'typeFilters'),
            ),
          ).thenThrow(Exception('Failed to apply filters'));
        },
        build: () => PokemonCardBloc(pokemonCardRepository: mockRepository),
        act: (bloc) => bloc.add(const TypeFilterChanged({'Fire'})),
        expect: () => [
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.initial)
              .having((s) => s.activeFilters, 'activeFilters', {'Fire'}),
          isA<PokemonCardState>()
              .having((s) => s.status, 'status', PokemonCardStatus.failure),
        ],
      );
    });
  });
}
