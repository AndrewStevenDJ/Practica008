import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pokecard_dex/pokemon_cards/data/models/pokemon_card_model.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Registrar adaptadores de Hive
  Hive.registerAdapter(PokemonCardModelAdapter());
  Hive.registerAdapter(CardImagesModelAdapter());
  
  // Abrir la caja de caché
  final box = await Hive.openBox<List<dynamic>>('pokemon_cards_cache');
  
  // Limpiar caché corrupto de la versión anterior
  try {
    print('🧹 Cleaning old cache...');
    await box.clear();
    print('✅ Cache cleared successfully');
  } catch (e) {
    print('⚠️ Error clearing cache: $e');
  }
  
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here

  runApp(await builder());
}
