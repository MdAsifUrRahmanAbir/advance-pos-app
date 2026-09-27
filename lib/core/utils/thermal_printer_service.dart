import 'dart:typed_data';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../features/payment/presentation/states/payment_state.dart';

class ThermalPrinterService {
  const ThermalPrinterService._();

  static Future<List<BluetoothInfo>> scanPairedPrinters() async {
    final isSupported = await PrintBluetoothThermal.bluetoothEnabled;
    if (!isSupported) return [];
    return PrintBluetoothThermal.pairedBluetooths;
  }

  static Future<bool> connect(String macAddress) {
    return PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  static Future<bool> isConnected() {
    return PrintBluetoothThermal.connectionStatus;
  }

  static Future<void> disconnect() {
    return PrintBluetoothThermal.disconnect;
  }

  static Future<bool> printReceipt({
    required String storeName,
    required String saleId,
    required String saleDate,
    required String methodLabel,
    required List<ReceiptLineItem> items,
    required double total,
    required double givenAmount,
    required double changeDue,
  }) async {
    final bytes = await _buildReceiptBytes(
      storeName: storeName,
      saleId: saleId,
      saleDate: saleDate,
      methodLabel: methodLabel,
      items: items,
      total: total,
      givenAmount: givenAmount,
      changeDue: changeDue,
    );
    return PrintBluetoothThermal.writeBytes(bytes);
  }

  static Future<Uint8List> _buildReceiptBytes({
    required String storeName,
    required String saleId,
    required String saleDate,
    required String methodLabel,
    required List<ReceiptLineItem> items,
    required double total,
    required double givenAmount,
    required double changeDue,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    bytes.addAll(
      generator.text(
        storeName,
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
      ),
    );
    bytes.addAll(generator.text(saleDate, styles: const PosStyles(align: PosAlign.center)));
    bytes.addAll(generator.hr());

    bytes.addAll(generator.text('Sale ID: $saleId'));
    bytes.addAll(generator.text('Payment: $methodLabel'));
    bytes.addAll(generator.hr());

    for (final item in items) {
      bytes.addAll(
        generator.row([
          PosColumn(text: '${item.quantity}x ${item.name}', width: 8),
          PosColumn(text: item.lineTotal.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]),
      );
    }
    bytes.addAll(generator.hr());

    bytes.addAll(
      generator.row([
        PosColumn(text: 'Total', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(text: total.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]),
    );
    bytes.addAll(
      generator.row([
        PosColumn(text: 'Given', width: 8),
        PosColumn(text: givenAmount.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]),
    );
    bytes.addAll(
      generator.row([
        PosColumn(text: 'Change', width: 8),
        PosColumn(text: changeDue.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]),
    );

    bytes.addAll(generator.hr());
    bytes.addAll(generator.text('Thank you for your purchase!', styles: const PosStyles(align: PosAlign.center)));
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    return Uint8List.fromList(bytes);
  }
}