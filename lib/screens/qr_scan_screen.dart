import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qr_service.dart';
import '../services/database_service.dart';
import '../services/gpx_service.dart';
import '../models/planned_ride.dart';
import 'package:gpx/gpx.dart';
import 'dart:io';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        _handleQrData(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _handleQrData(String data) async {
    try {
      final decoded = QrService.decodeRide(data);
      final PlannedRide ride = decoded['ride'];
      final List<Map<String, double>>? track = decoded['track'];

      if (track != null && track.isNotEmpty) {
        // If there's a track, we create a temporary GPX to store it locally
        // so the app can show the route on map in detail screen.
        final gpx = Gpx();
        final trk = Trk();
        final segment = Trkseg();
        
        for (final pt in track) {
          segment.trkpts.add(Wpt(lat: pt['lat'], lon: pt['lng']));
        }
        
        trk.trksegs.add(segment);
        gpx.trks.add(trk);
        
        final gpxString = GpxWriter().asString(gpx);
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/shared_ride_${DateTime.now().millisecondsSinceEpoch}.gpx');
        await tempFile.writeAsString(gpxString);
        
        final localPath = await GpxService().saveGpxLocally(tempFile);
        ride.gpxFilePath = localPath;
      }

      final db = DatabaseService();
      await db.createPlannedRide(ride);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Percorso importato con successo!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'importazione: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scansiona QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay to guide user
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
