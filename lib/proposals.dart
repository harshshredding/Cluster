import 'package:flutter/material.dart';
import 'colors.dart';
import 'tag_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';

class Proposals extends StatefulWidget {
  final List<String> _filters;
  final Function updateFilters;
  
  Proposals(this._filters, this.updateFilters);
  
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
    _filters = widget._filters;
    getProposals();
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
  
  void getProposals() {
    _proposals.clear();
    _subscriptions.clear();
    if (_filters.isEmpty) {
      var subscription = _firestore
          .collection("proposals")
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
    } else {
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
    widget.updateFilters(chosenFilters);
    _filters = chosenFilters;
    getProposals();
  }

  Future<void> createChatIfDoesntExist(String creatorUserId, String proposalId, BuildContext context) async {
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
      if (!chat.exists) {
        Map<String, dynamic> dataToWrite = {
          "id" : chatId,
          "proposal_id": proposalId,
          "creator_id": creatorUserId,
          "interested_id": currentUser.uid
        };
        await Firestore.instance.runTransaction((Transaction t) async {
          t.set(currentUserReference, dataToWrite);
          t.set(creatorUserReference, dataToWrite);
          t.set(chatReference, dataToWrite);
          return null;
        });
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId)));
    }
  }

  Widget createCard(String topic, String summary, String userId, String proposalId, BuildContext context) {
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
              Flexible (
                flex: 17,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10, top: 10),
                        child: (userId != null)
                            ? FutureBuilder(
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot>
                              asyncSnapshot) {
                            if (asyncSnapshot.connectionState == ConnectionState.done) {
                              String photoUrl =
                              asyncSnapshot.data.data["photo_url"];
                              return GestureDetector(
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(photoUrl),
                                  backgroundColor: Colors.transparent,
                                ),
                                onTap: () {
                                  if (asyncSnapshot.data.data != null) {
                                    if (asyncSnapshot.data.documentID != null) {
                                      Navigator.of(context).push<void>(
                                          MaterialPageRoute(
                                            builder: (context) => UserProfile(false, userDocumentId:asyncSnapshot.data.documentID),
                                            fullscreenDialog: true
                                          )
                                      );
                                    }
                                  }
                                },
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                          future: Firestore.instance
                              .collection("users")
                              .document(userId)
                              .get(),
                        )
                            : CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              "https://firebasestorage.googleapis.com/v0/b/cluster-c7373.appspot.com/o/uglBgoTL4wbDe7F3vOJSYAsNAJq1d7ad0d20-b750-11e9-8d3f-77436f189394?alt=media&token=f856aba3-f8e5-4ee2-b3a6-26ed4ed823f9"),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Harsh Verma",
                          style: TextStyle(fontSize: 15),
                        ),
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 0, bottom: 5),
                      )
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "TOPIC :",
                      style: TextStyle(
                          color: Colors.brown.shade100, fontSize: 13),
                    ),
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 5),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(topic, style: TextStyle(fontSize: 15, fontFamily: "Trajan Pro")),
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
                    child: Text(summary, style: TextStyle(fontSize: 15, fontFamily: "Trajan Pro")),
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 0, bottom: 10),
                  )
                ],
              ),),
              Flexible(
                flex: 4,
                child: Container(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.chat, size: 25),
                    onPressed: () async {
                        createChatIfDoesntExist(userId, proposalId, context);
                      },
                  ),
                  margin:
                  EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
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
                        "FILTER",
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
