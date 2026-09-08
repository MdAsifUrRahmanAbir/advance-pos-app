import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  static Future<String?> scan(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen(), fullscreenDialog: true),
    );
  }

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late final MobileScannerController _controller;
  bool _handled = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [
        BarcodeFormat.qrCode,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    _handled = true;
    Navigator.of(context).pop(value);
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _ScannerErrorView(error: error),
          ),
          // Dim overlay with a clear viewfinder cutout in the middle.
          IgnorePointer(
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: _ViewfinderCutoutBorder(),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _CircleIconButton(
                    icon: _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    onTap: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: AppSizes.xxl,
            left: 0,
            right: 0,
            child: Text(
              'Align the barcode within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textWhite, fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Container(
        width: AppSizes.xxl - AppSizes.xs,
        height: AppSizes.xxl - AppSizes.xs,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.textWhite, size: AppSizes.iconMd),
      ),
    );
  }
}

/// Shown by [MobileScanner.errorBuilder] when the camera can't start —
/// most commonly a denied camera permission.
class _ScannerErrorView extends StatelessWidget {
  final MobileScannerException error;

  const _ScannerErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: AppColors.textWhite, size: AppSizes.iconLg * 2),
            const SizedBox(height: AppSizes.md),
            Text(
              error.errorCode == MobileScannerErrorCode.permissionDenied
                  ? 'Camera permission is required to scan barcodes.'
                  : 'Could not start the camera. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textWhite, fontSize: AppSizes.fontMd),
            ),
            const SizedBox(height: AppSizes.lg),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.backToHome, style: TextStyle(color: AppColors.primaryLight)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuts a rounded-rectangle "hole" out of the dim overlay so the camera
/// preview shows through clearly in the scan target area.
class _ViewfinderCutoutBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cutoutSize = rect.width * 0.7;
    final cutout = Rect.fromCenter(center: rect.center, width: cutoutSize, height: cutoutSize);
    return Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(AppSizes.radiusLg)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}