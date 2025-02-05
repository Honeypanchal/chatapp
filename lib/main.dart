import 'package:chatapp/Pages/ChatLayout/ChatPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupChatPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDescription.dart';
import 'package:chatapp/Pages/GroupChatLayout/GroupDisplayPage.dart';
import 'package:chatapp/Pages/GroupChatLayout/UpdateGroupPermissions.dart';
import 'package:chatapp/Pages/Profile/Profile.dart';
import 'package:chatapp/Pages/statuspage.dart';
import 'package:chatapp/pages/GroupChatLayout/AddNewMembersToGroup.dart';
import 'package:chatapp/pages/GroupChatLayout/NewGroup.dart';
import 'package:chatapp/pages/GroupChatLayout/NewGroupDefinition.dart';
import 'package:chatapp/Pages/Authentication/FirstPage.dart';
import 'package:chatapp/services/auth_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Pages/GroupChatLayout/GroupPermissions.dart';
import 'models/CustomClass.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
      apiKey: "AIzaSyCkGQ8wNEx6kfHif77NG-DSHgD2HYug320",
      appId: "1:796613698658:web:658acd1fecf115b281dd3b",
      messagingSenderId: "796613698658",
      projectId: "chatapp-6f684",
    )
        : null,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _user;
  CustomClass? foundUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    _user = auth.currentUser;

    if (_user != null) {
      final found = await getUserDetails(_user!.uid);
      setState(() {
        foundUser = found;
      });
      print(foundUser!.firstName);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _isLoading
          ? const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "Redirecting you to your chats...",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      )
          : _user != null
          ? ChatPage(currentUser: foundUser!)
          : Firstpage(),
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;
        switch (settings.name) {
          case '/newGroup':
            return MaterialPageRoute(
              builder: (context) => NewGroup(currentUser: args!["currentUser"]),
            );
          case '/chatPage':
            return MaterialPageRoute(
              builder: (context) => ChatPage(currentUser: args!["currentUser"]),
            );
          case '/newGroupDefinition':
            return MaterialPageRoute(
              builder: (context) => NewGroupDefinition(
                members: args!["members"],
                createdBy: args["currentUser"],
              ),
            );
          case '/statusPage':
            return MaterialPageRoute(builder: (context) => StatusPage());
          case '/groupDisplay':
            return MaterialPageRoute(
              builder: (context) => GroupDisplayPage(
                currentUser: args!["currentUser"],
              ),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (context) => Profile(currentUser: args!["currentUser"]),
            );

          case '/groupPermissions':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => GroupPermissions(
                groupSettings: args['groupSettings'],
                sendMessages: args['sendMessages'],
                addOtherMembers: args['addOtherMembers'],
                admins: args['admins'],
                members: args['members'],
                currentUser: args['currentUser'],
              ),
            );

          case '/groupchat':
            return MaterialPageRoute(
                builder: (context) => Groupchatpage(
                    groupId: args!['groupId'],
                    currentUser: args['currentUser']));
          case '/groupDescription':
            return MaterialPageRoute(
                builder: (context) => GroupDescription(
                    groupId: args!['groupId'],
                    currentUser: args['currentUser']));
          case '/addNewMembers':
            return MaterialPageRoute(
                builder: (context) => AddNewMembersToGroup(
                    existingMembers: args!['existingMembers'],
                    groupId: args['groupId']));
          case '/updateGroupPermissions':
            return MaterialPageRoute(
                builder: (context) => UpdateGroupPermissions(
                    groupSettings: args!['groupSettings'],
                    sendMessages: args['sendMessages'],
                    addOtherMembers: args['addOtherMembers'],
                    admins: args['admins'],
                    members: args['members'],
                    currentUser: args['currentUser'],
                    createdBy:args['createdBy']));
          default:
            return null;
        }
      },
    );
  }
}