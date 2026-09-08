import 'package:permission_handler/permission_handler.dart';

/// Runtime permission requests for hardware-backed features (Bluetooth
/// printing, camera barcode scan, etc.). Utility-layer, mirrors
/// error_mapper.dart in scope.
class PermissionService {
  const PermissionService._();

  /// Requests Bluetooth scan + connect permissions (Android 12+).
  /// No-op on iOS and Android <12, where these permissions don't exist
  /// in this form — permission_handler returns `granted` automatically
  /// on platforms/versions that don't require the request.
  static Future<bool> requestBluetoothPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  static Future<bool> isBluetoothPermissionPermanentlyDenied() async {
    final scan = await Permission.bluetoothScan.status;
    final connect = await Permission.bluetoothConnect.status;
    return scan.isPermanentlyDenied || connect.isPermanentlyDenied;
  }
}