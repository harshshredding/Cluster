// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';

class DetailsScreen extends StatefulWidget {
  final String id;
  final Firestore firestore;

  DetailsScreen(this.id, this.firestore);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    DocumentReference document =
        widget.firestore.collection('events').document(widget.id);

    final tabBar = new TabBar(
      tabs: <Tab>[
        new Tab(icon: new Icon(Icons.description)),
        new Tab(icon: new Icon(Icons.chat)),
      ],
    );


    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar:  AppBar(
          bottom: tabBar,
        ),
        body:
        TabBarView(physics: NeverScrollableScrollPhysics(), children: [
          DetailsInformationScreen(document),
          Center(
            child: ChatScreen(widget.id),
          )
        ]),
      ),
    );
  }
}


class DetailsInformationScreen extends StatelessWidget {

  DocumentReference document;

  DetailsInformationScreen(this.document);

  Widget getEventImage(snapshot) {
    if (snapshot.data['download_url'] == null) {
      return Container(
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(10.0),
          child: Image.asset("images/default_event.jpg", fit: BoxFit.cover),
        ),
        padding: EdgeInsets.all(8),
        height: 400,
      );
    } else {
      String downloadUrl = snapshot.data['download_url'];
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(10.0),
          child: Image.network(
            downloadUrl,
            fit: BoxFit.cover,
          ),
        ),
        height: 400,
      );
    }
  }

  Widget createIfFieldExists(snapshot, String field, factory) {
    if (snapshot.data[field] != null) {
      print(snapshot.data[field]);
      return factory(snapshot);
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                getEventImage(snapshot),
                Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(10.0),
                        child:
                        createIfFieldExists(snapshot, 'title', (snapshot) {
                          return Text(
                            snapshot.data['title'],
                            style: TextStyle(
                                fontSize: 25.0, fontFamily: 'Heebo-Black'),
                          );
                        }),
                        padding: EdgeInsets.all(10),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(20.0),
                        child: createIfFieldExists(snapshot, 'summary',
                                (snapshot) {
                              return Text(snapshot.data['summary'],
                                  style: TextStyle(
                                      fontSize: 15.0, fontFamily: 'Heebo-Black'));
                            }),
                        padding: EdgeInsets.all(4),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(20.0),
                        child:
                        createIfFieldExists(snapshot, 'date', (snapshot) {
                          return Text(snapshot.data['date'],
                              style: TextStyle(
                                  fontSize: 15.0, fontFamily: 'Heebo-Black'));
                        }),
                        padding: EdgeInsets.all(4),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(20.0),
                        child:
                        createIfFieldExists(snapshot, 'time', (snapshot) {
                          return Text(snapshot.data['time'],
                              style: TextStyle(
                                  fontSize: 15.0, fontFamily: 'Heebo-Black'));
                        }),
                        padding: EdgeInsets.all(4),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(20.0),
                        child: createIfFieldExists(snapshot, 'address',
                                (snapshot) {
                              return Text(snapshot.data['address'],
                                  style: TextStyle(
                                      fontSize: 15.0, fontFamily: 'Heebo-Black'));
                            }),
                        padding: EdgeInsets.all(4),
                      )
                    ],
                  ),
                  color: Colors.white,
                ),
              ],
            ),
            color: Colors.blueGrey,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
      future: document.get(),
    );
  }
}

