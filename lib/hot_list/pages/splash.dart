import 'package:flutter/material.dart';
import 'package:hot_list/global.dart';
import 'package:hot_list/hot_list/pages/home.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<SplashWidget> {
  @override
  void initState() {
    super.initState();
    if (!Global.isInitialized) {
      Global.init().then((value) => setState(() {
            // Global.overlayState = Overlay.of(context);
            // Global.overlayState?.insert(Global.createButton);
        }));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Global.isInitialized) {
      return Image.asset(
        "assets/images/splash.png",
        width: double.infinity,
        height: double.infinity,
        // fit: BoxFit.fill,
      );
    }
    return const HomePage();
  }
}
