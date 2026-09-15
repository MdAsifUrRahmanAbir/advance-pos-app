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
}

/*
 todo Fix — share_plus iPad anchor requirement
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptShareService {
  const ReceiptShareService._();

  static Future<Uint8List> _captureAsPng(GlobalKey boundaryKey, {double pixelRatio = 3}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('ReceiptShareService: no RepaintBoundary found for the given key.');
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('ReceiptShareService: failed to encode receipt image.');
    }
    return byteData.buffer.asUint8List();
  }

  /// [sharePositionOrigin] anchors the share popover on iPad — pass the
  /// share button's on-screen Rect (e.g. via a GlobalKey on the button
  /// itself). Ignored on phone/Android but required for iPad to avoid a
  /// silent no-op share sheet.
  static Future<void> shareReceiptImage({
    required GlobalKey boundaryKey,
    required String saleId,
    Rect? sharePositionOrigin,
  }) async {
    final bytes = await _captureAsPng(boundaryKey);
    final fileName = 'receipt_${saleId.replaceAll('#', '')}.png';
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: fileName, mimeType: 'image/png')],
        subject: 'Receipt $saleId',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}
 */
