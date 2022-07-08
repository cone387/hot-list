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
  final DataEntity data;
  final int index;
  const RecordTile({
    Key? key,
    required this.data,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        goToDetail(record: BrowseRecord(subscribe: data.subscribe, data: data));
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: buildRectWidget(
          radius: 10, child: buildImageWidget(data.subscribe.imageUrl)),
      title: Text(data.subscribe.name),
      subtitle: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(data.title),
      ),
      trailing: Text(data.updateTime.smartFormat),
    );
  }
}


// Widget recordBuilder(BrowseRecord record, int index) {
//   return ListTile(
//       // isThreeLine: true,
//       // subtitle: history[index].sub,
//       minLeadingWidth: 0,
//       leading: Text(
//         (index + 1).toString(),
//         style: const TextStyle(color: Colors.red),
//       ),
//       title: Align(
//           alignment: Alignment.centerLeft, child: Text(record.data.title)),
//       trailing: Text(record.browseTime.smartFormat),
//       onTap: () {
//         goToDetail(record: record);
//       });
// }
