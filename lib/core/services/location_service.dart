import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<LocationData?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      String locationName = 'Ubicación desconocida';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          locationName =
              "${place.locality ?? 'Ciudad desconocida'}, ${place.country ?? 'País desconocido'}";
        }
      } catch (e) {
        locationName =
            "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, long: $longitude, name: $locationName)';
  }
}
