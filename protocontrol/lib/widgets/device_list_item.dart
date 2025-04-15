import 'package:flutter/material.dart';
import '../models/ble_device.dart';

class DeviceListItem extends StatelessWidget {
  final BleDevice device;
  final VoidCallback onTap;

  const DeviceListItem({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          device.name.isNotEmpty ? device.name : 'Unknown Device',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(device.id),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: const Text('Connect'),
        ),
      ),
    );
  }
}