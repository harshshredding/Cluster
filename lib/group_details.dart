import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'proposals_for_group.dart';
import 'add_proposal.dart';

class GroupDetails extends StatefulWidget {
  final String groupId;

  GroupDetails(this.groupId);

  GroupDetailsState createState() {
    return GroupDetailsState();
  }
}

class GroupDetailsState extends State<GroupDetails> {
  bool shouldShowFullText = false;
  String groupDescriptionText;
  Future<DocumentSnapshot> future;

  void initState() {
    super.initState();
    this.future =
        Firestore.instance.collection("groups").document(widget.groupId).get();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              String groupDescriptionText = asyncSnapshot.data.data['purpose'];
              String rules = asyncSnapshot.data.data['rules'] ?? "";
              int trimEnd = (groupDescriptionText.length < 100)
                  ? groupDescriptionText.length
                  : 100;

              String groupInfoShort = shouldShowFullText
                  ? groupDescriptionText
                  : groupDescriptionText.substring(0, trimEnd) + " ... ";
              return Scaffold(
                appBar: AppBar(
                  title: Text(asyncSnapshot.data.data["title"]),
                ),
                body: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 2),
                      child: shouldShowFullText
                          ? Column(
                              children: <Widget>[
                                Text(
                                  "Purpose",
                                  style: TextStyle(
                                      fontFamily: "Trajan Pro", fontSize: 15),
                                ),
                                Text(groupDescriptionText + "\n",
                                    style: TextStyle(
                                        fontFamily: "Trajan Pro",
                                        fontSize: 15)),
                                Text(
                                  "Rules",
                                  style: TextStyle(
                                      fontFamily: "Trajan Pro", fontSize: 15),
                                ),
                                Text(rules)
                              ],
                            )
                          : Text(groupInfoShort + "\n",
                              style: TextStyle(
                                  fontFamily: "Trajan Pro", fontSize: 15)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return AddProposalScreen(preSelectedGroups: [
                                  asyncSnapshot.data.data['title']
                                ]);
                              }));
                            },
                            child: Text("Add Proposal"),
                            color: Colors.brown,
                          ),
                        ),
                        Expanded(
                          child: Container(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    shouldShowFullText = !shouldShowFullText;
                                  });
                                },
                                icon: shouldShowFullText
                                    ? Icon(Icons.keyboard_arrow_up)
                                    : Icon(Icons.keyboard_arrow_down),
                              )),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Flexible(
                        child: ProposalsForOneGroup(
                            asyncSnapshot.data.data["title"]))
                  ],
                ),
              );
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
                            color: index.isEven ? Colors.brown : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ));
              break;
          }
        },
        future: this.future);
  }
}
