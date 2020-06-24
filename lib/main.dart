import 'package:flutter/material.dart';

import 'home.dart';
import 'routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '广告牌',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
//      supportedLocales: const <Locale>[
//        const Locale('en', 'US'), // English
//        const Locale('zh', 'ZH'), // Chinese
//      ],
      initialRoute: MyHomePage.route,
      routes: routes,
    );
  }
}
