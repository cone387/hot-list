// ignore_for_file: avoid_web_libraries_in_flutter, unused_import

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hot_list/common/entities/login.dart';
import 'package:hot_list/common/entities/oauth.dart';
import 'package:hot_list/global.dart';
import 'dart:html' as html;
import 'dart:js';

import 'package:hot_list/logger.dart';

Future<T?> doLogin<T>({
  required BuildContext context,
  required Oauth oauth,
  Function(LoginResponse? loginResponse)? onComplete,
}) async {
  int i = 0;
  LoginResponse? loginRes;
  var window = html.window.open(oauth.oauthUrl, "seeme login");
  var onMessage = html.window.onMessage.listen(
      (
        event,
      ) {
        // event as html.MessageEvent;
        logger.d("event: ${event.data} $i");
        logger.i(event.data.runtimeType);
        loginRes = LoginResponse.fromJson(jsonDecode(event.data));
        window.close();
      },
      onError: (_) {
        logger.d("message on error");
        window.close();
      },
      cancelOnError: true,
      onDone: () {
        logger.d("on message done");
      });
  // print(window.opener == html.window); // => true
  // print(window.parent == html.window); // => false
  while (window.closed != null && !window.closed!) {
    // window.postMessage("window", "http://localhost:8000");
    // html.window.postMessage("html window", "*");
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  await onMessage.cancel();
  logger.i("end login");
  onComplete?.call(loginRes);
  return null;
}
