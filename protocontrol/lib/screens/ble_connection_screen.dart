import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ble_provider.dart';
import '../widgets/device_list_item.dart';
import '../models/ble_device.dart';

class BleConnectionScreen extends ConsumerStatefulWidget {
  const BleConnectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BleConnectionScreen> createState() =>
      _BleConnectionScreenState();
}

class _BleConnectionScreenState extends ConsumerState<BleConnectionScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-connect to last device
    Future.microtask(() {
      ref.read(bleServiceProvider).connectToLastDevice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isScanningAsync = ref.watch(isScanningProvider);
    final devicesAsync = ref.watch(discoveredDevicesProvider);
    final connectedDeviceAsync = ref.watch(connectedDeviceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Proto'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          final isScanning = isScanningAsync.value ?? false;
          if (!isScanning) {
            ref.read(bleServiceProvider).startScan();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Connected device section
                    connectedDeviceAsync.maybeWhen(
                      data:
                          (device) =>
                              device != null
                                  ? Card(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.bluetooth_connected,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Connected',
                                                      style: TextStyle(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      device.name.isNotEmpty
                                                          ? device.name
                                                          : device.id,
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  ref
                                                      .read(bleServiceProvider)
                                                      .disconnect();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .errorContainer,
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onErrorContainer,
                                                ),
                                                child: const Text('Disconnect'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          LinearProgressIndicator(
                                            value: 1.0,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  : const SizedBox.shrink(),
                      orElse: () => const SizedBox.shrink(),
                    ),

                    // Scan buttons
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Available Devices',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        isScanningAsync.maybeWhen(
                          data:
                              (isScanning) =>
                                  isScanning
                                      ? ElevatedButton.icon(
                                        onPressed:
                                            () =>
                                                ref
                                                    .read(bleServiceProvider)
                                                    .stopScan(),
                                        icon: const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        label: const Text('Cancel'),
                                      )
                                      : ElevatedButton.icon(
                                        onPressed:
                                            () =>
                                                ref
                                                    .read(bleServiceProvider)
                                                    .startScan(),
                                        icon: const Icon(Icons.search),
                                        label: const Text('Scan'),
                                      ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Device list
            devicesAsync.when(
              data: (devices) {
                if (devices.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('No devices found. Pull down to scan again.'),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final device = devices[index];
                    return DeviceListItem(
                      device: device,
                      onTap:
                          () => ref
                              .read(bleServiceProvider)
                              .connectToDevice(device),
                    );
                  }, childCount: devices.length),
                );
              },
              loading:
                  () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Searching for Protos...'),
                        ],
                      ),
                    ),
                  ),
              error:
                  (err, _) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Error: $err')),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
