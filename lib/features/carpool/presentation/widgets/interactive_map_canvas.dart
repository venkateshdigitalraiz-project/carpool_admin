import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../places/data/datasources/geocoding_remote_datasource.dart';

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

/// Fully portable, smooth Google Map display matching Screenshot 3:
/// - Fetches real Google Maps roadmap tiles directly (mt0-mt3.google.com)
/// - Resolves GPS coordinates dynamically via Google & OpenStreetMap geocoding
/// - Completely avoids blank screens caused by Google Cloud Android SDK restrictions
/// - Smooth touch gesture dragging, panning, pinch-to-zoom, and recentering
/// - Fixed center location pin marker matching Screenshot 3
class InteractiveMapCanvas extends StatefulWidget {
  final String locationTitle;
  final String? subtitle;
  final String? nativeTitle;
  final LatLng? initialLatLng;
  final ValueChanged<LatLng>? onLocationChanged;
  final bool isPickup;

  const InteractiveMapCanvas({
    super.key,
    required this.locationTitle,
    this.subtitle,
    this.nativeTitle,
    this.initialLatLng,
    this.onLocationChanged,
    this.isPickup = true,
  });

  @override
  State<InteractiveMapCanvas> createState() => _InteractiveMapCanvasState();
}

class _InteractiveMapCanvasState extends State<InteractiveMapCanvas>
    with SingleTickerProviderStateMixin {
  late LatLng _center;
  late LatLng _initialCenter;
  double _zoom = 12.0;
  double _baseZoom = 12.0;
  Offset _lastFocalPoint = Offset.zero;
  bool _isLoadingCoordinates = false;
  String? _dynamicSubtitle;

  late final AnimationController _animCtrl;
  Animation<double>? _zoomAnimation;
  Animation<LatLng>? _panAnimation;

  @override
  void initState() {
    super.initState();
    _center = widget.initialLatLng ?? const LatLng(16.5062, 80.6480);
    _initialCenter = _center;

    // Optimize image cache for silky smooth map tile panning & zooming
    PaintingBinding.instance.imageCache.maximumSize = 2000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 150 * 1024 * 1024;

    _animCtrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 320),
        )..addListener(() {
          setState(() {});
        });

    _resolveCoordinatesDynamically(widget.locationTitle);
  }

  @override
  void didUpdateWidget(covariant InteractiveMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locationTitle != widget.locationTitle) {
      _resolveCoordinatesDynamically(widget.locationTitle);
    }
  }

  Future<void> _resolveCoordinatesDynamically(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isLoadingCoordinates = true;
    });

    final geocoded = await DynamicGeocodingService.getCoordinates(clean);
    if (!mounted) return;

    if (geocoded != null) {
      final newCenter = LatLng(geocoded.latitude, geocoded.longitude);
      setState(() {
        _center = newCenter;
        _initialCenter = newCenter;
        _isLoadingCoordinates = false;
        if (geocoded.localName != null && geocoded.localName!.isNotEmpty) {
          _dynamicSubtitle = geocoded.localName;
        }
      });

      widget.onLocationChanged?.call(newCenter);
    } else {
      setState(() {
        _isLoadingCoordinates = false;
      });
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_animCtrl.isAnimating) {
      _animCtrl.stop();
    }
    if (_zoomAnimation != null) {
      _zoom = _zoomAnimation!.value;
      _zoomAnimation = null;
    }
    if (_panAnimation != null) {
      _center = _panAnimation!.value;
      _panAnimation = null;
    }
    _baseZoom = _zoom;
    _lastFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (_animCtrl.isAnimating) {
      _animCtrl.stop();
    }

    // 1. Continuous smooth pinch to zoom
    if (details.scale != 1.0) {
      final newZoom = (_baseZoom + math.log(details.scale) / math.ln2).clamp(
        8.0,
        18.0,
      );
      _zoom = newZoom;
    }

    // 2. Smooth single-finger dragging / panning
    final delta = details.focalPoint - _lastFocalPoint;
    _lastFocalPoint = details.focalPoint;

    final worldPixel = _latLngToWorldPixel(
      _center.latitude,
      _center.longitude,
      _zoom,
    );
    final newWorldPixel = worldPixel - delta;
    final newLatLng = _worldPixelToLatLng(
      newWorldPixel.dx,
      newWorldPixel.dy,
      _zoom,
    );

    setState(() {
      _center = newLatLng;
    });
    widget.onLocationChanged?.call(_center);
  }

  void _zoomIn() {
    if (_zoom >= 17.5) return;
    final currentVal = _zoomAnimation != null && _animCtrl.isAnimating
        ? _zoomAnimation!.value
        : _zoom;
    final targetZoom = (currentVal + 1.0).clamp(8.0, 18.0);
    _animateZoom(targetZoom);
  }

  void _zoomOut() {
    if (_zoom <= 8.5) return;
    final currentVal = _zoomAnimation != null && _animCtrl.isAnimating
        ? _zoomAnimation!.value
        : _zoom;
    final targetZoom = (currentVal - 1.0).clamp(8.0, 18.0);
    _animateZoom(targetZoom);
  }

  void _animateZoom(double targetZoom) {
    if (_animCtrl.isAnimating) {
      _animCtrl.stop();
    }
    final startZoom = _zoomAnimation != null ? _zoomAnimation!.value : _zoom;
    _panAnimation = null;
    _zoomAnimation = Tween<double>(
      begin: startZoom,
      end: targetZoom,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _zoom = targetZoom;
          _zoomAnimation = null;
        });
      }
    });
  }

  void _onResetView() {
    if (_animCtrl.isAnimating) {
      _animCtrl.stop();
    }
    final startCenter = _panAnimation != null ? _panAnimation!.value : _center;
    final startZoom = _zoomAnimation != null ? _zoomAnimation!.value : _zoom;

    _panAnimation = LatLngTween(
      begin: startCenter,
      end: _initialCenter,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _zoomAnimation = Tween<double>(
      begin: startZoom,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _center = _initialCenter;
          _zoom = 12.0;
          _panAnimation = null;
          _zoomAnimation = null;
        });
        widget.onLocationChanged?.call(_center);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rawCity = widget.locationTitle.split(',').first.trim();
    final cityName = rawCity.isNotEmpty ? rawCity : 'Vijayawada';
    final subtitleText =
        widget.nativeTitle ?? _dynamicSubtitle ?? widget.subtitle ?? '';

    final currentZoom = _zoomAnimation != null && _animCtrl.isAnimating
        ? _zoomAnimation!.value
        : _zoom;
    final currentCenter = _panAnimation != null && _animCtrl.isAnimating
        ? _panAnimation!.value
        : _center;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // Interactive Smooth Pan & Zoom Google Map Layer
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _onScaleStart,
                onScaleUpdate: (details) => _onScaleUpdate(details, viewSize),
                onDoubleTap: _zoomIn,
                child: ClipRect(
                  child: Stack(
                    children: [
                      // Base fallback vector canvas (behind tiles while loading)
                      Positioned.fill(
                        child: CustomPaint(
                          size: viewSize,
                          painter: _GoogleMapCanvasPainter(
                            centerCity: cityName,
                            nativeScript: subtitleText,
                          ),
                        ),
                      ),

                      // Real Google Maps Road & Satellite Vector Tiles
                      _buildTileLayer(viewSize, currentCenter, currentZoom),
                    ],
                  ),
                ),
              ),
            ),

            // Loading indicator while resolving geocodes
            if (_isLoadingCoordinates)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(220),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),

            // Fixed Location Pin Marker Centered on Screen (no text display)
            Center(
              child: IgnorePointer(
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 50,
                        color: Colors.red,
                      ),
                      Container(
                        width: 6,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(50),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Google Logo Watermark at bottom left
            Positioned(
              left: 14,
              bottom: 24,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(190),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Google',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF5F6368),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),

            // Floating Zoom and Recenter Controls on Right Side (aligned above the action button)
            Positioned(
              right: 20,
              bottom: 94,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlBtn(Icons.add, 'Zoom in', _zoomIn),
                  const SizedBox(height: 6),
                  _buildControlBtn(Icons.remove, 'Zoom out', _zoomOut),
                  const SizedBox(height: 6),
                  _buildControlBtn(Icons.my_location, 'Recenter', _onResetView),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: const Color(0xFF0A1E34)),
        ),
      ),
    );
  }

  Widget _buildTileLayer(Size viewSize, LatLng center, double zoom) {
    final int z = zoom.floor();
    final double s = math.pow(2.0, zoom - z).toDouble();

    final centerWorld = _latLngToWorldPixel(
      center.latitude,
      center.longitude,
      z.toDouble(),
    );
    final halfW = viewSize.width / 2.0;
    final halfH = viewSize.height / 2.0;

    // Viewport bounds in base zoom z coordinate space
    final visLeft = centerWorld.dx - (halfW / s);
    final visRight = centerWorld.dx + (halfW / s);
    final visTop = centerWorld.dy - (halfH / s);
    final visBottom = centerWorld.dy + (halfH / s);

    // Load with 1-tile buffer on all sides for silky smooth panning & zooming
    final minTileX = (visLeft / 256.0).floor() - 1;
    final maxTileX = (visRight / 256.0).floor() + 1;
    final minTileY = (visTop / 256.0).floor() - 1;
    final maxTileY = (visBottom / 256.0).floor() + 1;

    final maxCoord = (1 << z) - 1;
    final tileSize = 256.0 * s;
    final List<Widget> tileWidgets = [];

    for (int tx = minTileX; tx <= maxTileX; tx++) {
      for (int ty = minTileY; ty <= maxTileY; ty++) {
        if (ty < 0 || ty > maxCoord) continue;
        final wrappedTx =
            ((tx % (maxCoord + 1)) + (maxCoord + 1)) % (maxCoord + 1);

        // Continuous fractional subpixel placement
        final screenLeft = halfW + (tx * 256.0 - centerWorld.dx) * s;
        final screenTop = halfH + (ty * 256.0 - centerWorld.dy) * s;

        final serverIndex = (wrappedTx + ty).abs() % 4;
        final tileUrl =
            'https://mt$serverIndex.google.com/vt/lyrs=m&scale=2&hl=en&x=$wrappedTx&y=$ty&z=$z';

        tileWidgets.add(
          Positioned(
            key: ValueKey('tile_${z}_${wrappedTx}_$ty'),
            left: screenLeft,
            top: screenTop,
            width: tileSize,
            height: tileSize,
            child: Image.network(
              tileUrl,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
              cacheWidth: 512,
              cacheHeight: 512,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        );
      }
    }

    return Stack(children: tileWidgets);
  }

  static Offset _latLngToWorldPixel(double lat, double lng, double zoom) {
    final n = math.pow(2.0, zoom).toDouble();
    final x = (lng + 180.0) / 360.0 * 256.0 * n;
    final latRad = lat * math.pi / 180.0;
    final sinLat = math.sin(latRad).clamp(-0.9999, 0.9999);
    final y =
        (1.0 - math.log((1.0 + sinLat) / (1.0 - sinLat)) / (2.0 * math.pi)) /
        2.0 *
        256.0 *
        n;
    return Offset(x, y);
  }

  static LatLng _worldPixelToLatLng(double px, double py, double zoom) {
    final n = math.pow(2.0, zoom).toDouble();
    final lng = px / (256.0 * n) * 360.0 - 180.0;
    final yNormalized = 1.0 - 2.0 * py / (256.0 * n);
    final sinhVal = _sinh(math.pi * yNormalized);
    final latRad = math.atan(sinhVal);
    final lat = latRad * 180.0 / math.pi;
    return LatLng(lat, lng);
  }

  static double _sinh(double x) {
    return (math.exp(x) - math.exp(-x)) / 2.0;
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
    : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    final lat = begin!.latitude + (end!.latitude - begin!.latitude) * t;
    final lng = begin!.longitude + (end!.longitude - begin!.longitude) * t;
    return LatLng(lat, lng);
  }
}

/// Base Google Maps vector canvas (serves as beautiful base canvas & offline fallback)
class _GoogleMapCanvasPainter extends CustomPainter {
  final String centerCity;
  final String nativeScript;

  _GoogleMapCanvasPainter({
    required this.centerCity,
    required this.nativeScript,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Warm Google Maps canvas background (#F9F6EE)
    final bgPaint = Paint()..color = const Color(0xFFF9F6EE);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // 2. Minor secondary streets
    final streetBorder = Paint()
      ..color = const Color(0xFFECE7DE)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (double i = -100; i < w + 200; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i + 120, h), streetBorder);
      canvas.drawLine(Offset(i, 0), Offset(i + 120, h), streetPaint);
    }
    for (double j = -100; j < h + 200; j += 75) {
      canvas.drawLine(Offset(0, j), Offset(w, j + 50), streetBorder);
      canvas.drawLine(Offset(0, j), Offset(w, j + 50), streetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoogleMapCanvasPainter oldDelegate) {
    return oldDelegate.centerCity != centerCity;
  }
}
