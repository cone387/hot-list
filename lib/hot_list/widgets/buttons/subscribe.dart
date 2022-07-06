// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_list/hot_list/controllers/subscribe.dart';
import 'package:hot_list/hot_list/controllers/user.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';

// Widget addSuggestSubBtn(context){
//     return IconButton(
//         icon: Icon(Icons.add, size: 25, color: Colors.blue,),
//         onPressed: (){
//             Navigator.push(context, MaterialPageRoute(builder: (_){
//                 return SuggestView();
//             }));
//         });
// }

// Widget goToHistoryBtn(context){
//     return IconButton(icon: Icon(Icons.history, size: 25, color: Colors.blue,), onPressed: (){
//             logger.d("click history");
//             Navigator.push(context, MaterialPageRoute(builder: (_)=>HistoryView()));
//      });
// }

// Widget collectionBtn(context, sub, data){
//     // 将某条信息添加到收藏的按钮/  Icons.star_border -> 为收藏, Icons.star -> 已收藏
//     return IconButton(icon: Icon(Icons.star_border), onPressed: (){
//         logger.d("addToCollection");
//         User.addCollection(BrowseRecord(sub, data)).then((value) => Fluttertoast.showToast(msg: "添加到收藏"));
//     });
// }

// Widget shareBtn(context){
//     // 分享订阅或某条信息
//     return IconButton(icon: Icon(Icons.share), onPressed: (){
//         Fluttertoast.showToast(msg: "分享");
//         });
// }

// Widget openInBrowseBtn(context){
//     return IconButton(icon: Icon(Icons.open_in_browser_outlined), onPressed: (){Fluttertoast.showToast(msg: "在浏览器中打开");});
// }

// Widget openInApp(context){
//     return IconButton(icon: Icon(Icons.exit_to_app), onPressed: (){Fluttertoast.showToast(msg: "在APP中打开");});
// }

// Widget SubscribeBtn(context, Subscribe sub) {
//   return TextButton(
//       child: Text("退订"),
//       style:
//           ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
//       onPressed: () {
//         // if(User.isAnonymous){
//         //     Get.toNamed(Routes.login);
//         // }
//         // UserController.unsubscribe(sub as UserSubscribe).then((value){
//       });
// }

class SubscribeButton<T> extends StatefulWidget {
  final Subscribe subscribe;
  const SubscribeButton(this.subscribe, {Key? key}) : super(key: key);

  @override
  State<SubscribeButton<T>> createState() {
    return _SubscribeButtonState<T>();
  }
}

class _SubscribeButtonState<T> extends State<SubscribeButton<T>> {

  late UserSubscribe? subscribe = UserSubscribeControler().querySubscribe(widget.subscribe);

  bool get isSubscribed => subscribe != null;

  _onPressed() {
    if (isSubscribed) {
      UserSubscribeControler()
          .removeItem(subscribe!);
    } else {
      UserSubscribeControler()
          .addItem(UserSubscribe(subscribe: widget.subscribe));
    }
    setState(() {
      subscribe = UserSubscribeControler().querySubscribe(widget.subscribe);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color color = isSubscribed ? Colors.red : Colors.blue;
    String text = isSubscribed ? "退订" : "订阅";
    if (T == FloatingActionButton) {
      return FloatingActionButton(
        backgroundColor: color ,
        onPressed: _onPressed,
        child: Text(text),
      );
    } else {
      return TextButton(
        onPressed: _onPressed,
        style: ButtonStyle(
            textStyle:
                MaterialStateProperty.all(const TextStyle(color: Colors.blue)),
            backgroundColor: MaterialStateProperty.all(Colors.grey[400])),
        child: Text(text, style: TextStyle(color: color),
        ),
      );
    }
  }
}
