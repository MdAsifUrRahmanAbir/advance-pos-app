import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

/// Replaces the system share sheet. Install BEFORE anything touches
/// SharePlus.instance (it captures SharePlatform.instance once).
class FakeSharePlatform extends SharePlatform {
  final List<ShareParams> calls = [];

  /// Thrown by the next share call only.
  Object? nextError;

  @override
  Future<ShareResult> share(ShareParams params) async {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    calls.add(params);
    return const ShareResult('ok', ShareResultStatus.success);
  }
}

/// Mocks the `gal` plugin channel (gal 2.3.3: hasAccess, requestAccess,
/// putImageBytes) so Save never shows a photo-permission dialog.
class GalChannelMock {
  static const _channel = MethodChannel('gal');

  bool hasAccess = true;
  bool grantOnRequest = true;
  final List<String> savedNames = [];
  final List<int> savedByteCounts = [];

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      switch (call.method) {
        case 'hasAccess':
          return hasAccess;
        case 'requestAccess':
          return grantOnRequest;
        case 'putImageBytes':
          final args = call.arguments as Map;
          savedNames.add(args['name'] as String);
          savedByteCounts.add((args['bytes'] as Uint8List).length);
          return null;
      }
      return null;
    });
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}