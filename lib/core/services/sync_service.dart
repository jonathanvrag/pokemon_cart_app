import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/cart_item.dart';

class SyncService {
  final Dio _dio;
  late Box<CartItem> _cartBox;

  SyncService(this._dio) {
    _cartBox = Hive.box<CartItem>('cartBox');
  }

  Future<SyncResult> syncCart() async {
    try {
      final localItems = _cartBox.values.toList();

      if (localItems.isEmpty) {
        return SyncResult.success(itemsCount: 0);
      }

      final cartData = {
        'items': localItems
            .map(
              (item) => {
                'pokemonName': item.pokemonName,
                'pokemonUrl': item.pokemonUrl,
                'imageUrl': item.imageUrl,
                'price': item.simulatedPrice,
                'captureTime': item.captureTime.toIso8601String(),
                'latitude': item.latitude,
                'longitude': item.longitude,
                'locationName': item.locationName,
              },
            )
            .toList(),
        'syncTime': DateTime.now().toIso8601String(),
        'totalItems': localItems.length,
        'totalPrice': localItems.fold<double>(
          0,
          (sum, item) => sum + item.simulatedPrice,
        ),
      };

      final response = await _simulateServerSync(cartData);

      if (response.isSuccess) {
        return SyncResult.success(itemsCount: localItems.length);
      } else {
        return SyncResult.failure(error: response.error ?? 'Error desconocido');
      }
    } catch (e) {
      if (e is DioException) {
        return SyncResult.failure(error: _handleDioError(e));
      }
      return SyncResult.failure(error: 'Error de sincronización: $e');
    }
  }

  Future<ServerResponse> _simulateServerSync(
    Map<String, dynamic> cartData,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final success = DateTime.now().millisecondsSinceEpoch % 10 != 0;

      if (success) {
        return ServerResponse.success();
      } else {
        return ServerResponse.failure(error: 'Error del servidor simulado');
      }
    } catch (e) {
      return ServerResponse.failure(error: e.toString());
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado';
      case DioExceptionType.sendTimeout:
        return 'Tiempo de envío agotado';
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de recepción agotado';
      case DioExceptionType.connectionError:
        return 'Error de conexión a internet';
      case DioExceptionType.badResponse:
        return 'Error del servidor: ${e.response?.statusCode}';
      default:
        return 'Error de red: ${e.message}';
    }
  }
}

class SyncResult {
  final bool isSuccess;
  final int itemsCount;
  final String? error;

  SyncResult._({required this.isSuccess, required this.itemsCount, this.error});

  factory SyncResult.success({required int itemsCount}) {
    return SyncResult._(isSuccess: true, itemsCount: itemsCount);
  }

  factory SyncResult.failure({required String error}) {
    return SyncResult._(isSuccess: false, itemsCount: 0, error: error);
  }
}

class ServerResponse {
  final bool isSuccess;
  final String? error;

  ServerResponse._({required this.isSuccess, this.error});

  factory ServerResponse.success() {
    return ServerResponse._(isSuccess: true);
  }

  factory ServerResponse.failure({required String error}) {
    return ServerResponse._(isSuccess: false, error: error);
  }
}
