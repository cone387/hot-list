// ignore_for_file: library_private_types_in_public_api

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/logger.dart';
import 'package:flutter/material.dart';
import 'package:hot_list/route.dart';

Future<T?>? goToDetail<T>({required BrowseRecord record}) {
  logger.d("goto $record");
  return Get.toNamed(Routes.browseDetail, arguments: record);
}

class BrowseWidget extends StatelessWidget {
  final BrowseRecord record;

  const BrowseWidget({required this.record, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      pullToRefreshController: PullToRefreshController(),
      initialUrlRequest: URLRequest(url: Uri.parse(record.data.url)),
      onWebViewCreated: (controller) {},
      // navigationDelegate: (NavigationRequest request) {
      //   logger.d("url ${request.url}");
      //   if (request.url.startsWith('zhihu://')) {
      //     logger.d("即将打开 ${request.url}");
      //     return NavigationDecision.prevent;
      //   }
      //   return NavigationDecision.navigate;
      // },
      shouldInterceptAjaxRequest: (controller, request) async {
        print("should intercept");
        return request;
      },
      onLoadStop: (controller, uri) {
        if (uri.toString().contains("zhihu.com")) {
          controller.evaluateJavascript(source: '''(function closePopUp(){
                                        var actions = document.getElementsByClassName('ModalExp-modalShow')[0].getElementsByClassName('ModalWrap-itemBtn');
                                        actions[actions.length-1].click();
                                    })()''');
        }
      },
    );
  }
}
