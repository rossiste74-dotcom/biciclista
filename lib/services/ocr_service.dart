import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  Future<Map<String, dynamic>> extractRideDataFromImage(
    String imagePath,
  ) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      final text = recognizedText.text;

      double? distance;
      double? elevation;
      String? timeStr;

      // Extract specific patterns for Strava/Komoot screenshots
      // E.g. "Distanza 42,5 km", "Dislivello 500 m", "Tempo 1:45:00"

      // Look for distance: usually close to 'km'
      final distanceRegExp = RegExp(r'([\d\.,]+)\s*km', caseSensitive: false);
      final distMatch = distanceRegExp.firstMatch(text);
      if (distMatch != null) {
        final distStr = distMatch.group(1)?.replaceAll(',', '.') ?? '';
        distance = double.tryParse(distStr);
      }

      // Look for elevation: usually close to 'm' and maybe the word 'dislivello' or 'elev' or just 'm' after a number
      final elevRegExp = RegExp(
        r'(dislivello|ascenso|elev|elevation)[\s\n]*([\d\.,]+)\s*m',
        caseSensitive: false,
      );
      final elevMatch = elevRegExp.firstMatch(text);
      if (elevMatch != null) {
        final elevStr = elevMatch.group(2)?.replaceAll(',', '.') ?? '';
        elevation = double.tryParse(elevStr);
      } else {
        // Fallback: search for something followed by 'm' that is not a km
        final anyElevRegExp = RegExp(r'([\d\.,]+)\s*m\b', caseSensitive: false);
        final matches = anyElevRegExp.allMatches(text);
        for (var match in matches) {
          final valStr = match.group(1)?.replaceAll(',', '.') ?? '';
          final val = double.tryParse(valStr);
          if (val != null && (distance == null || val != distance)) {
            elevation = val;
            break;
          }
        }
      }

      // Time (e.g. 1h 45m or 1:45:00)
      final timeRegExp = RegExp(
        r'([\d]+)[h:]\s*([\d]+)[m]?',
        caseSensitive: false,
      );
      final timeMatch = timeRegExp.firstMatch(text);
      if (timeMatch != null) {
        final hours = timeMatch.group(1);
        final minutes = timeMatch.group(2);
        timeStr = '${hours}h ${minutes}m';
      }

      // Date parsing (e.g., "12 Ago 2023", "12/08/2023", "Oggi alle 14:30")
      DateTime? activityDate;
      // Very basic date regex for DD MM YYYY or DD/MM/YYYY
      final dateRegExp = RegExp(
        r'(\d{1,2})[\s/]+([a-zA-Z]{3}|\d{1,2})[\s/]+(\d{4}|\d{2})',
        caseSensitive: false,
      );
      final dateMatch = dateRegExp.firstMatch(text);
      if (dateMatch != null) {
        // Attempt to create a rudimentary date string. A full robust logic would use intl.
        // For now, if we find a year, we just flag it. The actual parsing is complex due to languages.
        // We will pass the raw match to notes or try a very basic parse.
        final d = dateMatch.group(1);
        final m = dateMatch.group(2);
        final y = dateMatch.group(3);
        timeStr = '${timeStr ?? ''} Data trovata: $d/$m/$y';
      }

      // Heart Rate (bpm or fc media)
      int? heartRate;
      final hrRegExp = RegExp(
        r'([\d]{2,3})\s*(bpm|fc media|frequenza cardiaca)',
        caseSensitive: false,
      );
      final hrMatch = hrRegExp.firstMatch(text);
      if (hrMatch != null) {
        heartRate = int.tryParse(hrMatch.group(1) ?? '');
      }

      // Power (W, watt)
      int? power;
      final powerRegExp = RegExp(
        r'([\d]{2,4})\s*(W|Watt)',
        caseSensitive: false,
      );
      // Wait, distance could be matching "W", so we have to be careful. But "W" or "Watt" are usually distinct.
      // Also check it's preceded by "potenza" optionally.
      final matches = powerRegExp.allMatches(text);
      for (var powerMatch in matches) {
        final pwr = int.tryParse(powerMatch.group(1) ?? '');
        if (pwr != null && pwr > 30 && pwr < 2000) {
          // sanity check for power vs other numbers
          power = pwr;
          break;
        }
      }

      return {
        'distance': distance,
        'elevation': elevation,
        'date': activityDate, // May be null if not confidently parsed
        'heartRate': heartRate,
        'power': power,
        'notes':
            'Importato tramite screenshot.\n${timeStr != null && timeStr.isNotEmpty ? 'Tempo/Data: $timeStr\n' : ''}\nTesto grezzo letto:\n$text',
      };
    } catch (e) {
      print('OCR Error: $e');
      return {'notes': 'Errore durante la lettura OCR: $e'};
    } finally {
      textRecognizer.close();
    }
  }
}
