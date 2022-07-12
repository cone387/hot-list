// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_list/common/controllers/object.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/hot_list/entities/setting.dart';

Widget SettingObx<T>({
  required SettingKey<T> key,
  required Widget Function(SettingKey<T>, _SettingController) builder,
}) {
  return GetBuilder(
      global: false,
      init: SettingController,
      id: key.name,
      builder: (_SettingController c) => builder(key, c));
}

Widget SettingsObx({
  required List<SettingKey> keys,
  required Widget Function(List<SettingKey> keys, _SettingController) builder,
}) {
  GlobalKey globalKey = GlobalKey();
  return GetBuilder(
      key: globalKey,
      global: false,
      // autoRemove: false,
      init: SettingController,
      id: keys,
      builder: (_SettingController controller) {
        for (var element in keys) {
          controller.addListenerId(element.name, () {
            if (globalKey.currentState != null &&
                globalKey.currentState!.mounted) {
              // ignore: invalid_use_of_protected_member
              globalKey.currentState!.setState(() {});
            }
          });
        }
        return builder(keys, controller);
      });
}

class _SettingController extends CacheableRichItemController<Setting> {
  _SettingController();

  @override
  Setting decoder(Json json) {
    return Setting.fromJson(json);
  }

  @override
  Future<Setting?> getItem() async {
    return null;
  }

  updateSetting<T>(SettingKey key, T value) {
    item.value.set<T>(key.name, value);
    update([key.name]);
    toCache(item.value);
  }

  T? getSetting<T>(SettingKey key) {
    return item.value.get(key.name) ?? key.value;
  }

  @override
  Setting get initItem => Setting();

  @override
  String get key => 'hot-list-setting';
}

_SettingController SettingController = _SettingController();
Rx<Setting> get GlobalSetting => SettingController.item;
