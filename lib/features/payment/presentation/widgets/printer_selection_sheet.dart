import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/permission_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';

/// One-time paired-printer picker. No dedicated printer-setup screen
/// exists yet in Settings — this is a stopgap so printing is usable now.
/// Worth promoting into a proper features/settings/ printer-pairing
/// screen later (with persisted "last used printer" via secure storage).
class PrinterSelectionSheet extends StatefulWidget {
  const PrinterSelectionSheet({super.key});

  @override
  State<PrinterSelectionSheet> createState() => _PrinterSelectionSheetState();
}

class _PrinterSelectionSheetState extends State<PrinterSelectionSheet> {
  bool _isLoading = true;
  bool _permissionDenied = false;
  bool _permissionPermanentlyDenied = false;
  List<BluetoothInfo> _devices = const [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final granted = await PermissionService.requestBluetoothPermissions();
    if (!granted) {
      final permanentlyDenied = await PermissionService.isBluetoothPermissionPermanentlyDenied();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _permissionDenied = true;
        _permissionPermanentlyDenied = permanentlyDenied;
      });
      return;
    }

    final devices = await ThermalPrinterService.scanPairedPrinters();
    if (!mounted) return;
    setState(() {
      _devices = devices;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLg),
          topRight: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectPrinterTitle,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.md),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_permissionDenied)
              _PermissionDeniedNotice(permanentlyDenied: _permissionPermanentlyDenied)
            else if (_devices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.noPrintersFoundMessage,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        AppStrings.pairPrinterHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs),
                      ),
                    ],
                  ),
                )
              else
                ..._devices.map(
                      (device) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.print_outlined, color: AppColors.primary),
                    title: Text(device.name, style: const TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600)),
                    subtitle: Text(device.macAdress, style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary)),
                    onTap: () => Navigator.of(context).pop(device),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _PermissionDeniedNotice extends StatelessWidget {
  final bool permanentlyDenied;
  const _PermissionDeniedNotice({required this.permanentlyDenied});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Column(
        children: [
          const Icon(Icons.bluetooth_disabled_rounded, color: AppColors.error, size: AppSizes.iconLg),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Bluetooth permission is required to find printers.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600),
          ),
          if (permanentlyDenied) ...[
            const SizedBox(height: AppSizes.sm),
            TextButton(
              // TODO: import permission_handler's `openAppSettings()` at
              // the call site once this notice is finalized — deferred
              // here since it's a one-line addition once behavior is
              // confirmed with real hardware.
              onPressed: () {},
              child: const Text('Open App Settings'),
            ),
          ],
        ],
      ),
    );
  }
}