import 'package:go_router/go_router.dart';
import 'package:pokecard_dex/pokemon_cards/detail/view/card_detail_page.dart';
import 'package:pokecard_dex/pokemon_cards/view/cards_page.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CardsPage(),
    ),
    GoRoute(
      path: '/card/:id',
      builder: (context, state) {
        final cardId = state.pathParameters['id']!;
        return CardDetailPage(cardId: cardId);
      },
    ),
  ],
);
