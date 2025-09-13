import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/datasources/pokemon_remote_datasource.dart';
import 'data/repositories/pokemon_repository_impl.dart';
import 'domain/repositories/pokemon_repository.dart';
import 'domain/usecases/get_pokemon_list.dart';
import 'domain/entities/cart_item.dart';
import 'presentation/bloc/pokemon/pokemon_bloc.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/bloc/cart/cart_event.dart';
import 'presentation/pages/catalog_page.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CartItemAdapter());
  await Hive.openBox<CartItem>('cartBox');

  await setupDependencies();
  runApp(const MyApp());
}

Future<void> setupDependencies() async {
  // External dependencies
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Data sources
  getIt.registerLazySingleton<PokemonRemoteDataSource>(
    () => PokemonRemoteDataSourceImpl(dio: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetPokemonList(repository: getIt()));

  // BLoCs
  getIt.registerFactory(() => PokemonBloc(getPokemonList: getIt()));
  getIt.registerLazySingleton(() => CartBloc());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<PokemonBloc>()),
        BlocProvider(
          create: (context) => getIt<CartBloc>()..add(const LoadCart()),
        ),
      ],
      child: MaterialApp(
        title: 'Pokemon Cart App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const CatalogPage(),
      ),
    );
  }
}
