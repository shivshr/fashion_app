import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {

  static Future<String> getFullAddress() async {

    /// Get GPS position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    /// Convert coordinates → address
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;

    final street = place.street;
    final city = place.locality;
    final state = place.administrativeArea;
    final country = place.country;

    /// Remove empty parts to avoid ",,"
    final parts = [
      street,
      city,
      state,
      country,
    ].where((e) => e != null && e.trim().isNotEmpty).toList();

    return parts.join(', ');
  }
}