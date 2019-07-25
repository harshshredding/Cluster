// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';
import 'package:intl/intl.dart';

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
        appBar: AppBar(
          bottom: tabBar,
        ),
        body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
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
        height: 300,
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
        height: 300,
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
                                fontSize: 35.0, fontFamily: 'Heebo-Black'),
                          );
                        }),
                        padding: EdgeInsets.all(10),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(20, 2, 0, 2),
                        child:
                            createIfFieldExists(snapshot, 'date', (snapshot) {
                          return Row(
                            children: <Widget>[
                              Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(Icons.access_time),
                                  ),
                                  flex: 1,
                              ),
                              Expanded(
                                  child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(getCustomDateFormat(snapshot.data['date']) + " - " + snapshot.data['time'],
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontFamily: 'Heebo-Black')
                                          )
                                        ),
                                  flex: 7,
                              )
                            ],
                          );
                        }),
                        padding: EdgeInsets.all(4),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 20),
                        child:
                        createIfFieldExists(snapshot, 'time', (snapshot) {
                          return Text(getTimeRemaining(snapshot.data['date'], snapshot.data['time']),
                              style: TextStyle(
                                  fontSize: 15.0, fontFamily: 'Heebo-Black'));
                        }),
                        padding: EdgeInsets.fromLTRB(7, 0, 0, 0),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: createIfFieldExists(snapshot, 'summary',
                            (snapshot) {
                          return Text('SUMMARY',
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontFamily: 'Heebo-Black',
                                  color: Colors.grey));
                        }),
                        padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(20, 2, 0, 10),
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
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: createIfFieldExists(snapshot, 'summary',
                                (snapshot) {
                              return Text('ADDRESS',
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontFamily: 'Heebo-Black',
                                      color: Colors.grey));
                            }),
                        padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(20, 2, 0, 30),
                        child: createIfFieldExists(snapshot, 'address',
                            (snapshot) {
                          return Text(snapshot.data['address'],
                              style: TextStyle(
                                  fontSize: 15.0, fontFamily: 'Heebo-Black',
                              ));
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

  String getCustomDateFormat(String date) {
    DateTime dateTime = DateTime.parse(date);
    DateFormat getMonth = new DateFormat('MMMM');
    DateFormat getDay = new DateFormat('d');
    String month = getMonth.format(dateTime);
    String day_num = getDay.format(dateTime);
    return month + " " + day_num;
  }

  String getTimeRemaining(String date, String time) {
    DateTime now = DateTime.now();
    DateTime _date = DateTime.parse(date);
    int hours = int.parse(time.split(":")[0]);;
    int minutes = int.parse(time.split(":")[1]);
    DateTime givenDateTime = _date.add(Duration(hours: hours, seconds: minutes));
    Duration diff = givenDateTime.difference(now);
    if (diff.inDays < 0 || diff.inHours < 0 || diff.inSeconds < 0) {
      int diffDaysAbsolute = -diff.inDays;
      int diffHoursAbsolute = -diff.inHours;
      if ((diffDaysAbsolute > 0)  && (diffDaysAbsolute < 8)) {
        return (diffDaysAbsolute).toString() + " days ago";
      } else if ((diffDaysAbsolute == 0) && (diffHoursAbsolute != 0)) {
        return (diffHoursAbsolute).toString() + " hours ago";
      }
    } else {
      if ((diff.inDays > 0)  && (diff.inDays < 8)) {
        return "in " + (diff.inDays).toString() + " days";
      } else if ((diff.inDays == 0) && (diff.inHours != 0)) {
        return "in " + (diff.inHours).toString() + " hours";
      }
    }
    return "";
  }
}
