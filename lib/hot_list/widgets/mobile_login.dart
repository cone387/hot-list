import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hot_list/common/entities/login.dart';
import 'package:hot_list/common/entities/oauth.dart';

Future<T?> doLogin<T>({
  required BuildContext context,
  required Oauth oauth,
  Function(LoginResponse? loginResponse)? onComplete,
}) async {
  return Navigator.push<T>(context, MaterialPageRoute(builder: (context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(oauth.oauthUrl)),
          onWebViewCreated: (webViewController) async {
            webViewController.addJavaScriptHandler(
                handlerName: 'handleOauthResult',
                callback: (args) {
                  onComplete?.call(LoginResponse.fromJson(jsonDecode(args[0])));
                });
          },
        ),
      ),
    );
  }));
}


// login widget