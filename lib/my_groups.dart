import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'group_details.dart';
import 'dart:async';
import 'helper.dart';
import 'edit_group.dart';

class MyGroups extends StatefulWidget {
  MyGroupsState createState() {
    return MyGroupsState();
  }
}

class MyGroupsState extends State<MyGroups> {
  Future<QuerySnapshot> getMyGroups() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    return Firestore.instance
        .collection("kingdoms")
        .document(getUserOrganization(currentUser) ?? "")
        .collection('groups')
        .where('user_id', isEqualTo: currentUser.uid)
        .getDocuments();
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
        child: Stack(
          children: <Widget>[
            Container(
                margin: EdgeInsets.all(1),
                color: Colors.brown.shade400,
                child: Center(
                  child: Text(
                    groupSnap.data["title"],
                    style: TextStyle(fontFamily: "AmaticSC", fontSize: 50),
                  ),
                )),
            Container(
              alignment: Alignment.bottomRight,
              margin: EdgeInsets.only(right: 5),
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return EditGroupScreen(
                            groupSnap.data['title'] ?? '',
                            groupSnap.data['purpose'] ?? '',
                            groupSnap.data['rules'] ?? '',
                            groupSnap.documentID ?? ''
                        );
                      }));
                },
                child: Text("Edit", style: TextStyle(fontFamily: "AmaticSC", color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ));
    }
    return result;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Groups"),),
      body: Column(children: <Widget>[
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
        FutureBuilder<QuerySnapshot>(builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.done) {
            QuerySnapshot _allGroupsSnapshot = asyncSnapshot.data;
            return Flexible(
              child: (_allGroupsSnapshot != null)
                  ? GridView.count(
                  crossAxisCount: 2,
                  children: getGroupTiles(_allGroupsSnapshot.documents))
                  : Container(
                  margin: const EdgeInsets.only(top: 25),
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
            );
          } else {
            return LoadingSpinner();
          }
        },
          future: getMyGroups(),)
      ]),
    );
  }
}