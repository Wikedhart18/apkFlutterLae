import 'dart:convert';
import 'dart:io';

class NotificationWebhookClient {
  NotificationWebhookClient._();

  static final String? _endpoint = const String.fromEnvironment('NOTIFY_URL');
  static final String? _apiKey = const String.fromEnvironment('NOTIFY_API_KEY');

  static bool get isConfigured =>
      _endpoint != null && _endpoint!.isNotEmpty && _apiKey != null && _apiKey!.isNotEmpty;

  static Future<void> notifyPackageStatus({
    required String clienteId,
    required String packageId,
    required String estado,
  }) async {
    if (!isConfigured) return;
    try {
      final uri = Uri.parse(_endpoint!);
      final client = HttpClient();
      final req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.headers.add('x-api-key', _apiKey!);
      req.add(utf8.encode(jsonEncode({
        'clienteId': clienteId,
        'packageId': packageId,
        'estado': estado,
      })));
      final resp = await req.close();
      await resp.drain<void>();
      client.close();
    } catch (_) {
      // Silencioso: el flujo principal (actualización de estado) no debe fallar por el webhook.
    }
  }
}


