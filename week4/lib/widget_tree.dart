import 'package:flutter/material.dart';
import 'package:week4/pages/home_page.dart';
import 'package:week4/pages/login_register_page.dart';
import 'package:week4/auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BudgetTrackerApp();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
