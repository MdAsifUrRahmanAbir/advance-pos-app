import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
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

  static String _fileName(String saleId) =>
      'receipt_${saleId.replaceAll('#', '')}';

  /// Shares the receipt as a PNG through the system share sheet (email,
  /// messaging and social apps). [subject] is used by email apps, [text]
  /// as the message body. [sharePositionOrigin] anchors the share popover
  /// on iPad — pass the tapped button's global rect.
  static Future<void> shareReceiptImage({
    required GlobalKey boundaryKey,
    required String saleId,
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    final bytes = await _captureAsPng(boundaryKey);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            name: '${_fileName(saleId)}.png',
            mimeType: 'image/png',
          ),
        ],
        subject: subject ?? 'Receipt $saleId',
        text: text,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Saves the receipt as a PNG to the device gallery / Photos. Returns
  /// false when the user denies photo access; throws on other failures.
  static Future<bool> saveReceiptImage({
    required GlobalKey boundaryKey,
    required String saleId,
  }) async {
    if (!await Gal.hasAccess() && !await Gal.requestAccess()) return false;
    final bytes = await _captureAsPng(boundaryKey);
    await Gal.putImageBytes(bytes, name: _fileName(saleId));
    return true;
  }

  /// Captures the widget under [boundaryKey] (wrapped in a
  /// [RepaintBoundary]) as PNG bytes. Used to print a receipt on a thermal
  /// printer exactly as it is previewed on screen.
  static Future<Uint8List> captureAsPng(
      GlobalKey boundaryKey, {
        double pixelRatio = 3,
      }) => _captureAsPng(boundaryKey, pixelRatio: pixelRatio);
}