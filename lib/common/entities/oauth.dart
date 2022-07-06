import 'package:hot_list/common/utils/url.dart';

class Oauth {
  final String name;
  final String url;
  final String path;
  final String clientId;
  final String oauthBaseUrl;

  const Oauth({
    required this.name,
    this.url = "http://localhost:8000",
    required this.path,
    required this.clientId,
    required this.oauthBaseUrl,
  });

  Oauth copyWith({
    String? name,
    String? url,
    String? path,
    String? clientId,
    String? oauthBaseUrl,
  }) {
    return Oauth(
        name: name ?? this.name,
        clientId: clientId ?? this.clientId,
        url: url ?? this.url,
        path: path ?? this.path,
        oauthBaseUrl: oauthBaseUrl ?? this.oauthBaseUrl);
  }

  String get redirectUrl => urlJoin(url, path);

  String get oauthUrl => oauthBaseUrl
      .replaceAll('{client_id}', clientId)
      .replaceAll('{redirect_uri}', redirectUrl);
}
