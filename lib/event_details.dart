// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cluster/helper.dart';

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


class DetailsInformationScreen extends StatefulWidget {
  final DocumentReference document;
  DetailsInformationScreen(this.document);
  DetailsInformationScreenState createState() => DetailsInformationScreenState();
}


class DetailsInformationScreenState extends State<DetailsInformationScreen> {

  bool _isInterested = false;

  initState() {
    super.initState();
    checkIfInterested();
  }

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

  void showInterest() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference documentReference = Firestore.instance.collection("events")
        .document(widget.document.documentID).collection("interested_users").document(user.uid);
    DocumentReference userDocReference = Firestore.instance.collection("users")
        .document(user.uid).collection("interested_in_going").document(widget.document.documentID);
    await Firestore.instance.runTransaction((Transaction tx) async {
      await tx.set(documentReference, {"user_id": user.uid});
      await tx.set(userDocReference, {"event_id": widget.document.documentID});
    });
    setState(() {
      _isInterested = !_isInterested;
    });
  }

  void showNotInterested() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference documentReference = Firestore.instance.collection("events")
        .document(widget.document.documentID).collection("interested_users").document(user.uid);
    DocumentReference userDocReference = Firestore.instance.collection("users")
        .document(user.uid).collection("interested_in_going").document(widget.document.documentID);
    await Firestore.instance.runTransaction((Transaction tx) async {
      await tx.delete(documentReference);
      await tx.delete(userDocReference);
    });
    setState(() {
      _isInterested = !_isInterested;
    });
  }

  void checkIfInterested() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot interestDocument = await widget.document
        .collection("interested_users").document(user.uid).get();
    setState(() {
      _isInterested = interestDocument.exists;
    });
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                        margin: EdgeInsets.only(right: 20),
                        alignment: Alignment.topRight,
                        child: (!_isInterested) ?
                        RaisedButton(
                            onPressed: showInterest,
                            child: Text('GOING'),
                        ):
                        RaisedButton(
                          onPressed: showNotInterested,
                          child: Text('GOING'),
                          color: Colors.green,
                        )
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(12, 10, 10, 10),
                        child:
                            createIfFieldExists(snapshot.data, ['title'], (snapshot) {
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
                            createIfFieldExists(snapshot.data, ['date'], (snapshot) {
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
                        createIfFieldExists(snapshot.data, ['time'], (snapshot) {
                          return Text(getTimeRemaining(snapshot.data['date'], snapshot.data['time']),
                              style: TextStyle(
                                  fontSize: 15.0, fontFamily: 'Heebo-Black'));
                        }),
                        padding: EdgeInsets.fromLTRB(7, 0, 0, 0),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: createIfFieldExists(snapshot.data, ['summary'],
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
                        child: createIfFieldExists(snapshot.data, ['summary'],
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
                        child: createIfFieldExists(snapshot.data, ['summary'],
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
                        child: createIfFieldExists(snapshot.data, ['address'],
                            (snapshot) {
                          return Text(snapshot.data['address'],
                              style: TextStyle(
                                  fontSize: 15.0, fontFamily: 'Heebo-Black',
                              ));
                        }),
                        padding: EdgeInsets.all(4),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 5),
                        child: createIfFieldExists(snapshot.data, ['summary'],
                                (snapshot) {
                              return Text('CREATED BY',
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontFamily: 'Heebo-Black',
                                      color: Colors.blueAccent));
                            }),
                        padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 20),
                        child: Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Row(
                          children: <Widget>[
                            FutureBuilder<DocumentSnapshot>(
                                future: Firestore.instance.collection("users")
                                    .document(snapshot.data.data['user_id']).get(),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.done:
                                      {
                                        if (snapshot.hasError) {
                                          return Container();
                                        } else {
                                          if (snapshot.data.exists) {
                                            return createIfFieldExists(
                                                snapshot.data, ['photo_url'], (
                                                snapshot) {
                                              return CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    snapshot.data['photo_url']),
                                                radius: 15,
                                              );
                                            }
                                            );
                                          }
                                        }
                                      }
                                    break;
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                    case ConnectionState.none:
                                      break;
                                  }
                                  return Container();
                                }),
                            createIfFieldExists(snapshot.data, ['user_display_name'],
                                    (snapshot) {
                                  return Container(
                                      margin: EdgeInsets.fromLTRB(10, 3, 0, 0),
                                      child: Text(snapshot.data['user_display_name'])
                                  );
                                })
                            ],
                          )
                        ),
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
      future: widget.document.get(),
    );
  }

  /// Returns converts the given date into format
  /// [Month] [Day]
  /// Here month is not the numeric month
  /// Day is the numeric day
  String getCustomDateFormat(String date) {
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(date);
    } on FormatException catch (e) {
      print("error parsing date");
      print(e);
    }
    DateFormat getMonth = new DateFormat('MMMM');
    DateFormat getDay = new DateFormat('d');
    String month = getMonth.format(dateTime);
    String day_num = getDay.format(dateTime);
    return month + " " + day_num;
  }

  /// Returns the string representation of the amount
  /// of time that remains (or has passed) till the start
  /// of the event.
  String getTimeRemaining(String date, String time) {
    if (date == null || time == null) {
      return "";
    }
    DateTime now;
    DateTime _date;
    int hours;
    int minutes;
    try {
      now = DateTime.now();
      _date = DateTime.parse(date);
      hours = int.parse(time.split(":")[0]);
      minutes = int.parse(time.split(":")[1]);
    } on FormatException catch (e) {
      print("time ["+ time + "]" + " date [" + date + "] could not be parsed "
          + " correctly.");
      print(e);
      return "";
    }
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
