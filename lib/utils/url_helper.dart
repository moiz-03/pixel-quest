import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  const UrlHelper._();

  /// Returns `null` on success, or a user-facing error message on failure.
  static Future<String?> openExternal(String url) async {
    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) return 'Could not open the link.';
      return null;
    } on PlatformException catch (e) {
      return 'Could not open link: ${e.message ?? e.code}';
    } catch (_) {
      return 'Could not open the link.';
    }
  }
}
