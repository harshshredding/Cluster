import 'package:flutter/material.dart';
import 'proposals.dart';
import 'user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'my_chats.dart';
import 'groups.dart';


class Home extends StatefulWidget {
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  int _currentIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> _children;


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
            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
              icon: Icon(Icons.add_box, color: Colors.white,),
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
