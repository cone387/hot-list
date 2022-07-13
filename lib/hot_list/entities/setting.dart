import 'package:get/get.dart';
import 'package:hot_list/common/commont.dart';

class SettingKey<T> {
  final String key;
  SettingKey? parent;
  T? value;
  SettingKey(this.key, {this.parent, this.value});

  set parentName(String name) {
    parent = SettingKey(name);
  }

  @override
  String toString() {
    if (parent != null) {
      return "${parent!.name}.$key";
    } else {
      return key;
    }
  }

  String get name {
    return toString();
  }
}

class MutiSettingKey {
  List<SettingKey> keys;
  static final Map<String, MutiSettingKey> _mapping = {};

  MutiSettingKey._from(this.keys);

  factory MutiSettingKey(List<SettingKey> keys) {
    String name = keys.join(';');
    _mapping[name] ??= MutiSettingKey._from(keys);
    return _mapping[name]!;
  }

  bool operator ==(other) {
    if (other is MutiSettingKey) {
      return hashCode == other.hashCode;
    } else if (other is SettingKey) {
      return keys.firstWhereOrNull(
              (element) => element.toString() == other.toString()) !=
          null;
    } else if (other is String) {
      return keys.map((e) => e.toString()).contains(other);
    }
    return false;
  }

  @override
  int get hashCode {
    int a = 0;
    for (var element in keys) {
      a += element.hashCode;
    }
    return a;
  }
}

class ObservedKey {
  static var isShowBrowsedData =
      SettingKey('is-show-browsed-data', value: true);
  static var isShowNotBrowsedFlag =
      SettingKey<bool>('is-show-not-browsed-flag', value: true);
  static var browsedTimesChanged =
      SettingKey<int>('browsed-times-changed', value: 0);
  static var isLabelLatestData = SettingKey<bool>('is-label-latest-data', value: true);
  static var isShowNotLatestData = SettingKey<bool>('is-show-not-latest-data', value: true);
  static var isEnableFilter = SettingKey<bool>('is-enable-filter', value: true);
}

class Setting extends IdSerializable {
  Setting() : _setting = {};

  late final Json _setting;

  Setting.fromJson(Json json) {
    _setting = json;
  }

  @override
  Json toJson() {
    return _setting;
  }

  set<T>(String key, T value) {
    _setting[key] = value;
  }

  T? get<T>(String key) {
    return _setting[key];
  }
}
