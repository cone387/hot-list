// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:hot_list/common/extensions/datetime.dart';
import 'package:hot_list/common/widgets/image.dart';
import 'package:hot_list/common/widgets/list.dart';
import 'package:hot_list/hot_list/controllers/browse.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/widgets/mobile_browse.dart'
    if (dart.library.html) 'package:hot_list/hot_list/widgets/web_browse.dart';
export 'package:hot_list/hot_list/widgets/mobile_browse.dart'
    if (dart.library.html) 'package:hot_list/hot_list/widgets/web_browse.dart'
    show goToDetail, BrowseWidget;

class RecordTile extends StatelessWidget {
  final BrowseRecord record;
  final int index;
  const RecordTile({
    Key? key,
    required this.record,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        goToDetail(record: record);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: buildRectWidget(
          radius: 10, child: buildImageWidget(record.subscribe.imageUrl)),
      title: Text(record.data.title),
      subtitle: Text(record.subscribe.name),
      trailing: Text(record.browseTime.smartFormat),
    );
  }
}
