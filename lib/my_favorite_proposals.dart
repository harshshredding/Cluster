import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'proposal_details.dart';
import 'proposals.dart';

class MyFavoriteProposals extends StatefulWidget {
  MyFavoriteProposalsState createState() {
    return MyFavoriteProposalsState();
  }
}

/// Page that lists all the favorite events of the user
class MyFavoriteProposalsState extends State<MyFavoriteProposals> {
  FirebaseUser currentUser;

  Future<QuerySnapshot> getMyProposals() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    return Firestore.instance
        .collection("users")
        .document(currentUser.uid)
        .collection("favorites")
        .getDocuments();
  }

  Widget createCard(String topic, String summary, String userId,
      String proposalId, BuildContext context) {
    return Card(
      shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20))),
      elevation: 5,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            color: Colors.brown,
            child: Text(
              "DISCUSSION",
              style: TextStyle(
                color: Colors.brown.shade200,
                fontSize: 15,
                fontFamily: 'CarterOne',
                letterSpacing: 3,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FutureBuilder(
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.done) {
                          return Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10, top: 10),
                                child: (userId != null)
                                    ? GestureDetector(
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                        asyncSnapshot
                                            .data.data["photo_url"] ??
                                            ""),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  onTap: () {
                                    if (asyncSnapshot.data.data != null) {
                                      if (asyncSnapshot.data.documentID !=
                                          null) {
                                        Navigator.of(context).push<void>(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserProfile(false,
                                                        userDocumentId:
                                                        asyncSnapshot
                                                            .data
                                                            .documentID),
                                                fullscreenDialog: true));
                                      }
                                    }
                                  },
                                )
                                    : CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                      'images/default_event.jpg'),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  asyncSnapshot.data.data != null
                                      ? asyncSnapshot.data.data["name"]
                                      : "",
                                  style: TextStyle(fontSize: 15),
                                ),
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 0, bottom: 5),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.chat, size: 20),
                                    onPressed: () async {
                                      ProposalsState.createChatIfDoesntExist(
                                          userId, proposalId, context);
                                    },
                                  ),
                                ),
                              )
                            ],
                          );
                        } else {
                          return Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10, top: 10),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                  AssetImage('images/default_event.jpg'),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "loading...",
                                  style: TextStyle(fontSize: 15),
                                ),
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 0, bottom: 5),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.chat, size: 20),
                                    onPressed: () async {
                                      ProposalsState.createChatIfDoesntExist(
                                          userId, proposalId, context);
                                    },
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                      },
                      future: Firestore.instance
                          .collection("users")
                          .document(userId)
                          .get(),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "MEET TO DISCUSS :",
                        style: TextStyle(
                            color: Colors.brown.shade100, fontSize: 13),
                      ),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 5),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(topic,
                          style: TextStyle(
                              fontSize: 15, fontFamily: "Trajan Pro")),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 0, bottom: 10),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "SUMMARY :",
                        style: TextStyle(
                            color: Colors.brown.shade100, fontSize: 13),
                      ),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 5),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(summary,
                          style: TextStyle(
                              fontSize: 15, fontFamily: "Trajan Pro")),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 0, bottom: 10),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      margin: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
    );
  }

  Widget buildCardsList(QuerySnapshot querySnapshot, context) {
    List<DocumentSnapshot> proposals = querySnapshot.documents;
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot currProposal = proposals[index];
        String proposalId = currProposal.data['id'];
        return FutureBuilder(
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
            switch (asyncSnapshot.connectionState) {
              case ConnectionState.done:
                DocumentSnapshot proposal = asyncSnapshot.data;
                return createCard(
                    proposal.data['title'],
                    proposal.data['summary'],
                    proposal.data['user_id'],
                    proposal.documentID,
                    context);
                break;
              case ConnectionState.active:
              case ConnectionState.waiting:
              case ConnectionState.none:
              default:
                return Container(width: 0, height: 0);
                break;
            }
          },
          future: Firestore.instance
              .collection("proposals")
              .document(proposalId)
              .get(),
        );
      },
      itemCount: proposals.length,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Favorite Proposals"),
      ),
      body: FutureBuilder(
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
            switch (asyncSnapshot.connectionState) {
              case ConnectionState.done:
                return buildCardsList(asyncSnapshot.data, context);
                break;
              case ConnectionState.active:
              case ConnectionState.waiting:
              case ConnectionState.none:
              default:
                return Center(
                  child: SpinKitFadingCircle(
                    itemBuilder: (_, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.brown : Colors.grey,
                        ),
                      );
                    },
                  ),
                );
                break;
            }
          },
          future: getMyProposals()),
    );
  }
}
