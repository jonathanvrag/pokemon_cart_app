import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'pokemon.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 0)
class CartItem extends Equatable {
  @HiveField(0)
  final String pokemonName;

  @HiveField(1)
  final String pokemonUrl;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final double simulatedPrice;

  @HiveField(4)
  final DateTime captureTime;

  @HiveField(5)
  final double? latitude;

  @HiveField(6)
  final double? longitude;

  @HiveField(7)
  final String? locationName;

  const CartItem({
    required this.pokemonName,
    required this.pokemonUrl,
    required this.imageUrl,
    required this.simulatedPrice,
    required this.captureTime,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  factory CartItem.fromPokemon({
    required Pokemon pokemon,
    required double simulatedPrice,
    required DateTime captureTime,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return CartItem(
      pokemonName: pokemon.name,
      pokemonUrl: pokemon.url,
      imageUrl: pokemon.imageUrl,
      simulatedPrice: simulatedPrice,
      captureTime: captureTime,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }

  @override
  List<Object?> get props => [
    pokemonName,
    pokemonUrl,
    imageUrl,
    simulatedPrice,
    captureTime,
    latitude,
    longitude,
    locationName,
  ];
}
