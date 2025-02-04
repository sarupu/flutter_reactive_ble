import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/utils/uuid_converter.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import 'characteristic_interaction_dialog.dart';

part 'device_interaction_tab.g.dart';

// ignore_for_file: annotate_overrides

class DeviceInteractionTab extends StatelessWidget {
  const DeviceInteractionTab({
    required this.device,
    Key? key,
  }) : super(key: key);

  final DiscoveredDevice device;

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleDeviceConnector, ConnectionStateUpdate, BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
                __) =>
            _DeviceInteractionTab(
          viewModel: DeviceInteractionViewModel(
            deviceId: device.id,
            connectableStatus: device.connectable,
            connectionStatus: connectionStateUpdate.connectionState,
            deviceConnector: deviceConnector,
            discoverServices: () =>
                serviceDiscoverer.discoverServices(device.id),
            readRssi: () => serviceDiscoverer.readRssi(device.id),
          ),
        ),
      );
}

@immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.connectableStatus,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
    required this.readRssi,
  });

  final String deviceId;
  final Connectable connectableStatus;
  final DeviceConnectionState connectionStatus;
  final BleDeviceConnector deviceConnector;
  final Future<int> Function() readRssi;

  @CustomEquality(Ignore())
  final Future<List<Service>> Function() discoverServices;

  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  // Future<void> connect() async {
  //   await deviceConnector.connect(deviceId);
  //   // print(discoveredServices)
  //   if (deviceConnected) {
  //     await discoverServices();
  //   }
  // }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class _DeviceInteractionTab extends StatefulWidget {
  const _DeviceInteractionTab({
    required this.viewModel,
    Key? key,
  }) : super(key: key);

  final DeviceInteractionViewModel viewModel;

  @override
  _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
}

class _DeviceInteractionTabState extends State<_DeviceInteractionTab> {
  late List<Service> discoveredServices;

  // int _rssi = 0;

  bool _isServiceMode = false;

  @override
  void initState() {
    discoveredServices = [];
    super.initState();
  }

  Future<void> connect() async {
    await widget.viewModel.deviceConnector.connect(widget.viewModel.deviceId);
    final result = await widget.viewModel.discoverServices();
    setState(() {
      discoveredServices = result;
    });
  }

  // Future<void> readRssi() async {
  //   final rssi = await widget.viewModel.readRssi();
  //   setState(() {
  //     _rssi = rssi;
  //   });
  // }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                // Padding(
                //   padding: const EdgeInsetsDirectional.only(
                //       top: 8.0, bottom: 16.0, start: 16.0),
                //   child: Text(
                //     "ID: ${widget.viewModel.deviceId}",
                //     style: const TextStyle(fontWeight: FontWeight.bold),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsetsDirectional.only(start: 16.0),
                //   child: Text(
                //     "Connectable: ${widget.viewModel.connectableStatus}",
                //     style: const TextStyle(fontWeight: FontWeight.bold),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsetsDirectional.only(start: 16.0),
                //   child: Text(
                //     "Connection: ${widget.viewModel.connectionStatus}",
                //     style: const TextStyle(fontWeight: FontWeight.bold),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsetsDirectional.only(start: 16.0),
                //   child: Text(
                //     "Rssi: $_rssi dB",
                //     style: const TextStyle(fontWeight: FontWeight.bold),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed:
                            !widget.viewModel.deviceConnected ? connect : null,
                        child: const Text("Connect"),
                      ),
                      ElevatedButton(
                        onPressed: widget.viewModel.deviceConnected
                            ? widget.viewModel.disconnect
                            : null,
                        child: const Text("Disconnect"),
                      ),
                      // ElevatedButton(
                      //   onPressed: widget.viewModel.deviceConnected
                      //       ? discoverServices
                      //       : null,
                      //   child: const Text("Discover Services"),
                      // ),
                      Container(
                        child: Row(
                          children: [
                            const Text("Service Mode:",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Switch(
                              value: _isServiceMode,
                              onChanged: (newValue) {
                                setState(() {
                                  _isServiceMode = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                      // ElevatedButton(
                      //   onPressed:
                      //       widget.viewModel.deviceConnected ? readRssi : null,
                      //   child: const Text("Get RSSI"),
                      // ),
                    ],
                  ),
                ),
                if (widget.viewModel.deviceConnected)
                  _ServiceDiscoveryList(
                    isServiceMode: _isServiceMode,
                    deviceId: widget.viewModel.deviceId,
                    discoveredServices: discoveredServices,
                  ),
              ],
            ),
          ),
        ],
      );
}

class _ServiceDiscoveryList extends StatefulWidget {
  const _ServiceDiscoveryList({
    required this.isServiceMode,
    required this.deviceId,
    required this.discoveredServices,
    Key? key,
  }) : super(key: key);

  final bool isServiceMode;
  final String deviceId;
  final List<Service> discoveredServices;

  @override
  _ServiceDiscoveryListState createState() => _ServiceDiscoveryListState();
}

class _ServiceDiscoveryListState extends State<_ServiceDiscoveryList> {
  // late final List<int> _expandedItems;

  @override
  void initState() {
    // _expandedItems = [];
    super.initState();
  }

  // String _characteristicSummary(Characteristic c) {
  //   final props = <String>[];
  //   if (c.isReadable) {
  //     props.add("read");
  //   }
  //   if (c.isWritableWithoutResponse) {
  //     props.add("write without response");
  //   }
  //   if (c.isWritableWithResponse) {
  //     props.add("write with response");
  //   }
  //   if (c.isNotifiable) {
  //     props.add("notify");
  //   }
  //   if (c.isIndicatable) {
  //     props.add("indicate");
  //   }

  //   return props.join("\n");
  // }

  // Widget _characteristicTile(Characteristic characteristic) => ListTile(
  //       onTap: () => showDialog<void>(
  //         context: context,
  //         builder: (context) => CharacteristicInteractionDialog(
  //           characteristic: characteristic,
  //           key: UniqueKey(),
  //         ),
  //       ),
  //       title: Text(
  //         '${characteristic.id}\n(${_characteristicSummary(characteristic)})',
  //         style: const TextStyle(
  //           fontSize: 14,
  //         ),
  //       ),
  //     );

  List<Widget> buildWidgets() {
    final characteristics = widget.isServiceMode
        ? widget.discoveredServices
            .singleWhere((service) =>
                service.id.toString() == "e38a1810-f738-491c-ac4a-83357266cf10")
            .characteristics
        : widget.discoveredServices
            .singleWhere((service) =>
                service.id.toString() == "9615bb5a-f40c-47b5-9556-2c90c724e57c")
            .characteristics;

    return characteristics.map(_buildServiceDataRow).toList();
  }

  Widget _buildServiceDataRow(Characteristic c) => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                '${convertTo16BitUUID(c.id)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FutureBuilder<String>(
                  future: _readCharacteristic(c).timeout(
                    const Duration(milliseconds: 150),
                    onTimeout: () => _readCharacteristic(c, retryCount: 1),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return Text(snapshot.data!);
                    } else {
                      return const Text('No data');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Future<String> _readCharacteristic(Characteristic c,
      {int retryCount = 0}) async {
    try {
      final value = await c.read().timeout(
        const Duration(milliseconds: 150),
        onTimeout: () async {
          if (retryCount < 3) {
            return c.read();
          } else {
            throw TimeoutException('Read characteristic timed out');
          }
        },
      );

      if (c.id.toString() == "9615bb5a-f40c-47b5-9556-2c90c724e571") {
        // Convert hexadecimal to decimal
        final epoch = int.parse(
            value.reversed.map((e) => e.toRadixString(16)).join(),
            radix: 16);
        // Convert epoch to Unix time
        final dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
        print(value);
        print(epoch);
        return dateTime.toString();
      } else {
        // Default to utf8.decode
        return utf8.decode(value);
      }
    } catch (e) {
      if (retryCount < 3) {
        return _readCharacteristic(c, retryCount: retryCount + 1);
      } else {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.discoveredServices.isEmpty
      ? const SizedBox()
      : SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 20.0,
              start: 20.0,
              end: 20.0,
            ),
            child: Column(
              children: buildWidgets(),
            ),
          ),
        );
}

// class UserVehicleDataDisplay extends StatefulWidget {
//   const UserVehicleDataDisplay({super.key});

//   @override
//   State<UserVehicleDataDisplay> createState() => _UserVehicleDataDisplayState();
// }

// class _UserVehicleDataDisplayState extends State<UserVehicleDataDisplay> {
//   Future<String> _fetchData(String dataType) async {
//     await Future<void>.delayed(Durations.long2);
//     switch (dataType) {
//       case 'clock':
//         return DateTime.now().toString().substring(11, 19);
//       case 'date':
//         return DateTime.now().toString().substring(0, 10);
//       case 'odometer':
//         return '${Random().nextInt(4801) + 150} Km';
//       case 'trip':
//         return '${Random().nextInt(150)} Km';
//       case 'warnings':
//         return (DateTime.now().millisecond % 2 == 0) ? "OK" : "Yağ Kontrolü";
//       case 'nextMaintenance':
//         return DateTime.now()
//             .add(const Duration(days: 4))
//             .toString()
//             .substring(0, 10);
//       case 'speed':
//         return '40 km/h';
//       case 'batteryA':
//         return '64%';
//       case 'batteryB':
//         return '100%';
//       default:
//         return 'Bilinmeyen';
//     }
//   }

//   Widget _buildUserDataRow(String label, Future<String> dataFuture) =>
//       Container(
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: Colors.blue,
//             width: 2.0,
//           ),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         margin: const EdgeInsets.only(bottom: 5),
//         padding: const EdgeInsets.all(8.0),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Row(
//             children: [
//               Text(
//                 '$label:',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: FutureBuilder<String>(
//                   future: dataFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const LinearProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else if (snapshot.hasData) {
//                       return Text(snapshot.data!);
//                     } else {
//                       return const Text('No data');
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildUserDataRow('Saat', _fetchData('clock')),
//             _buildUserDataRow('Tarih', _fetchData('date')),
//             _buildUserDataRow('Odometre km', _fetchData('odometer')),
//             _buildUserDataRow('Tripmetre km', _fetchData('trip')),
//             _buildUserDataRow('Uyarılar', _fetchData('warnings')),
//             _buildUserDataRow(
//                 'Bir sonraki bakım zamanı', _fetchData('nextMaintenance')),
//             _buildUserDataRow('Motorun anlık hızı', _fetchData('speed')),
//             _buildUserDataRow('Batarya A', _fetchData('batteryA')),
//             _buildUserDataRow('Batarya B', _fetchData('batteryB')),
//           ],
//         ),
//       );
// }

// class ServiceVehicleDataDisplay extends StatefulWidget {
//   const ServiceVehicleDataDisplay({super.key});

//   @override
//   State<ServiceVehicleDataDisplay> createState() =>
//       _ServiceVehicleDataDisplayState();
// }

// class _ServiceVehicleDataDisplayState extends State<ServiceVehicleDataDisplay> {
//   Future<String> _fetchData(String dataType) async {
//     await Future<void>.delayed(Durations.long2);
//     switch (dataType) {
//       case 'bluetooth':
//         return 'OK';
//       case 'battery_voltage_a':
//         return '${Random().nextInt(100)}%';
//       case 'battery_voltage_b':
//         return '${Random().nextInt(100)}%';
//       case 'current_reading':
//         return '64 A';
//       case 'converter_voltage':
//         return '700 V';
//       case 'mib_temperatures':
//         return 'M: 112 C, I: 30 C, B: 52 C';
//       case 'brake_indicator':
//         return 'OK';
//       case 'throttle_position':
//         return '6 ∠';
//       case 'self_diagnostic':
//         return 'OK';
//       default:
//         return 'Bilinmeyen';
//     }
//   }

//   Widget _buildServiceDataRow(String label, Future<String> dataFuture) =>
//       Container(
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: Colors.blue,
//             width: 2.0,
//           ),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         margin: const EdgeInsets.only(bottom: 5),
//         padding: const EdgeInsets.all(8.0),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Row(
//             children: [
//               Text(
//                 '$label:',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: FutureBuilder<String>(
//                   future: dataFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const LinearProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else if (snapshot.hasData) {
//                       return Text(snapshot.data!);
//                     } else {
//                       return const Text('No data');
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildServiceDataRow('Bluetooth', _fetchData('bluetooth')),
//             _buildServiceDataRow(
//                 'Battery Voltage A', _fetchData('battery_voltage_a')),
//             _buildServiceDataRow(
//                 'Battery Voltage B', _fetchData('battery_voltage_b')),
//             _buildServiceDataRow(
//                 'Current Reading', _fetchData('current_reading')),
//             _buildServiceDataRow(
//                 'AC/DC Converter Voltage', _fetchData('converter_voltage')),
//             _buildServiceDataRow(
//                 'MIB Temperatures', _fetchData('mib_temperatures')),
//             _buildServiceDataRow(
//                 'Brake Indicator', _fetchData('brake_indicator')),
//             _buildServiceDataRow(
//                 'Throttle Position', _fetchData('throttle_position')),
//             _buildServiceDataRow(
//                 'Self Diagnostic', _fetchData('self_diagnostic')),
//           ],
//         ),
//       );
// }
