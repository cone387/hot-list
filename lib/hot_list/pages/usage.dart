import 'package:flutter/material.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/widgets/image.dart';
import 'package:hot_list/global.dart';
import 'package:hot_list/hot_list/controllers/user.dart';
import 'package:hot_list/route.dart';

class UsageItem {
  final String name;
  final IconData iconData;
  final String? route;

  UsageItem({required this.name, required this.iconData, this.route});
}

class UsagePage extends StatefulWidget {
  const UsagePage({Key? key}) : super(key: key);

  @override
  State<UsagePage> createState() => _UsageState();
}

class _UsageState extends State<UsagePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<UsageItem> usageItems = [
    UsageItem(
        name: "历史浏览", iconData: Icons.history, route: Routes.browseHistory),
    UsageItem(
        name: "我的收藏",
        iconData: Icons.collections,
        route: Routes.browseCollection),
    UsageItem(
      name: "信息过滤",
      iconData: Icons.filter_outlined,
    ),
    UsageItem(name: "推送设置", iconData: Icons.notifications),
    UsageItem(name: "主题设置", iconData: Icons.topic),
    UsageItem(name: "吐槽建议", iconData: Icons.comment),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // AppBar(title: Text("我的"),)
    return Scaffold(
        // appBar: AppBar(title: Text("我的"),),
        body: ListView(
      children: [
        Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: buildRectWidget(
                    child: buildImageWidget(GlobalUser.avatarUrl,
                        defaultImage: Global.defaultAvatar),
                    width: 110),
              ),
              Obx(() {
                if (UserController.isLoggedIn.value) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 5),
                    child: Text(
                      GlobalUser.username,
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                }
                return ElevatedButton(
                    onPressed: () {
                      Get.toNamed(Routes.login);
                    },
                    child: const Text("登录"));
              }),
              GlobalUser.email != null
                  ? Text(GlobalUser.email!,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ))
                  : Container(),
            ],
          ),
        ),
        ...usageItems.map((e) => ListTile(
            leading: Icon(e.iconData, color: Colors.blue), //左图标
            title: Text(e.name), //中间标题
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (e.route != null) {
                Get.toNamed(e.route!);
              }
            })),
        ListTile(
          leading: const Icon(
            Icons.exit_to_app_rounded,
            color: Colors.red,
          ),
          title: const Text("退出登录"),
          onTap: () {
            showModalBottomSheet(
                // isScrollControlled: true, //可滚动 解除showModalBottomSheet最大显示屏幕一半的限制
                shape: const RoundedRectangleBorder(
                  //圆角
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                context: context,
                builder: (context) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('您确定要退出登录吗?'),
                        ),
                        const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                  onPressed: () {
                                    UserController.logout().then((value) =>
                                        Get.offAllNamed(Routes.login));
                                  },
                                  child: const Text(
                                    "是",
                                    style: TextStyle(fontSize: 18),
                                  )),
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.grey[300],
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "否",
                                    style: TextStyle(fontSize: 18),
                                  )),
                            ),
                          ],
                        ),
                        Container(
                          height: 30,
                        )
                      ],
                    ),
                  );
                });
          },
        )
      ],
    ));
  }
}
