import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import '../models/ble_device.dart';

class BleService {
  final SharedPreferences _prefs;

  BluetoothDevice? _connectedDevice;
  final List<BleDevice> _discoveredDevices = [];

  final _isScanning = StreamController<bool>.broadcast();
  final _devicesList = StreamController<List<BleDevice>>.broadcast();
  final _connectedDeviceController = StreamController<BleDevice?>.broadcast();

  static const String _lastDeviceIdKey = 'last_device_id';
  static const String _protoServiceUuid =
      '0000xxxx-0000-1000-8000-00805f9b34fb';

  BleService(this._prefs) {
    _isScanning.add(false);
    initializeBluetooth();

    // Set up subscription to listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      _discoveredDevices.clear();

      for (ScanResult result in results) {
        final device = BleDevice(
          id: result.device.remoteId.str,
          name:
              result.device.platformName.isNotEmpty
                  ? result.device.platformName
                  : 'Unknown Device',
          rssi: result.rssi,
        );

        // Only add if not already in the list
        if (!_discoveredDevices.any((d) => d.id == device.id)) {
          _discoveredDevices.add(device);
        }
      }

      // Sort by RSSI (signal strength)
      _discoveredDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

      _devicesList.add(_discoveredDevices);
    }, onError: (e) => print(e));

    // Listen to scan state changes
    FlutterBluePlus.isScanning.listen((scanning) {
      _isScanning.add(scanning);
    });
  }

  Future<void> initializeBluetooth() async {
    final isSupported = await FlutterBluePlus.isSupported;
    if (!isSupported) {
      print("Bluetooth not supported on this device.");
      return;
    }

    // Request Bluetooth permissions dynamically
    PermissionStatus bluetoothScanStatus =
        await Permission.bluetoothScan.request();
    PermissionStatus bluetoothConnectStatus =
        await Permission.bluetoothConnect.request();
    PermissionStatus locationStatus = await Permission.location.request();

    if (bluetoothScanStatus.isGranted &&
        bluetoothConnectStatus.isGranted &&
        locationStatus.isGranted) {
      // Try to turn it on (Android only)
      if (!kIsWeb && Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }

      FlutterBluePlus.adapterState.listen((state) {
        if (state == BluetoothAdapterState.on) {
          print("Bluetooth works");
        } else if (state == BluetoothAdapterState.off) {
          print("Bluetooth is off!");
        } else if (state == BluetoothAdapterState.unauthorized) {
          print("Bluetooth permissions denied");
        }
      });
    } else {
      print("Required permissions not granted");
    }
  }

  // Getters for Streams
  Stream<bool> get isScanning => _isScanning.stream;
  Stream<List<BleDevice>> get discoveredDevices => _devicesList.stream;
  Stream<BleDevice?> get connectedDevice => _connectedDeviceController.stream;

  Future<void> startScan() async {
    bool isScanning = await FlutterBluePlus.isScanning.first;
    if (isScanning) {
      return;
    }

    _discoveredDevices.clear();
    _devicesList.add(_discoveredDevices);

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BleDevice device) async {
    try {
      final bleDevice = BluetoothDevice.fromId(device.id);
      await bleDevice.connect(autoConnect: false);

      _connectedDevice = bleDevice;
      _connectedDeviceController.add(device);
      await _prefs.setString(_lastDeviceIdKey, device.id);

      // Discover services
      List<BluetoothService> services = await bleDevice.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == _protoServiceUuid) {}
      }
    } catch (e) {
      print('Failed to connect: $e');
      await disconnect();
    }
  }

  Future<void> connectToLastDevice() async {
    final lastDeviceId = _prefs.getString(_lastDeviceIdKey);
    if (lastDeviceId == null) return;

    final List<ScanResult> results = [];

    // Start scanning
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    // Listen to scan results for 5 seconds
    final sub = FlutterBluePlus.scanResults.listen((r) {
      results.addAll(r);
    });

    // Wait for scan duration to complete
    await Future.delayed(const Duration(seconds: 10));
    await FlutterBluePlus.stopScan();
    await sub.cancel();

    final match = results.firstWhereOrNull(
      (r) => r.device.remoteId.str == lastDeviceId,
    );

    if (match != null) {
      await match.device.connect(autoConnect: false);
      _connectedDevice = match.device;
      _connectedDeviceController.add(
        BleDevice(
          id: match.device.remoteId.str,
          name: match.device.platformName,
          rssi: match.rssi,
        ),
      );
    } else {
      print("Device not found in scan results.");
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        print('Error disconnecting: $e');
      }
      _connectedDevice = null;
      _connectedDeviceController.add(null);
    }
  }

  void dispose() {
    _isScanning.close();
    _devicesList.close();
    _connectedDeviceController.close();
  }
}
