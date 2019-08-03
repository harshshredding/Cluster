import 'package:flutter/material.dart';
import 'proposals.dart';

class Home extends StatefulWidget {
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    Proposals(),
    Center(child: Text("lo", style: TextStyle(color: Colors.white)))
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kluzter"),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
              icon: Icon(Icons.add_box, color: Colors.white,),
              onPressed: () {
                Navigator.pushNamed(context, '/addEvent',
                    arguments: ModalRoute.of(context).settings.arguments);
              },
            ),
          )
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          onTap: _onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              title: Text('chat'),
            )
          ]
      )
    );
  }
}
