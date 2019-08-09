import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'group_details.dart';

class Groups extends StatefulWidget {
  GroupsState createState() {
    return GroupsState();
  }
}

class GroupsState extends State<Groups> {
  List<Widget> getGroupTiles(List<DocumentSnapshot> groupSnaps) {
    List<Widget> result = List<Widget>();
    if (groupSnaps == null || groupSnaps.isEmpty) {
      return result;
    }
    for (DocumentSnapshot groupSnap in groupSnaps) {
      result.add(
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
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
              )
          ),
        )
      );
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
          child: FutureBuilder(
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
                switch (asyncSnapshot.connectionState) {
                  case ConnectionState.done:
                    return GridView.count(
                        crossAxisCount: 2,
                        children: getGroupTiles(asyncSnapshot.data.documents));
                    break;
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  default:
                    return Container(
                        margin: EdgeInsets.only(top: 25),
                        child: Center(
                          child: SpinKitFadingCircle(
                            itemBuilder: (_, int index) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      index.isEven ? Colors.brown : Colors.grey,
                                ),
                              );
                            },
                          ),
                        ));
                    break;
                }
              },
              future: Firestore.instance.collection("groups").getDocuments()))
    ]);
  }
}
