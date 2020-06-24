import 'package:flutter/material.dart';
import 'package:marqueer/home.dart';
import 'package:marqueer/marqueer.dart';

Map<String, WidgetBuilder> routes = {
  MyHomePage.route: (BuildContext context) => MyHomePage(),
  Marqueer.route: (BuildContext context) => Marqueer(),
};
