import 'package:flutter/material.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/hot_list/controllers/setting.dart';
import 'package:hot_list/hot_list/entities/setting.dart';

class IsShowBrowsedDataButton extends StatelessWidget {
  const IsShowBrowsedDataButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(Icons.restart_alt_rounded
              // size: 17,
              ),
        ),
        const Expanded(child: Text("显示已读热点")),
        SettingObx(
            key: ObservedKey.isShowBrowsedData,
            builder: (key, controller) {
              return Checkbox(
                  value: controller.getSetting(key),
                  onChanged: (bool? value) {
                    value = value ?? true;
                    controller.updateSetting(key, value);
                    Get.back();
                  });
            })
      ],
    );
  }
}

class IsShowNotBrowsedCountButton extends StatelessWidget {
  const IsShowNotBrowsedCountButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(Icons.numbers
              // size: 17,
              ),
        ),
        const Expanded(child: Text("显示未读数量")),
        SettingObx(
            key: ObservedKey.isShowNotBrowsedFlag,
            builder: (key, controller) {
              return Checkbox(
                  value: controller.getSetting(key)!,
                  onChanged: (bool? value) {
                    value = value ?? true;
                    controller.updateSetting(key, value);
                    Get.back();
                  });
            })
      ],
    );
  }
}

// 将最近更新的信息标记为红色
class IsLabelLatesetDataButton extends StatelessWidget {
  const IsLabelLatesetDataButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(Icons.label
              // size: 17,
              ),
        ),
        const Expanded(child: Text("标记最新热点")),
        SettingObx(
            key: ObservedKey.isLabelLatestData,
            builder: (key, controller) {
              return Checkbox(
                  value: controller.getSetting(key)!,
                  onChanged: (bool? value) {
                    value = value ?? true;
                    controller.updateSetting(key, value);
                    Get.back();
                  });
            })
      ],
    );
  }
}

//  是否不显示最近更新的信息
class IsShowNotLatestButton extends StatelessWidget {
  const IsShowNotLatestButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(Icons.new_label_sharp
              // size: 17,
              ),
        ),
        const Expanded(child: Text("显示上次未读")),
        SettingObx(
            key: ObservedKey.isShowNotLatestData,
            builder: (key, controller) {
              return Checkbox(
                  value: controller.getSetting(key)!,
                  onChanged: (bool? value) {
                    value = value ?? true;
                    controller.updateSetting(key, value);
                    Get.back();
                  });
            })
      ],
    );
  }
}

//  是否不显示最近更新的信息
class IsEnableFilterButton extends StatelessWidget {
  const IsEnableFilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(Icons.filter_list
              // size: 17,
              ),
        ),
        const Expanded(child: Text("启用过滤")),
        SettingObx(
            key: ObservedKey.isEnableFilter,
            builder: (key, controller) {
              return Checkbox(
                  value: controller.getSetting(key)!,
                  onChanged: (bool? value) {
                    value = value ?? true;
                    controller.updateSetting(key, value);
                    Get.back();
                  });
            })
      ],
    );
  }
}
