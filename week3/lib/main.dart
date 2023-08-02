import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:week3/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: 'AIzaSyBjmY0Bb8lRboj6FeJHeLf9GYbU4aajmdQ',
        appId: '1:1098350360228:android:9ede9dd38752ca5d9cd831',
        messagingSenderId: '1098350360228',
        projectId: 'assignment3-45f14'),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const WidgetTree(),
    );
  }
}
