import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'group_details.dart';
import 'dart:async';

class Groups extends StatefulWidget {
  GroupsState createState() {
    return GroupsState();
  }
}

class GroupsState extends State<Groups> {
  StreamSubscription<QuerySnapshot> _subscription;
  QuerySnapshot _allGroupsSnapshot;

  initState() {
    super.initState();
    _subscription = Firestore.instance
        .collection("groups")
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _allGroupsSnapshot = snapshot;
      });
    });
  }

  List<Widget> getGroupTiles(List<DocumentSnapshot> groupSnaps) {
    List<Widget> result = List<Widget>();
    if (groupSnaps == null || groupSnaps.isEmpty) {
      return result;
    }
    for (DocumentSnapshot groupSnap in groupSnaps) {
      result.add(GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return GroupDetails(groupSnap.documentID);
          }));
        },
        child: Container(
            margin: EdgeInsets.all(1),
            color: Colors.brown.shade400,
            child: Center(
              child: Text(
                groupSnap.data["title"],
                style: TextStyle(fontFamily: "AmaticSC", fontSize: 50),
              ),
            )),
      ));
    }
    return result;
  }

  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 10, right: 5),
        alignment: Alignment.center,
        child: RaisedButton(
          elevation: 10,
          color: brownBackground,
          onPressed: () {
            Navigator.pushNamed(context, "/add_group");
          },
          child: Text("Create Group"),
          shape:
              BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      Divider(
        color: Colors.grey,
      ),
      Flexible(
        child: ((_allGroupsSnapshot != null) && (_subscription != null))
            ? GridView.count(
                crossAxisCount: 2,
                children: getGroupTiles(_allGroupsSnapshot.documents))
            : Container(
                margin: EdgeInsets.only(top: 25),
                child: Center(
                  child: SpinKitFadingCircle(
                    itemBuilder: (_, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.brown : Colors.grey,
                        ),
                      );
                    },
                  ),
                )),
      )
    ]);
  }
}
