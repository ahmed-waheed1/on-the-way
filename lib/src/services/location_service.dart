import 'package:fpdart/fpdart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/utils.dart';

/// The device position plus a human-readable address.
class LocationResult {
  const LocationResult({required this.position, required this.address});
  final Position position;
  final String address;
}

/// A service to handle device location requests and status checks.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Robustly resolves the current location + address without ever hanging or
  /// throwing. Checks services, requests permission, times out the GPS fix
  /// (falling back to the last known position), and reverse-geocodes best-effort.
  Future<Either<Failure, LocationResult>> resolveLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return left(const LocationFailure(
          'Location services are off. Please turn on GPS and try again.',
        ));
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return left(const LocationFailure('Location permission was denied.'));
      }
      if (permission == LocationPermission.deniedForever) {
        return left(const LocationFailure(
          'Location permission is permanently denied. Enable it in Settings.',
        ));
      }

      // GPS fix with a hard time limit; fall back to the last known position.
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) {
        return left(const LocationFailure(
          'Could not get your location. Move to an open area and try again.',
        ));
      }

      // Reverse geocode best-effort — never let this fail the whole request.
      var address =
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 8));
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [p.subLocality, p.locality, p.administrativeArea]
              .where((e) => e != null && e.isNotEmpty)
              .map((e) => e!)
              .toList();
          if (parts.isNotEmpty) address = parts.join(', ');
        }
      } catch (_) {
        // keep the lat/lon fallback address
      }

      return right(LocationResult(position: position, address: address));
    } catch (e) {
      return left(LocationFailure(
        'Could not get your location. Please try again.',
        error: e,
      ));
    }
  }

  /// Check the status of location permission.
  FutureEither<LocationPermission> checkPermission() async {
    return runTask(() => Geolocator.checkPermission());
  }

  /// Request location permission.
  FutureEither<LocationPermission> requestPermission() async {
    return runTask(() => Geolocator.requestPermission());
  }

  /// Check if location services are enabled.
  FutureEither<bool> isLocationServiceEnabled() async {
    return runTask(() => Geolocator.isLocationServiceEnabled());
  }

  /// Open the location settings.
  FutureEither<bool> openLocationSettings() async {
    return runTask(() => Geolocator.openLocationSettings());
  }

  /// Get the current position.
  FutureEither<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    return runTask(() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      } 

      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      );
    });
  }

  /// Get the last known position.
  FutureEither<Position?> getLastKnownPosition() async {
    return runTask(() => Geolocator.getLastKnownPosition());
  }

  /// Get a stream of position updates.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 0,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
