import 'package:flutter/material.dart';
import 'colors.dart';
import 'tag_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';

class Proposals extends StatefulWidget {
  ProposalsState createState() {
    return ProposalsState();
  }
}

class ProposalsState extends State<Proposals> {
  final Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _proposals = new List();
  List<StreamSubscription<QuerySnapshot>> _subscriptions = new List();
  List<String> _filters = List<String>();

  void initState() {
    super.initState();
    getProposalsAtStart();
  }

  List<Widget> createChips() {
    List<Widget> result = List();
    for (String filter in _filters) {
      result.add(Container(
        margin: EdgeInsets.only(left: 5, right: 5),
        child: Chip(
          label: Text(filter),
          backgroundColor: Colors.blueGrey,
          elevation: 4,
        ),
      ));
    }
    return result;
  }

  getProposalsAtStart() async {
    print("getProposalsAtStart");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userDataSnap =  await Firestore.instance.collection("users").document(user.uid).get();
    List<dynamic> filters = userDataSnap.data['filters'] ?? List<String>();
    if (filters != null) {
      for (String filter in filters) {
        _filters.add(filter);
      }
      getProposals();
    }
  }

  void getProposals() {
    _proposals.clear();
    _subscriptions.clear();
    if (_filters.isNotEmpty) {
      for (String filter in _filters) {
        var subscription = _firestore
            .collection("proposals")
            .where(filter, isEqualTo: true)
            .snapshots()
            .listen((QuerySnapshot snapshot) {
          List<DocumentSnapshot> newDocuments = snapshot.documents;
          List<DocumentSnapshot> thingsToAdd = List();
          for (DocumentSnapshot proposal in newDocuments) {
            bool proposalDoesntExist =
            _proposals.every((DocumentSnapshot oldProposal) {
              return (oldProposal.documentID != proposal.documentID);
            });
            if (proposalDoesntExist) {
              thingsToAdd.add(proposal);
            }
          }
          setState(() {
            _proposals.addAll(thingsToAdd);
          });
        });
        _subscriptions.add(subscription);
      }
    }
  }
  

  void configureFilter(BuildContext context) async {
    List<String> chosenFilters = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => TagSelector(_filters)));
    if (chosenFilters == null) {
      chosenFilters = List<String>();
    }
    _filters = chosenFilters ?? List<String>();
    getProposals();
    uploadUserFilters(chosenFilters);
  }

  uploadUserFilters(List<String> userFilters) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(user.uid).updateData({
      "filters" : userFilters
    });
  }

  static Future<void> createChatIfDoesntExist(String creatorUserId, String proposalId, BuildContext context) async {
    if (creatorUserId == null || proposalId == null) {
      var snackbar = new SnackBar(
        duration: new Duration(seconds: 2),
        content: Text("Some error occured.")
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } else {
      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      print(currentUser.uid);
      String chatId = proposalId + creatorUserId + currentUser.uid;
      DocumentReference currentUserReference = Firestore.instance
          .collection("users").document(currentUser.uid).collection("chats").document(chatId);
      DocumentReference creatorUserReference = Firestore
          .instance.collection("users").document(creatorUserId).collection("chats").document(chatId);
      DocumentReference chatReference = Firestore.instance.collection("chats").document(chatId);
      DocumentSnapshot chat = await chatReference.get();
      Timestamp currentTime = Timestamp.now();
      if (!chat.exists) {
        Map<String, dynamic> dataToWrite = {
          "id" : chatId,
          "proposal_id": proposalId,
          "creator_id": creatorUserId,
          "interested_id": currentUser.uid,
          "last_updated": currentTime
        };
        WriteBatch batch = Firestore.instance.batch();
        batch.setData(currentUserReference, dataToWrite);
        batch.setData(creatorUserReference, dataToWrite);
        batch.setData(chatReference, dataToWrite);
        await batch.commit();
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId, creatorUserId, proposalId)));
    }
  }

  static Widget createCard(String topic, String summary, String userId,
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
                                            .data.data["photo_url"] ?? ""),
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
                                  backgroundImage: AssetImage('images/default_event.jpg'),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  asyncSnapshot.data.data != null ? asyncSnapshot.data.data["name"] : "",
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
                                      createChatIfDoesntExist(
                                          userId, proposalId, context);
                                    },
                                  ),
                                  margin: EdgeInsets.only(
                                      left: 10, right: 5, top: 5, bottom: 5),
                                ),
                              )
                            ],
                          );
                        } else {
                          return Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10, top: 10),
                                child:  CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage('images/default_event.jpg'),
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
                                      createChatIfDoesntExist(
                                          userId, proposalId, context);
                                    },
                                  ),
                                  margin: EdgeInsets.only(
                                      left: 10, right: 5, top: 5, bottom: 5),
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

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 60,
          color: Colors.grey.shade900,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 14),
          child: Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(right: 10),
                  child: ButtonTheme(
                    minWidth: 30,
                    shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: RaisedButton(
                      elevation: 15,
                      onPressed: () {
                        configureFilter(context);
                      },
                      child: Text(
                        "SUBS",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: brownTextColor2,
                    ),
                  )),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: createChips(),
                ),
              )
            ],
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot currEvent = _proposals[index];
              String topic = currEvent.data["title"] ?? "";
              String summary = currEvent.data["summary"] ?? "";
              String userId = currEvent.data["user_id"];
              return createCard(topic, summary, userId, currEvent.documentID, context);
            },
            itemCount: _proposals.length,
          ),
        ),
      ],
    );
  }
}
