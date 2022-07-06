import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hot_list/common/entities/oauth.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/hot_list/controllers/user.dart';
import 'mobile_login.dart' if (dart.library.html) 'web_login.dart';

class LoginProvider extends StatelessWidget {
  const LoginProvider(
      {Key? key,
      required this.name,
      required this.image,
      required this.oauth,
      required this.onLoginSuccess})
      : super(key: key);

  final String image;
  final String name;
  final Oauth oauth;
  final void Function(Json) onLoginSuccess;
  // Completer<WebViewController> _webViewController =
  //     Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        doLogin(
            context: context,
            oauth: oauth,
            onComplete: (response) {
              if (response != null && response.success) {
                UserController.onLoginSucceed(response.result!);
                onLoginSuccess(response.result!);
              } else {
                Fluttertoast.showToast(msg: response!.errorData.toString());
              }
            });
      },
      child: Container(
        width: 60,
        height: 60,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Image.asset(image),
      ),
    );
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({required this.loginProviders, Key? key}) : super(key: key);

  final List<LoginProvider> loginProviders;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // padding: EdgeInsets.only(top: 50),
              // scrollDirection: Axis.vertical,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                  ),
                ),
                Text(
                  '吾日三省吾身',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, color: Colors.grey[600]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 150.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: loginProviders
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: e,
                            ))
                        .toList(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
