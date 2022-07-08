// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:hot_list/hot_list/controllers/subscribe.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';


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
