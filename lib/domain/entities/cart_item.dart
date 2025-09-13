import 'package:equatable/equatable.dart';
import 'pokemon.dart';

class CartItem extends Equatable {
  final Pokemon pokemon;
  final double simulatedPrice;
  final DateTime captureTime;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const CartItem({
    required this.pokemon,
    required this.simulatedPrice,
    required this.captureTime,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  CartItem copyWith({
    Pokemon? pokemon,
    double? simulatedPrice,
    DateTime? captureTime,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return CartItem(
      pokemon: pokemon ?? this.pokemon,
      simulatedPrice: simulatedPrice ?? this.simulatedPrice,
      captureTime: captureTime ?? this.captureTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  List<Object?> get props => [
    pokemon,
    simulatedPrice,
    captureTime,
    latitude,
    longitude,
    locationName,
  ];
}
