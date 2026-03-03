import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'link_parser_service.dart';
import 'ocr_service.dart';
import '../screens/manual_ride_screen.dart';

class ShareIntentService {
  static final ShareIntentService _instance = ShareIntentService._internal();
  factory ShareIntentService() => _instance;
  ShareIntentService._internal();

  StreamSubscription? _intentDataStreamSubscription;
  bool _isProcessing = false;

  void init(BuildContext context) {
    // Listen to media sharing while app is open
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty && context.mounted) {
        _processSharedMedia(context, value.first);
      }
    }, onError: (err) {
      debugPrint("getMediaStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty && context.mounted) {
        _processSharedMedia(context, value.first);
        ReceiveSharingIntent.instance.reset(); // clear
      }
    });
  }

  Future<void> _processSharedMedia(BuildContext context, SharedMediaFile media) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      if (media.type == SharedMediaType.text || media.type == SharedMediaType.url) {
        final linkParser = LinkParserService();
        final url = linkParser.extractUrl(media.path);
        
        if (url != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Analisi del link in corso...')),
          );
          
          final data = await linkParser.parseUrl(url);
          
          if (data != null && context.mounted) {
            _navigateToManualRide(context, data);
          } else if (context.mounted) {
            // Fallback: just open with the text as note
            _navigateToManualRide(context, {'notes': media.path});
          }
        } else if (context.mounted) {
          // It's just text
          _navigateToManualRide(context, {'notes': media.path});
        }
      } else if (media.type == SharedMediaType.image) {
         final ocrService = OCRService();
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Estrazione dati dall\'immagine in corso...')),
         );
         
         final data = await ocrService.extractRideDataFromImage(media.path);
         if (context.mounted) {
            _navigateToManualRide(context, data);
         }
      }
    } finally {
      _isProcessing = false;
    }
  }

  void _navigateToManualRide(BuildContext context, Map<String, dynamic> data) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManualRideScreen(
          initialName: data['name']?.toString(),
          initialDistance: data['distance']?.toString(),
          initialElevation: data['elevation']?.toString(),
          initialNotes: data['notes']?.toString(),
          initialDate: data['date'] as DateTime?,
          initialHeartRate: data['heartRate'] as int?,
          initialPower: data['power'] as int?,
        ),
      ),
    );
  }

  void dispose() {
    _intentDataStreamSubscription?.cancel();
  }
}
