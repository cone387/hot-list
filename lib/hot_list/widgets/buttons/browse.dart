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
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(),
    icon: const Icon(
      Icons.history,
      size: 25,
      // color: Colors.blue,
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

class CollectionButton extends StatefulWidget {
  final BrowseRecord record;

  const CollectionButton({Key? key, required this.record}) : super(key: key);

  @override
  State<CollectionButton> createState() => _CollectionButtonState();
}

class _CollectionButtonState extends State<CollectionButton> {
  @override
  void initState() {
    super.initState();
    widget.record.data.listenChange(
        'isCollected',
        () => setState(
              () => {},
            ));
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.record.data;
    return IconButton(
        icon: data.isCollected
            ? const Icon(
                Icons.star,
                color: Colors.blue,
              )
            : const Icon(Icons.star_border),
        onPressed: () {
          if (data.isCollected) {
            BrowseCollectionController().removeItem(widget.record);
          } else {
            BrowseCollectionController().addItem(widget.record);
          }
          // User.addCollection(BrowseRecord(sub, data)).then((value) => Fluttertoast.showToast(msg: "???????????????"));
        });
  }
}

Widget DataShareButton(context) {
  // ???????????????????????????
  return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        // Fluttertoast.showToast(msg: "??????");
      });
}

Widget OpenInBrowseButton(DataEntity data) {
  return IconButton(
      icon: const Icon(
        Icons.open_in_browser,
        color: Colors.blue,
      ),
      onPressed: () {
        launchUrlString(data.url);
        // Fluttertoast.showToast(msg: "?????????????????????");
      });
}

Widget OpenInAppButton(context) {
  return IconButton(
      icon: const Icon(Icons.exit_to_app),
      onPressed: () {
        Fluttertoast.showToast(msg: "???APP?????????");
      });
}
