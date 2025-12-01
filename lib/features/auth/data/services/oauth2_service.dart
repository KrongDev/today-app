import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class OAuth2Service {
  static const String _baseUrl = 'http://localhost:8080'; // TODO: Update with actual server URL
  
  StreamSubscription? _linkSubscription;
  
  /// Launch OAuth2 login in browser
  Future<void> launchOAuth2Login(String provider) async {
    final url = Uri.parse('$_baseUrl/oauth2/authorization/$provider');
    
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch OAuth2 URL');
    }
  }
  
  /// Listen for deep link callback and extract tokens
  Stream<OAuth2Tokens> listenForCallback() async* {
    try {
      // Get initial link if app was opened via deep link
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        final tokens = _extractTokens(initialLink);
        if (tokens != null) {
          yield tokens;
        }
      }
      
      // Listen for subsequent deep links
      await for (final link in linkStream) {
        if (link != null) {
          final tokens = _extractTokens(link);
          if (tokens != null) {
            yield tokens;
          }
        }
      }
    } catch (e) {
      throw Exception('Error listening for OAuth2 callback: $e');
    }
  }
  
  /// Extract tokens from redirect URL
  OAuth2Tokens? _extractTokens(String url) {
    final uri = Uri.parse(url);
    
    // Expected format: myapp://oauth2/redirect?accessToken=...&refreshToken=...
    if (uri.path.contains('oauth2/redirect')) {
      final accessToken = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];
      
      if (accessToken != null && refreshToken != null) {
        return OAuth2Tokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
    }
    
    return null;
  }
  
  void dispose() {
    _linkSubscription?.cancel();
  }
}

class OAuth2Tokens {
  final String accessToken;
  final String refreshToken;
  
  OAuth2Tokens({
    required this.accessToken,
    required this.refreshToken,
  });
}
