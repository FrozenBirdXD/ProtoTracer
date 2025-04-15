import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ble_service.dart';
import '../models/ble_device.dart';

final bleServiceProvider = Provider<BleService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BleService(prefs);
});

final isScanningProvider = StreamProvider<bool>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.isScanning;
});

final discoveredDevicesProvider = StreamProvider<List<BleDevice>>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.discoveredDevices;
});

final connectedDeviceProvider = StreamProvider<BleDevice?>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.connectedDevice;
});



final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

