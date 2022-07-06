import 'package:path/path.dart' as _path;

String urlJoin(String base, String path) {
  if (path.startsWith('http')) {
    return path;
  } else if (path.startsWith('/')) {
    var uri = Uri.parse(base);
    return _path.join(uri.origin, path.substring(1));
  }
  return _path.join(base, path);
}
