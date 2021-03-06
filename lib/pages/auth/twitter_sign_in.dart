import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:privante/services/auth.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TwitterWebView extends StatelessWidget {
  TwitterWebView(this._auth);

  final Auth _auth;

  @override
  Widget build(BuildContext context) {
    print('開いた');
    return Scaffold(
        appBar: AppBar(
          title: Text('twitter login'),
        ),
        body: FutureBuilder(
            future: _auth.getTwitterAuthUrl(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (!snapshot.hasData) {
                print('グルグル');
                return Center(child: CircularProgressIndicator());
              }
              print('webview表示');
              print(snapshot.data);

              return WebView(
                // ここ変更
                initialUrl: snapshot.data,
                javascriptMode: JavascriptMode.unrestricted,
                navigationDelegate: (NavigationRequest request) {
                  print('delegate : ${request.url}');
                  if (request.url
                      .startsWith(DotEnv().env['TWITTER_REDIRECT_URI'])) {
                    // クエリストリングを取得
                    final String query = request.url.split('?').last;
                    if (query.contains('denied')) {
                      /// Cancel
                      print('cancel');
                      Navigator.pop(context, null);
                      // 重複pop対策
                    } else {
                      print('ok');
                      final Map<String, String> res =
                          Uri.splitQueryString(query);
                      _auth.signInWithTwitter(res).then((FirebaseUser user) {
                        /// Navigate to Main Page
                        Navigator.pop(context, user);
                        // 重複pop対策
                        return Future.value(false);
                      });
                    }
                  }
                  // ここは検討
                  print('if 一番した');
                  return NavigationDecision.navigate;
                },
              );
            }));
  }
}
