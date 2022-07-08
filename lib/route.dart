import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_list/hot_list/pages/browse.dart';
import 'package:hot_list/hot_list/pages/expolre.dart';
import 'package:hot_list/hot_list/pages/home.dart';
import 'package:hot_list/hot_list/pages/login.dart';
import 'package:hot_list/hot_list/pages/search.dart';
import 'package:hot_list/hot_list/pages/splash.dart';
import 'package:hot_list/hot_list/pages/usage.dart';
import 'package:hot_list/hot_list/widgets/subscribe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Routes {
  static String splash = '/';
  static String home = '/home/';
  static String login = '/login';
  static String register = '/register';
  static String usage = '/usage';
  static String explore = '/hotnews/explore';
  static String search = '/search';
  static String subscribeManage = '/subscribe/manage';
  static String browseRecord = '/subscribe/browse_record';
  static String collection = '/user/collection';
  static String subscribeDetail = '/subscribe/detail';
  static String browseDetail = '/subscribe/detail/browse';
  static String browseHistory = '/subscribe/detail/browse/history';
  static String browseCollection =
      '/hotnews/subscribe/detail/browse/collection';

  static Map<String, Widget Function(BuildContext)> get routes {
    var mapping = {
      splash: (context) => const SplashWidget(),
      home: (context) => const HomePage(),
      login: (context) => const LoginPage(),
      // register: (context)=>RegisterView(),
      usage: (context) => const UsagePage(),
      explore: (context) => const ExplorePage(),
      search: (context) => const SearchPage(),
      browseHistory: (context) => const BrowseHistoryPage(),
      browseCollection: (context) => const BrowseCollectionPage(),
      subscribeDetail: (context) {
        print("arguments ${Get.arguments}");
        return SubscriibeDetailWidget(
          subscribe: Get.arguments,
          subscribable: true,
        );
      },
      browseDetail: (context) {
        return BrowseDetailPage(Get.arguments);
      },

      subscribeManage: (context) {
        return SubscribeManageWidget();
      },
    };
    return mapping;
  }
}
