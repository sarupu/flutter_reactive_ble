import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

Map<String, String> servicesUuids = {
  '0x1800': 'GAP',
  '0x1801': 'GATT',
  '0x1802': 'Immediate Alert',
  '0x1803': 'Link Loss',
  '0x1804': 'Tx Power',
  '0x1805': 'Current Time',
  '0x1806': 'Reference Time Update',
  '0x1807': 'Next DST Change',
  '0x1808': 'Glucose',
  '0x1809': 'Health Thermometer',
  '0x180A': 'Device Information',
  '0x180D': 'Heart Rate',
  '0x180E': 'Phone Alert Status',
  '0x180F': 'Battery',
  '0x1810': 'Blood Pressure',
  '0x1811': 'Alert Notification',
  '0x1812': 'Human Interface Device',
  '0x1813': 'Scan Parameters',
  '0x1814': 'Running Speed and Cadence',
  '0x1815': 'Automation IO',
  '0x1816': 'Cycling Speed and Cadence',
  '0x1818': 'Cycling Power',
  '0x1819': 'Location and Navigation',
  '0x181A': 'Environmental Sensing',
  '0x181B': 'Body Composition',
  '0x181C': 'User Data',
  '0x181D': 'Weight Scale',
  '0x181E': 'Bond Management',
  '0x181F': 'Continuous Glucose Monitoring',
  '0x1820': 'Internet Protocol Support',
  '0x1821': 'Indoor Positioning',
  '0x1822': 'Pulse Oximeter',
  '0x1823': 'HTTP Proxy',
  '0x1824': 'Transport Discovery',
  '0x1825': 'Object Transfer',
  '0x1826': 'Fitness Machine',
  '0x1827': 'Mesh Provisioning',
  '0x1828': 'Mesh Proxy',
  '0x1829': 'Reconnection Configuration',
  '0x183A': 'Insulin Delivery',
  '0x183B': 'Binary Sensor',
  '0x183C': 'Emergency Configuration',
  '0x183D': 'Authorization Control',
  '0x183E': 'Physical Activity Monitor',
  '0x183F': 'Elapsed Time',
  '0x1840': 'Generic Health Sensor',
  '0x1843': 'Audio Input Control',
  '0x1844': 'Volume Control',
  '0x1845': 'Volume Offset Control',
  '0x1846': 'Coordinated Set Identification',
  '0x1847': 'Device Time',
  '0x1848': 'Media Control',
  '0x1849': 'Generic Media Control',
  '0x184A': 'Constant Tone Extension',
  '0x184B': 'Telephone Bearer',
  '0x184C': 'Generic Telephone Bearer',
  '0x184D': 'Microphone Control',
  '0x184E': 'Audio Stream Control',
  '0x184F': 'Broadcast Audio Scan',
  '0x1850': 'Published Audio Capabilities',
  '0x1851': 'Basic Audio Announcement',
  '0x1852': 'Broadcast Audio Announcement',
  '0x1853': 'Common Audio',
  '0x1854': 'Hearing Access',
  '0x1855': 'Telephony and Media Audio',
  '0x1856': 'Public Broadcast Announcement',
  '0x1857': 'Electronic Shelf Label',
  '0x1858': 'Gaming Audio',
  '0x1859': 'Mesh Proxy Solicitation',
  '0x185A': 'Industrial Measurement Device',
  '0x185B': 'Ranging',
  // Test
  '0xBAAD': 'Safety Mode',
  '0xDEAD': 'Max Speed',
};

String convertTo16BitUUID(Uuid someId) {
  // Define the Bluetooth Base UUID suffix
  final uuid = someId.toString().toUpperCase();
  const bluetoothBaseUUID = '-0000-1000-8000-00805F9B34FB';
  if (uuid.endsWith(bluetoothBaseUUID) && uuid.startsWith('0000')) {
    // Extract the 16-bit UUID part (the `xxxx` part)
    final uuid16 = uuid.substring(4, 8);
    return servicesUuids['0x$uuid16'] ??
        "Unknown Service"; // Add the "0x" prefix
  } else {
    throw ArgumentError('The provided UUID is not convertible to 16-bit.');
  }
}
