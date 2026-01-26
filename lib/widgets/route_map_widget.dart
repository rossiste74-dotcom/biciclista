import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Widget for displaying a GPX route on an interactive map
class RouteMapWidget extends StatefulWidget {
  /// List of all route points (lat/lng pairs)
  final List<Map<String, double>> routePoints;

  /// Starting point coordinates
  final LatLng? startPoint;

  /// Middle point coordinates
  final LatLng? middlePoint;

  /// Ending point coordinates
  final LatLng? endPoint;

  /// Distance in kilometers (for info overlay)
  final double? distance;

  /// Elevation gain in meters (for info overlay)
  final double? elevation;

  /// Extra markers to display (e.g., weather points)
  final List<Marker>? additionalMarkers;

  const RouteMapWidget({
    super.key,
    required this.routePoints,
    this.startPoint,
    this.middlePoint,
    this.endPoint,
    this.distance,
    this.elevation,
    this.additionalMarkers,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    // Convert route points to LatLng
    final routeLatLngs = widget.routePoints
        .map((point) => LatLng(point['lat']!, point['lng']!))
        .toList();

    if (routeLatLngs.isEmpty) {
      return Container(
        color: Colors.grey[100],
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Nessuna traccia GPS disponibile',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate bounds to center the map
    final bounds = _calculateBounds(routeLatLngs);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCameraFit: bounds != null
                ? CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(50),
                  )
                : routeLatLngs.isNotEmpty
                    ? CameraFit.coordinates(
                        coordinates: routeLatLngs,
                        padding: const EdgeInsets.all(50),
                      )
                    : CameraFit.bounds(
                        bounds: LatLngBounds(
                          widget.middlePoint ?? const LatLng(45.4642, 9.1900),
                          widget.middlePoint ?? const LatLng(45.4642, 9.1900),
                        ),
                        padding: const EdgeInsets.all(50),
                      ),
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.biciclistico.app',
              maxZoom: 19,
            ),
            // Route polyline
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routeLatLngs,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              ],
            ),
            // Markers for start, middle, end
            MarkerLayer(
              markers: _buildMarkers(),
            ),
          ],
        ),
        // Info overlay
        if (widget.distance != null || widget.elevation != null)
          Positioned(
            top: 16,
            right: 16,
            child: _buildInfoCard(),
          ),
        // Attribution
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '© OpenStreetMap contributors',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  /// Build markers for start, middle, and end points
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (widget.startPoint != null) {
      markers.add(
        Marker(
          point: widget.startPoint!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.play_circle,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    }

    if (widget.middlePoint != null) {
      markers.add(
        Marker(
          point: widget.middlePoint!,
          width: 30,
          height: 30,
          child: const Icon(
            Icons.circle,
            color: Colors.blue,
            size: 30,
          ),
        ),
      );
    }

    if (widget.endPoint != null) {
      markers.add(
        Marker(
          point: widget.endPoint!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.flag,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }

    if (widget.additionalMarkers != null) {
      markers.addAll(widget.additionalMarkers!);
    }

    return markers;
  }

  /// Build info card with distance and elevation
  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.distance != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.straighten, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.distance!.toStringAsFixed(1)} km',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            if (widget.distance != null && widget.elevation != null)
              const SizedBox(height: 8),
            if (widget.elevation != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.terrain, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.elevation!.toStringAsFixed(0)} m',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Calculate bounds for the route
  LatLngBounds? _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) return null;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }
}
