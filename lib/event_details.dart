// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InfoView extends StatelessWidget {
  final String id;

  const InfoView(this.id);

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text("hello"),
              Spacer(),
              Text("hello"),
            ],
          ),
          SizedBox(height: 8),
          Text("he"),
          SizedBox(height: 8),
          Text("he"),
          SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Save'),
            ],
          ),
        ],
      ),
    );
  }
}

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
    return Scaffold(
        body: FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Align(
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Container(
                  child: Image.asset("images/meWithLongHair.jpeg",
                      height: 300, fit: BoxFit.cover),
                  padding: EdgeInsets.all(10),
                ),
                Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(10.0),
                        child: createIfFieldExists(snapshot, 'title', (snapshot) {
                          return Text(
                            snapshot.data['title'],
                            style: TextStyle(
                                fontSize: 25.0,
                                fontFamily: 'Heebo-Black'),
                          );
                        }),
                        padding: EdgeInsets.all(10),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(20.0),
                        child: createIfFieldExists(snapshot, 'summary', (snapshot) {
                          return Text(snapshot.data['summary'],
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Heebo-Black'));
                        }),
                        padding: EdgeInsets.all(4),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(20.0),
                        child: createIfFieldExists(snapshot, 'date', (snapshot) {
                          return Text(snapshot.data['date'],
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Heebo-Black'));
                        }),
                        padding: EdgeInsets.all(4),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(20.0),
                        child: createIfFieldExists(snapshot, 'time', (snapshot) {
                          return Text(snapshot.data['time'],
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Heebo-Black'));
                        }),
                        padding: EdgeInsets.all(4),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(20.0),
                        child: createIfFieldExists(snapshot, 'address', (snapshot) {
                          return Text(snapshot.data['address'],
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Heebo-Black'));
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
    ));
  }

  Widget createIfFieldExists(snapshot, String field, factory) {
    if (snapshot.data[field] != null) {
      print(snapshot.data[field]);
      return factory(snapshot);
    } else {
      return Container(width: 0, height: 0);
    }
  }
}
