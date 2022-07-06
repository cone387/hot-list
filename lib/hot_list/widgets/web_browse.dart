// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/logger.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:html' as html;

void goToDetail({required BrowseRecord record}) {
  logger.d("goto $record");
  html.window.open(record.data.url, record.subscribe.name);
}

class BrowseWidget extends StatelessWidget {
  final BrowseRecord record;

  const BrowseWidget({required this.record, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    launchUrlString(record.data.url);
    return const Scaffold();
  }
}
