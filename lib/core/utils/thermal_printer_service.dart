import 'dart:typed_data';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:image/image.dart' as img;

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
    // required String saleId,
    required String saleDate,
    required String methodLabel,
    required List<ReceiptLineItem> items,
    required double total,
    required double givenAmount,
    required double changeDue,
    String? billNo,
    double? subtotal,
    double? discount,
    double? vat,
    List<ReceiptLineItem>? returnedItems,
    String returnedHeading = 'Returned',
    String itemsHeading = 'Replacement',
    String discountLabel = 'Discount',
  }) async {
    final bytes = await _buildReceiptBytes(
      storeName: storeName,
      // saleId: saleId,
      saleDate: saleDate,
      methodLabel: methodLabel,
      items: items,
      total: total,
      givenAmount: givenAmount,
      changeDue: changeDue,
      billNo: billNo,
      subtotal: subtotal,
      discount: discount,
      vat: vat,
      returnedItems: returnedItems,
      returnedHeading: returnedHeading,
      itemsHeading: itemsHeading,
      discountLabel: discountLabel,
    );
    return PrintBluetoothThermal.writeBytes(bytes);
  }

  static Future<Uint8List> _buildReceiptBytes({
    required String storeName,
    // required String saleId,
    required String saleDate,
    required String methodLabel,
    required List<ReceiptLineItem> items,
    required double total,
    required double givenAmount,
    required double changeDue,
    String? billNo,
    double? subtotal,
    double? discount,
    double? vat,
    List<ReceiptLineItem>? returnedItems,
    String returnedHeading = 'Returned',
    String itemsHeading = 'Replacement',
    String discountLabel = 'Discount',
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

    // bytes.addAll(generator.text('Sale ID: $saleId'));
    if (billNo != null && billNo.isNotEmpty) {
      bytes.addAll(generator.text('Bill No: $billNo', styles: const PosStyles(bold: true)));
    }
    bytes.addAll(generator.text('Payment: $methodLabel'));
    bytes.addAll(generator.hr());

    void itemRows(List<ReceiptLineItem> rows, {bool negative = false}) {
      for (final item in rows) {
        bytes.addAll(
          generator.row([
            PosColumn(text: '${item.quantity}x ${item.name}', width: 8),
            PosColumn(
              text: (negative ? -item.lineTotal : item.lineTotal).toStringAsFixed(2),
              width: 4,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]),
        );
      }
    }

    // Replacement receipts print the returned products first, as credits.
    if (returnedItems != null && returnedItems.isNotEmpty) {
      bytes.addAll(generator.text(returnedHeading, styles: const PosStyles(bold: true)));
      itemRows(returnedItems, negative: true);
      bytes.addAll(generator.hr());
      bytes.addAll(generator.text(itemsHeading, styles: const PosStyles(bold: true)));
    }
    itemRows(items);
    bytes.addAll(generator.hr());

    // Optional breakdown — printed only when the caller provides it.
    void amountRow(String label, double? value) {
      if (value == null) return;
      bytes.addAll(
        generator.row([
          PosColumn(text: label, width: 8),
          PosColumn(text: value.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]),
      );
    }

    amountRow('Subtotal', subtotal);
    if (discount != null && discount > 0) amountRow(discountLabel, -discount);
    if (vat != null && vat > 0) amountRow('VAT', vat);

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

  /// Blank lines fed after an image receipt so the cut clears the text.
  static const int _imageTailFeedLines = 2;
  /// Prints a pre-rendered receipt image (for example a widget captured
  /// with `ReceiptShareService.captureAsPng`) so the paper matches the
  /// on-screen preview exactly. The image is scaled to the printable width
  /// of [paperSize] before it is rasterized.
  static Future<bool> printImage(
      Uint8List pngBytes, {
        PaperSize paperSize = PaperSize.mm58,
      }) async {
    final bytes = await _buildImageBytes(pngBytes, paperSize);
    return PrintBluetoothThermal.writeBytes(bytes);
  }

  static Future<Uint8List> _buildImageBytes(
      Uint8List pngBytes,
      PaperSize paperSize,
      ) async {
    final decoded = img.decodeImage(pngBytes);
    if (decoded == null) {
      throw StateError('ThermalPrinterService: could not decode receipt image.');
    }
    final fitted = img.copyResize(
      decoded,
      width: paperSize.width,
      interpolation: img.Interpolation.average,
    );
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    return Uint8List.fromList([
      ...generator.reset(),
      ...generator.imageRaster(fitted),
      ...generator.feed(_imageTailFeedLines),
      ...generator.cut(),
    ]);
  }
}