
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'Pages/FirstPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCkGQ8wNEx6kfHif77NG-DSHgD2HYug320",
            appId: "1:796613698658:web:658acd1fecf115b281dd3b",
            messagingSenderId: "796613698658",
            projectId: "chatapp-6f684"));
  }else
    {
      await Firebase.initializeApp();
    }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Firstpage(),
    );
  }
}
