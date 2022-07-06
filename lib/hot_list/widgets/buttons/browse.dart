// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/hot_list/controllers/browse.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/logger.dart';
import 'package:hot_list/route.dart';
import 'package:url_launcher/url_launcher_string.dart';

Widget ToHistoryButton() {
  return IconButton(
      icon: const Icon(
        Icons.history,
        size: 25,
        color: Colors.blue,
      ),
      onPressed: () {
        logger.d("click history");
        Get.toNamed(Routes.browseHistory);
      });
}

Widget SubscribeManageButton() {
  return IconButton(
      icon: const Icon(
        Icons.menu,
      ),
      onPressed: () {
        Get.toNamed(Routes.subscribeManage);
      });
}

class CollectionButton extends StatelessWidget {
  final BrowseRecord record;

  const CollectionButton({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.star_border),
        onPressed: () {
          BrowseCollectionController().addItem(record);
          // User.addCollection(BrowseRecord(sub, data)).then((value) => Fluttertoast.showToast(msg: "添加到收藏"));
        });
  }
}

Widget DataShareButton(context) {
  // 分享订阅或某条信息
  return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        // Fluttertoast.showToast(msg: "分享");
      });
}

Widget OpenInBrowseButton(DataEntity data) {
  return IconButton(
      icon: const Icon(Icons.open_in_browser),
      onPressed: () {
        launchUrlString(data.url);
        // Fluttertoast.showToast(msg: "在浏览器中打开");
      });
}

Widget OpenInAppButton(context) {
  return IconButton(
      icon: const Icon(Icons.exit_to_app),
      onPressed: () {
        Fluttertoast.showToast(msg: "在APP中打开");
      });
}
