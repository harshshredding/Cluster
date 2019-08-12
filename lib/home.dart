import 'package:flutter/material.dart';
import 'proposals.dart';
import 'user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_chats.dart';
import 'groups.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Home extends StatefulWidget {
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  int _currentIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> _children;

  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription<IosNotificationSettings> iosSubscription;

  void initState() {
    super.initState();
  }
  
  _saveDeviceToken() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String fcmToken = await _fcm.getToken();
    DocumentReference tokenDocument = Firestore.instance.collection("users")
        .document(user.uid).collection("tokens").document(fcmToken);
    await tokenDocument.setData({
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem
    }
    );
  }

  HomeState() {
    _children = [
      Groups(),
      Proposals(List<String>(), updateProposalsCallback),
      MyChats()
    ];
  }

  void updateProposalsCallback(List<String> filters) {
    print(filters);
    setState(() {
      _children[1] = Proposals(filters, updateProposalsCallback);
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 40),
              child: ListTile(
                title: Text("My Info"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserProfile(true)));
                },
              ),
            )
            ,
            ListTile(
              title: Text("My Proposals"),
              onTap: () async {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/my_proposals");
              },
            ),
            ListTile(
              title: Text("Log Out"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.person, color: Colors.white,), onPressed: () {
          _scaffoldKey.currentState.openDrawer();
        }),
        title: Text("CoffeeShop"),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
            child: RaisedButton(
              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: EdgeInsets.all(0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 12,
              color: Colors.grey.shade800,
              child: Row( children: <Widget>[
                Icon(Icons.add, size: 20,),
                Text("proposal", style: TextStyle(fontSize: 10)),
              ],),
              onPressed: () {
                Navigator.pushNamed(context, '/addProposal',
                    arguments: ModalRoute.of(context).settings.arguments);
              },
            ),
          )
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey.shade800,
          onTap: _onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              title: Text('groups'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text('feed'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              title: Text('chat'),
            ),
          ]
      )
    );
  }
}
