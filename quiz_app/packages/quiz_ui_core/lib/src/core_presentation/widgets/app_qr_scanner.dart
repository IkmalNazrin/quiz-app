import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';
import 'glass_card.dart';

class AppQRScanner extends StatefulWidget {
  final void Function(String code) onScan;
  final String title;
  final String instruction;

  const AppQRScanner({
    super.key,
    required this.onScan,
    this.title = 'Scan QR Code',
    this.instruction = 'Align the QR code within the frame',
  });

  @override
  State<AppQRScanner> createState() => _AppQRScannerState();
}

class _AppQRScannerState extends State<AppQRScanner>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isFlashOn = false;
  bool _hasScanned = false; // Prevent multiple scans

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleScan(BarcodeCapture capture) {
    if (_hasScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _hasScanned = true;
        // Provide haptic feedback
        // HapticFeedback.mediumImpact(); // Optional if haptic feedback desirable
        widget.onScan(barcode.rawValue!);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleScan,
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Error: ${error.errorCode}',
                      style: AppTypography.bodyMedium
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enable camera permissions in settings.',
                      style: AppTypography.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),

          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: AppColors.primary,
                borderRadius: 20,
                borderLength: 40,
                borderWidth: 6,
                cutOutSize: 280,
                overlayColor: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ),

          // Scan Line Animation
          Center(
            child: Container(
              width: 260,
              height: 2,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0),
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat()).moveY(
                begin: -130,
                end: 130,
                duration: 2.seconds,
                curve: Curves.easeInOut),
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: const CircleBorder(),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTypography.h3.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFlashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: _isFlashOn ? AppColors.warning : Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFlashOn = !_isFlashOn;
                          _controller.toggleTorch();
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Instruction
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                borderRadius: 30,
                child: Text(
                  widget.instruction,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOut),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the overlay shape to mimic qr_code_scanner styled overlay
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw overlay
    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final cutOutPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            cutOutRect,
            Radius.circular(borderRadius),
          ),
        ),
    );

    canvas.drawPath(cutOutPath, backgroundPaint);

    // Draw corners
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Top left
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top);
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top right
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom right
    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom);
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom left
    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
