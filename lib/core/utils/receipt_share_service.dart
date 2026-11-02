import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptShareService {
  const ReceiptShareService._();

  static Future<Uint8List> _captureAsPng(
    GlobalKey boundaryKey, {
    double pixelRatio = 3,
  }) async {
    final boundary =
        boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError(
        'ReceiptShareService: no RepaintBoundary found for the given key.',
      );
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('ReceiptShareService: failed to encode receipt image.');
    }
    return byteData.buffer.asUint8List();
  }

  static Future<void> shareReceiptImage({
    required GlobalKey boundaryKey,
    required String saleId,
  }) async {
    final bytes = await _captureAsPng(boundaryKey);
    final fileName = 'receipt_${saleId.replaceAll('#', '')}.png';
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: fileName, mimeType: 'image/png')],
        subject: 'Receipt $saleId',
      ),
    );
  }

  /// Captures the widget under [boundaryKey] (wrapped in a
  /// [RepaintBoundary]) as PNG bytes. Used to print a receipt on a thermal
  /// printer exactly as it is previewed on screen.
  static Future<Uint8List> captureAsPng(
      GlobalKey boundaryKey, {
        double pixelRatio = 3,
      }) => _captureAsPng(boundaryKey, pixelRatio: pixelRatio);
}
