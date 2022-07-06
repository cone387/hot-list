import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hot_list/common/commont.dart';
import 'package:hot_list/logger.dart';

abstract class ObjectCache<T> {
  String key;
  dynamic _value;

  ObjectCache({
    required this.key,
  });

  bool get isEmpty => _value == null;

  Future<T?> read() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString(key);
    if (string != null) {
      _value = jsonDecode(string);
    }
    return _value;
  }

  write(T object) async {
    _value = object;
    if (_value != null) {
      var prefs = await SharedPreferences.getInstance();
      prefs.setString(key, jsonEncode(_value));
      logger.d("write cache of $key success");
    } else {
      logger.d("cache<$key> is null cache");
    }
  }
}

class ListCache extends ObjectCache<List> {
  ListCache({required String key}) : super(key: key);
}

class JsonCache<T> extends ObjectCache<Json> {
  JsonCache({required String key}) : super(key: key);
}
