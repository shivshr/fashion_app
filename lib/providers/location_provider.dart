import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';

final locationProvider = FutureProvider<String>((ref) async {
  return await LocationService.getFullAddress();
});