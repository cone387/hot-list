import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hot_list/route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(HotListApp());
  if (!kIsWeb && Platform.isIOS) {
    if (kDebugMode) {
      print("backgound task register");
    }
    // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }
}

class HotListApp extends StatefulWidget {
  const HotListApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HotListState();
  }
  // Name:todayapn
  // Key ID:ZKH6JZ9KQ3
  // Services:Apple Push Notifications service (APNs), DeviceCheck

}

class HotListState extends State<HotListApp> {
  static Widget _defaultErrorWidgetBuilder(FlutterErrorDetails details) {
    String message = '';
    assert(() {
      message =
          '${details.exception}\nSee also: https://flutter.dev/docs/testing/errors';
      return true;
    }());
    final Object exception = details.exception;
    return ErrorWidget.withDetails(
        message: message, error: exception is FlutterError ? exception : null);
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return _defaultErrorWidgetBuilder(errorDetails);
    };
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'your todos',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        fontFamily: 'Roboto-Light',
        primaryColor: Colors.black,
        // textTheme: TextTheme(),
        primaryTextTheme:
            const TextTheme(headline1: TextStyle(color: Colors.black)),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                    const TextStyle(color: Colors.black)))),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                    const TextStyle(color: Colors.black)))),
        // bottomAppBarColor: Colors.black,
        // primaryColorBrightness: Brightness.light,
        appBarTheme: const AppBarTheme(
            elevation: 0,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white24),
        // primaryColor: Colors.white,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: Routes.routes,
      initialRoute: Routes.splash,
      routingCallback: (Routing? route) {
        // onRouting(route);
        print(route);
      },
      // home: SplashWidget(),
    );
  }
}
