// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 0;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      pokemonName: fields[0] as String,
      pokemonUrl: fields[1] as String,
      imageUrl: fields[2] as String,
      simulatedPrice: fields[3] as double,
      captureTime: fields[4] as DateTime,
      latitude: fields[5] as double?,
      longitude: fields[6] as double?,
      locationName: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.pokemonName)
      ..writeByte(1)
      ..write(obj.pokemonUrl)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.simulatedPrice)
      ..writeByte(4)
      ..write(obj.captureTime)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.locationName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
