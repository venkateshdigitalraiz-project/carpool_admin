import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/models/lat_lng.dart';
import '../../domain/entities/route_option.dart';

/// Interactive Multi-Route Google Map Canvas
/// - Renders real Google Maps roadmap tiles
/// - Draws all candidate routes (alternative routes in muted light blue, active route in bold vibrant blue)
/// - Draws custom origin and destination pins matching the screenshot
/// - Supports touch panning, pinch-to-zoom, and auto-fit to route bounds
class RouteMapCanvas extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final String originTitle;
  final String destinationTitle;
  final List<RouteOption> routes;
  final RouteOption? selectedRoute;
  final VoidCallback onBack;

  const RouteMapCanvas({
    super.key,
    required this.origin,
    required this.destination,
    required this.originTitle,
    required this.destinationTitle,
    required this.routes,
    required this.selectedRoute,
    required this.onBack,
  });

  @override
  State<RouteMapCanvas> createState() => _RouteMapCanvasState();
}

class _RouteMapCanvasState extends State<RouteMapCanvas>
    with SingleTickerProviderStateMixin {
  late LatLng _center;
  late double _zoom;
  late double _baseZoom;
  Offset _lastFocalPoint = Offset.zero;

  Size? _lastCalculatedSize;
  bool _hasInitialFit = false;

  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _center = widget.origin;
    _zoom = 8.0;
    _baseZoom = 8.0;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant RouteMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination ||
        oldWidget.routes != widget.routes) {
      if (_lastCalculatedSize != null) {
        _computeFitForSize(_lastCalculatedSize!);
      } else {
        _hasInitialFit = false;
      }
    }
  }

  void _computeFitForSize(Size viewSize) {
    const padding = EdgeInsets.fromLTRB(60, 80, 60, 40);

    final lats = <double>[widget.origin.latitude, widget.destination.latitude];
    final lons = <double>[widget.origin.longitude, widget.destination.longitude];

    for (final r in widget.routes) {
      for (final pt in r.polylinePoints) {
        lats.add(pt.latitude);
        lons.add(pt.longitude);
      }
    }

    final minLat = lats.reduce(math.min);
    final maxLat = lats.reduce(math.max);
    final minLon = lons.reduce(math.min);
    final maxLon = lons.reduce(math.max);

    final availW = math.max(60.0, viewSize.width - padding.left - padding.right);
    final availH = math.max(60.0, viewSize.height - padding.top - padding.bottom);

    var lonDiff = (maxLon - minLon).abs();
    if (lonDiff <= 0.0001) lonDiff = 0.01;
    final wAtZoom0 = (lonDiff / 360.0) * 256.0;
    final zoomX = math.log(availW / wAtZoom0) / math.ln2;

    double mercatorY(double lat) {
      final sinLat = math.sin(lat * math.pi / 180.0).clamp(-0.9999, 0.9999);
      return 0.5 - math.log((1.0 + sinLat) / (1.0 - sinLat)) / (4.0 * math.pi);
    }

    final yTop = mercatorY(maxLat);
    final yBottom = mercatorY(minLat);
    var latDiff = (yBottom - yTop).abs();
    if (latDiff <= 0.00001) latDiff = 0.01;
    final hAtZoom0 = latDiff * 256.0;
    final zoomY = math.log(availH / hAtZoom0) / math.ln2;

    // Use minimum of zoomX and zoomY, with a comfort safety margin of 0.25
    _zoom = (math.min(zoomX, zoomY) - 0.25).clamp(4.5, 14.5);
    _baseZoom = _zoom;

    final rawCenterLat = (minLat + maxLat) / 2.0;
    final rawCenterLon = (minLon + maxLon) / 2.0;

    // Vertical & horizontal offset adjustments for padding
    final dyOffset = (padding.top - padding.bottom) / 2.0;
    final dxOffset = (padding.left - padding.right) / 2.0;

    final centerWorld = _latLngToWorldPixel(rawCenterLat, rawCenterLon, _zoom);
    final adjustedWorld = Offset(centerWorld.dx - dxOffset, centerWorld.dy - dyOffset);
    _center = _worldPixelToLatLng(adjustedWorld.dx, adjustedWorld.dy, _zoom);

    _lastCalculatedSize = viewSize;
    _hasInitialFit = true;
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_animCtrl.isAnimating) _animCtrl.stop();
    _baseZoom = _zoom;
    _lastFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size viewSize) {
    if (_animCtrl.isAnimating) _animCtrl.stop();

    if (details.scale != 1.0) {
      _zoom = (_baseZoom + math.log(details.scale) / math.ln2).clamp(4.0, 16.0);
    }

    final delta = details.focalPoint - _lastFocalPoint;
    _lastFocalPoint = details.focalPoint;

    final worldPixel = _latLngToWorldPixel(
      _center.latitude,
      _center.longitude,
      _zoom,
    );
    final newWorldPixel = worldPixel - delta;
    _center = _worldPixelToLatLng(newWorldPixel.dx, newWorldPixel.dy, _zoom);
    setState(() {});
  }

  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 1.0).clamp(4.0, 16.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 1.0).clamp(4.0, 16.0);
    });
  }

  void _recenter() {
    if (_lastCalculatedSize != null) {
      setState(() {
        _computeFitForSize(_lastCalculatedSize!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (!_hasInitialFit || _lastCalculatedSize != viewSize) {
          _computeFitForSize(viewSize);
        }

        return Stack(
          children: [
            // Interactive Map Surface
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _onScaleStart,
                onScaleUpdate: (d) => _onScaleUpdate(d, viewSize),
                onDoubleTap: _zoomIn,
                child: ClipRect(
                  child: Stack(
                    children: [
                      // Real Google Maps Road Vector Tiles
                      _buildTileLayer(viewSize, _center, _zoom),

                      // Polyline and Marker Overlay Painter
                      CustomPaint(
                        size: viewSize,
                        painter: _RoutePolylinesAndMarkersPainter(
                          center: _center,
                          zoom: _zoom,
                          origin: widget.origin,
                          destination: widget.destination,
                          originTitle: widget.originTitle,
                          destinationTitle: widget.destinationTitle,
                          routes: widget.routes,
                          selectedRouteId: widget.selectedRoute?.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top-left Floating Back Button (matching screenshot)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF007BFF),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Google Logo Watermark at bottom left
            Positioned(
              left: 14,
              bottom: 14,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Google',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF5F6368),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
            ),

            // Floating Zoom / Recenter Controls on Right
            Positioned(
              right: 14,
              bottom: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlBtn(Icons.add, _zoomIn),
                  const SizedBox(height: 6),
                  _buildControlBtn(Icons.remove, _zoomOut),
                  const SizedBox(height: 6),
                  _buildControlBtn(Icons.my_location, _recenter),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withAlpha(240),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: const Color(0xFF0A1E34)),
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

    final visLeft = centerWorld.dx - (halfW / s);
    final visRight = centerWorld.dx + (halfW / s);
    final visTop = centerWorld.dy - (halfH / s);
    final visBottom = centerWorld.dy + (halfH / s);

    final minTileX = (visLeft / 256.0).floor() - 1;
    final maxTileX = (visRight / 256.0).floor() + 1;
    final minTileY = (visTop / 256.0).floor() - 1;
    final maxTileY = (visBottom / 256.0).floor() + 1;

    final maxTileIndex = (1 << z) - 1;
    final tiles = <Widget>[];

    for (int ty = minTileY; ty <= maxTileY; ty++) {
      if (ty < 0 || ty > maxTileIndex) continue;
      for (int tx = minTileX; tx <= maxTileX; tx++) {
        final wrappedTx = ((tx % (maxTileIndex + 1)) + (maxTileIndex + 1)) %
            (maxTileIndex + 1);

        final tileWorldX = tx * 256.0;
        final tileWorldY = ty * 256.0;

        final screenX = halfW + (tileWorldX - centerWorld.dx) * s;
        final screenY = halfH + (tileWorldY - centerWorld.dy) * s;
        final tileSize = 256.0 * s;

        final serverIndex = (tx + ty).abs() % 4;
        final tileUrl =
            'https://mt$serverIndex.google.com/vt/lyrs=m&hl=en&x=$wrappedTx&y=$ty&z=$z';

        tiles.add(
          Positioned(
            left: screenX,
            top: screenY,
            width: tileSize,
            height: tileSize,
            child: Image.network(
              tileUrl,
              fit: BoxFit.fill,
              errorBuilder: (_, _, _) => Container(color: const Color(0xFFE8ECEF)),
            ),
          ),
        );
      }
    }

    return Stack(children: tiles);
  }

  static Offset _latLngToWorldPixel(double lat, double lon, double zoom) {
    final sinLat = math.sin(lat * math.pi / 180.0).clamp(-0.9999, 0.9999);
    final x = ((lon + 180.0) / 360.0) * 256.0 * math.pow(2.0, zoom);
    final y = (0.5 - math.log((1.0 + sinLat) / (1.0 - sinLat)) / (4.0 * math.pi)) *
        256.0 *
        math.pow(2.0, zoom);
    return Offset(x, y);
  }

  static LatLng _worldPixelToLatLng(double x, double y, double zoom) {
    final mapSize = 256.0 * math.pow(2.0, zoom);
    final lon = (x / mapSize) * 360.0 - 180.0;
    final y2 = 0.5 - (y / mapSize);
    final lat = 90.0 - 360.0 * math.atan(math.exp(-y2 * 2.0 * math.pi)) / math.pi;
    return LatLng(lat.clamp(-85.0, 85.0), lon.clamp(-180.0, 180.0));
  }
}

/// Custom Painter for Polyline Routes and Location Pin Markers
class _RoutePolylinesAndMarkersPainter extends CustomPainter {
  final LatLng center;
  final double zoom;
  final LatLng origin;
  final LatLng destination;
  final String originTitle;
  final String destinationTitle;
  final List<RouteOption> routes;
  final String? selectedRouteId;

  _RoutePolylinesAndMarkersPainter({
    required this.center,
    required this.zoom,
    required this.origin,
    required this.destination,
    required this.originTitle,
    required this.destinationTitle,
    required this.routes,
    this.selectedRouteId,
  });

  Offset _toScreen(LatLng pt, Size size) {
    final ptWorld = _RouteMapCanvasState._latLngToWorldPixel(
      pt.latitude,
      pt.longitude,
      zoom,
    );
    final centerWorld = _RouteMapCanvasState._latLngToWorldPixel(
      center.latitude,
      center.longitude,
      zoom,
    );
    return Offset(
      size.width / 2.0 + (ptWorld.dx - centerWorld.dx),
      size.height / 2.0 + (ptWorld.dy - centerWorld.dy),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw alternative (unselected) routes first in soft light blue
    for (final r in routes) {
      if (r.id != selectedRouteId) {
        _drawPolyline(
          canvas,
          size,
          r.polylinePoints,
          color: const Color(0xFF7FAED4), // Soft muted steel blue
          borderOutlineColor: const Color(0xFF4A7B9D),
          strokeWidth: 4.2,
          isBold: false,
        );
      }
    }

    // 2. Draw selected route on top in rich bold vibrant blue
    for (final r in routes) {
      if (r.id == selectedRouteId) {
        _drawPolyline(
          canvas,
          size,
          r.polylinePoints,
          color: const Color(0xFF0070E0), // Vibrant royal blue from screenshot
          borderOutlineColor: const Color(0xFF004494),
          strokeWidth: 6.8,
          isBold: true,
        );
      }
    }

    // 3. Draw Origin Marker (Start) with address badge
    final originScreen = _toScreen(origin, size);
    _drawOriginPin(canvas, originScreen, originTitle, size);

    // 4. Draw Destination Marker (End) with address badge
    final destScreen = _toScreen(destination, size);
    _drawDestinationPin(canvas, destScreen, destinationTitle, size);
  }

  void _drawPolyline(
    Canvas canvas,
    Size size,
    List<LatLng> points, {
    required Color color,
    required Color borderOutlineColor,
    required double strokeWidth,
    required bool isBold,
  }) {
    if (points.length < 2) return;

    final path = Path();
    final first = _toScreen(points.first, size);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < points.length; i++) {
      final cur = _toScreen(points[i], size);
      path.lineTo(cur.dx, cur.dy);
    }

    // Border outline for high contrast
    final outlinePaint = Paint()
      ..color = borderOutlineColor.withAlpha(isBold ? 140 : 80)
      ..strokeWidth = strokeWidth + 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outlinePaint);

    // Main line paint
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  void _drawOriginPin(Canvas canvas, Offset pos, String name, Size size) {
    // Outer shadow
    canvas.drawCircle(
      pos,
      14,
      Paint()
        ..color = Colors.black.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Dark navy outer ring
    canvas.drawCircle(
      pos,
      12,
      Paint()..color = const Color(0xFF0A1E34),
    );

    // Vibrant green/blue ring
    canvas.drawCircle(
      pos,
      10,
      Paint()..color = const Color(0xFF10B981),
    );

    // Center white dot
    canvas.drawCircle(
      pos,
      5,
      Paint()..color = Colors.white,
    );

    // Connected callout pill
    _drawCalloutPill(
      canvas: canvas,
      pinPos: pos,
      tag: 'START',
      tagColor: const Color(0xFF10B981),
      mainText: name,
      size: size,
    );
  }

  void _drawDestinationPin(Canvas canvas, Offset pos, String name, Size size) {
    // Outer shadow
    canvas.drawCircle(
      pos,
      14,
      Paint()
        ..color = Colors.black.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Blue outer ring
    canvas.drawCircle(
      pos,
      12,
      Paint()..color = const Color(0xFF0070E0),
    );

    // White middle circle
    canvas.drawCircle(
      pos,
      9,
      Paint()..color = Colors.white,
    );

    // Inner blue core
    canvas.drawCircle(
      pos,
      5,
      Paint()..color = const Color(0xFF0070E0),
    );

    // Connected callout pill
    _drawCalloutPill(
      canvas: canvas,
      pinPos: pos,
      tag: 'DEST',
      tagColor: const Color(0xFF0070E0),
      mainText: name,
      size: size,
    );
  }

  void _drawCalloutPill({
    required Canvas canvas,
    required Offset pinPos,
    required String tag,
    required Color tagColor,
    required String mainText,
    required Size size,
  }) {
    final cleanName = mainText.split(',').first.trim();
    final displayText = cleanName.isNotEmpty ? cleanName : 'Location';

    final tagSpan = TextSpan(
      text: tag,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9.0,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
    final tagPainter = TextPainter(
      text: tagSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final nameSpan = TextSpan(
      text: displayText,
      style: const TextStyle(
        color: Color(0xFF0A1E34),
        fontSize: 12.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
    final namePainter = TextPainter(
      text: nameSpan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 140);

    const padH = 8.0;
    const padV = 5.0;
    const spacing = 6.0;
    final tagBoxW = tagPainter.width + 8.0;
    final tagBoxH = tagPainter.height + 4.0;
    final pillW = padH + tagBoxW + spacing + namePainter.width + padH;
    final pillH = math.max(tagBoxH, namePainter.height) + (padV * 2.0);

    // Position above pin
    double pillX = pinPos.dx - (pillW / 2.0);
    double pillY = pinPos.dy - pillH - 14.0;

    // Clamp within screen boundaries
    pillX = pillX.clamp(10.0, math.max(10.0, size.width - pillW - 10.0));
    pillY = pillY.clamp(45.0, math.max(45.0, size.height - pillH - 10.0));

    final pillRect = Rect.fromLTWH(pillX, pillY, pillW, pillH);
    final pillRRect = RRect.fromRectAndRadius(pillRect, const Radius.circular(8));

    // Shadow
    canvas.drawRRect(
      pillRRect,
      Paint()
        ..color = Colors.black.withAlpha(45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Pill background
    canvas.drawRRect(
      pillRRect,
      Paint()..color = Colors.white,
    );

    // Pill border
    canvas.drawRRect(
      pillRRect,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Connector line from pill to pin
    canvas.drawLine(
      Offset(pinPos.dx.clamp(pillX + 8, pillX + pillW - 8), pillY + pillH),
      Offset(pinPos.dx, pinPos.dy - 12),
      Paint()
        ..color = const Color(0xFF0A1E34).withAlpha(160)
        ..strokeWidth = 1.5,
    );

    // Tag badge container
    final tagRect = Rect.fromLTWH(
      pillX + padH,
      pillY + (pillH - tagBoxH) / 2.0,
      tagBoxW,
      tagBoxH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tagRect, const Radius.circular(4)),
      Paint()..color = tagColor,
    );
    tagPainter.paint(
      canvas,
      Offset(tagRect.left + 4, tagRect.top + 2),
    );

    // Name text
    namePainter.paint(
      canvas,
      Offset(
        tagRect.right + spacing,
        pillY + (pillH - namePainter.height) / 2.0,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePolylinesAndMarkersPainter old) {
    return old.center != center ||
        old.zoom != zoom ||
        old.selectedRouteId != selectedRouteId ||
        old.routes != routes;
  }
}
