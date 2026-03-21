import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class LinkParserService {
  /// Analyzes shared text to see if there's a URL
  String? extractUrl(String text) {
    final RegExp urlRegExp = RegExp(
      r'((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?',
      caseSensitive: false,
    );
    final match = urlRegExp.firstMatch(text);
    if (match != null) {
      return text.substring(match.start, match.end);
    }
    return null;
  }

  /// Fetches the URL and extracts OpenGraph metadata or title to guess distance and elevation
  Future<Map<String, dynamic>?> parseUrl(String url) async {
    try {
      String fetchUrl = url;
      if (kIsWeb) {
        // Use a CORS proxy if running on Flutter Web to avoid "Failed to fetch"
        fetchUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      }

      final response = await http
          .get(
            Uri.parse(fetchUrl),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final document = html.parse(response.body);

        // Extract title and OpenGraph description
        String title = '';
        String description = '';

        final titleElement = document.querySelector('title');
        if (titleElement != null) {
          title = titleElement.text;
        }

        final metaTags = document.querySelectorAll('meta');
        for (var meta in metaTags) {
          if (meta.attributes['property'] == 'og:description' ||
              meta.attributes['name'] == 'description') {
            description = meta.attributes['content'] ?? '';
            break;
          }
          if (meta.attributes['property'] == 'og:title') {
            title = meta.attributes['content'] ?? title;
          }
        }

        final fullText = '$title $description';

        // Simple regex extraction for Km / Elevation
        // Example Strava: "42.5 km - 500 m elevation"
        // Example Komoot: "Distance: 42.5 km | Elevation: 500 m"
        double? distance;
        double? elevation;
        String? extractedName = title;

        final distanceRegExp = RegExp(
          r'([\d\.,]+)\s*(km|chilometri|kilometers)',
          caseSensitive: false,
        );
        final distMatch = distanceRegExp.firstMatch(fullText);
        if (distMatch != null) {
          final distStr = distMatch.group(1)?.replaceAll(',', '.') ?? '';
          distance = double.tryParse(distStr);
        }

        final elevRegExp = RegExp(
          r'([\d\.,]+)\s*(m|metri|elevation|dislivello)',
          caseSensitive: false,
        );
        final elevMatch = elevRegExp.firstMatch(fullText);
        // Ensure it didn't match the same as distance if 'm' was used incorrectly, but usually ' elevation' helps.
        // Let's look exactly for Dislivello or elevation near it
        final specificElevRegExp = RegExp(
          r'(dislivello|elevation|ascenso|elev)[\s:]*([\d\.,]+)\s*m?',
          caseSensitive: false,
        );
        final specificElevMatch = specificElevRegExp.firstMatch(fullText);

        if (specificElevMatch != null) {
          final elevStr =
              specificElevMatch.group(2)?.replaceAll(',', '.') ?? '';
          elevation = double.tryParse(elevStr);
        } else if (elevMatch != null) {
          final elevStr = elevMatch.group(1)?.replaceAll(',', '.') ?? '';
          elevation = double.tryParse(elevStr);
        }

        // Date (e.g., "on 12 Aug 2023", "il 12/08/2023")
        DateTime? activityDate;
        final dateRegExp = RegExp(
          r'(\d{1,2})[\s/]+([a-zA-Z]{3}|\d{1,2})[\s/]+(\d{4}|\d{2})',
          caseSensitive: false,
        );
        final dateMatch = dateRegExp.firstMatch(fullText);
        String dateNotes = '';
        if (dateMatch != null) {
          final d = dateMatch.group(1);
          final m = dateMatch.group(2);
          final y = dateMatch.group(3);
          dateNotes = 'Data trovata: $d/$m/$y\n';
        }

        // Heart Rate (bpm, hr, fc)
        int? heartRate;
        final hrRegExp = RegExp(
          r'([\d]{2,3})\s*(bpm|hr|fc media|frequenza cardiaca)',
          caseSensitive: false,
        );
        final hrMatch = hrRegExp.firstMatch(fullText);
        if (hrMatch != null) {
          heartRate = int.tryParse(hrMatch.group(1) ?? '');
        }

        // Power (W, watt)
        int? power;
        final powerRegExp = RegExp(
          r'([\d]{2,4})\s*(W|Watt)',
          caseSensitive: false,
        );
        final matches = powerRegExp.allMatches(fullText);
        for (var powerMatch in matches) {
          final pwr = int.tryParse(powerMatch.group(1) ?? '');
          if (pwr != null && pwr > 30 && pwr < 2000) {
            power = pwr;
            break;
          }
        }

        return {
          'name': extractedName,
          'distance': distance,
          'elevation': elevation,
          'date': activityDate,
          'heartRate': heartRate,
          'power': power,
          'notes':
              'Importato dal link: $url\n\n$dateNotes\nDettagli estratti:\n$description',
        };
      }
    } catch (e) {
      print('Error parsing URL $url: $e');
    }
    return null;
  }
}
