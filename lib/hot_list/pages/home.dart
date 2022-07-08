// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:hot_list/hot_list/pages/expolre.dart';
import 'package:hot_list/hot_list/pages/subscribe.dart';
import 'package:hot_list/hot_list/pages/usage.dart';

class PageItem {
  final BottomNavigationBarItem bar;
  final Widget widget;

  PageItem({required this.bar, required this.widget});
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController controller;
  late final PageController _pageController = PageController(initialPage: _currentIndex);
  int _currentIndex = 0;

  final _pageItems = [
    PageItem(
        bar: const BottomNavigationBarItem(icon: Icon(Icons.home), label: "热点"),
        widget: const SubscribePage()),
    PageItem(
        bar: const BottomNavigationBarItem(
            icon: Icon(Icons.explore), label: "发现"),
        widget: const ExplorePage()),
    PageItem(
        bar: const BottomNavigationBarItem(
            icon: Icon(Icons.people), label: "我的"),
        widget: const UsagePage()),
  ];

  onTap(int index) {
    _pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // body: new PageView(physics: ScrollPhysics(),
      body: PageView.builder(
        //要点1
        physics: const NeverScrollableScrollPhysics(),
        //禁止页面左右滑动切换
        controller: _pageController,
        onPageChanged: onPageChanged,
        //回调函数
        itemCount: _pageItems.length,
        itemBuilder: (context, index) => _pageItems[index].widget,
      ),

      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Colors.black,
        // selectedItemColor: Colors.blue,
        type: BottomNavigationBarType
            .fixed, // 不加这一行会造成背景色无用bug https://github.com/flutter/flutter/issues/13642
        onTap: onTap,
        items: _pageItems.map((e) => e.bar).toList(),
        currentIndex: _currentIndex,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
