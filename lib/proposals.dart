import 'package:flutter/material.dart';
import 'colors.dart';
import 'tag_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';

class Proposals extends StatefulWidget {
  final bool dontShowFilterBar;
  final String groupName;

  Proposals()
      : this.dontShowFilterBar = false,
        groupName = null;

  Proposals.withoutFilter(this.groupName) : this.dontShowFilterBar = true;

  ProposalsState createState() {
    return ProposalsState();
  }
}

class ProposalsState extends State<Proposals> {
  final Firestore _firestore = Firestore.instance;
  ListOfProposals _proposals = new ListOfProposals();
  List<StreamSubscription<QuerySnapshot>> _proposalSubscriptions = new List();
  List<String> _filters = List<String>();
  StreamSubscription<QuerySnapshot> _favoritesSubscription;

  void initState() {
    super.initState();
    if (widget.dontShowFilterBar) {
      if (widget.groupName != null) {
        getProposalsForGroup(widget.groupName);
      }
    } else {
      getProposalsAtStart();
    }
    getFavoritesSubscription();
  }

  /// Creates group chips to display the group
  /// the user is subscribed to.
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

  /// Display proposals of one group.
  void getProposalsForGroup(String groupName) {
    if (widget.groupName != null) {
      _filters.add(groupName);
      getProposals();
    }
  }

  void getFavoritesSubscription() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    // get favorites information and store subscription.
    _favoritesSubscription = Firestore.instance
        .collection("users")
        .document(user.uid)
        .collection("favorites")
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<DocumentSnapshot> favorites = snapshot.documents;
      if (favorites != null) {
        setState(() {
          _proposals.setFavorites(favorites);
        });
      }
    });
  }

  /// Used to display the proposals when the screen loads
  /// for the first time.
  void getProposalsAtStart() async {
    print("getProposalsAtStart");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userDataSnap =
        await Firestore.instance.collection("users").document(user.uid).get();

    List<dynamic> filters = userDataSnap.data['filters'] ?? List<String>();
    if (filters != null) {
      for (String filter in filters) {
        _filters.add(filter);
      }
      getProposals();
    }
  }

  /// The main method which gets all the subscriptions that are used to
  /// update add proposals on the screen.
  void getProposals() {
    _proposals.clear();
    _proposalSubscriptions.clear();
    if (_filters.isNotEmpty) {
      Timestamp timeNow = Timestamp.now();
      for (String filter in _filters) {
        var subscription = _firestore
            .collection("proposals")
            .where(filter, isEqualTo: true)
            //.where('expiry', isGreaterThan: timeNow)
            .snapshots()
            .listen((QuerySnapshot snapshot) {
          List<DocumentSnapshot> newDocuments = snapshot.documents;
          List<DocumentSnapshot> thingsToAdd = List();
          for (DocumentSnapshot proposal in newDocuments) {
            bool proposalDoesntExist =
                !_proposals.proposalExists(proposal.documentID);
            if (proposalDoesntExist) {
              thingsToAdd.add(proposal);
            }
          }
          setState(() {
            for (DocumentSnapshot thing in thingsToAdd) {
              _proposals.addProposal(thing);
            }
          });
        });
        _proposalSubscriptions.add(subscription);
      }
    }
  }

  /// Show the subscription choosing screen and upload filters.
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

  /// Upload the filters chosen by the user
  void uploadUserFilters(List<String> userFilters) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(user.uid)
        .updateData({"filters": userFilters});
  }

  static Future<void> createChatIfDoesntExist(
      String creatorUserId, String proposalId, BuildContext context) async {
    if (creatorUserId == null || proposalId == null) {
      var snackbar = new SnackBar(
          duration: new Duration(seconds: 2),
          content: Text("Some error occured."),
          backgroundColor: Colors.red,
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } else {
      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      print(currentUser.uid);
      String chatId = proposalId + creatorUserId + currentUser.uid;
      DocumentReference currentUserReference = Firestore.instance
          .collection("users")
          .document(currentUser.uid)
          .collection("chats")
          .document(chatId);
      DocumentReference creatorUserReference = Firestore.instance
          .collection("users")
          .document(creatorUserId)
          .collection("chats")
          .document(chatId);
      DocumentReference chatReference =
          Firestore.instance.collection("chats").document(chatId);
      DocumentSnapshot chat = await chatReference.get();
      Timestamp currentTime = Timestamp.now();
      if (!chat.exists) {
        Map<String, dynamic> dataToWrite = <String, dynamic>{
          "id": chatId,
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(chatId, creatorUserId)));
    }
  }

  Widget createCard(String topic, String summary, String userId,
      String proposalId, BuildContext context, bool isFavorite) {
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
                                  (asyncSnapshot.data != null) && (asyncSnapshot.data.data != null)
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
                                  child: Row(
                                    children: <Widget>[
                                      isFavorite
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.star,
                                                size: 20,
                                                color: Colors.yellow,
                                              ),
                                              onPressed: () async {
                                                FirebaseUser user =
                                                    await FirebaseAuth.instance
                                                        .currentUser();
                                                if (user != null) {
                                                  DocumentReference favDocRef =
                                                      Firestore.instance
                                                          .collection("users")
                                                          .document(user.uid)
                                                          .collection(
                                                              "favorites")
                                                          .document(proposalId);
                                                  try {
                                                    await favDocRef.delete();
                                                  } catch (err) {
                                                    print(err);
                                                    var snackbar = new SnackBar(
                                                        duration: new Duration(
                                                            seconds: 2),
                                                        content: Text(
                                                            "Error While Un-favoriting. Try Again."),
                                                      backgroundColor: Colors.red,
                                                    );
                                                    Scaffold.of(context)
                                                        .showSnackBar(snackbar);
                                                  }
                                                } else {
                                                  // TODO harsh please !!!
                                                }
                                              },
                                            )
                                          : IconButton(
                                              icon: Icon(Icons.star, size: 20),
                                              onPressed: () async {
                                                FirebaseUser user =
                                                    await FirebaseAuth.instance
                                                        .currentUser();
                                                if (user != null) {
                                                  DocumentReference favDocRef =
                                                      Firestore.instance
                                                          .collection("users")
                                                          .document(user.uid)
                                                          .collection(
                                                              "favorites")
                                                          .document(proposalId);
                                                  try {
                                                    await favDocRef.setData(
                                                        {"id": proposalId});
                                                  } catch (err) {
                                                    print(err);
                                                    var snackbar = new SnackBar(
                                                        duration: new Duration(
                                                            seconds: 2),
                                                        content: Text(
                                                            "Error While Favoriting. Try again."),
                                                        backgroundColor: Colors.red,
                                                    );
                                                    Scaffold.of(context)
                                                        .showSnackBar(snackbar);
                                                  }
                                                } else {
                                                  // TODO harsh please !!!
                                                }
                                              },
                                            ),
                                      IconButton(
                                        icon: Icon(Icons.chat, size: 20),
                                        onPressed: () async {
                                          createChatIfDoesntExist(
                                              userId, proposalId, context);
                                        },
                                      )
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.end,
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
        widget.dontShowFilterBar
            ? Container(
                width: 0,
                height: 0,
              )
            : Container(
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
              DocumentSnapshot currEvent = _proposals.get(index);
              String topic = currEvent.data["title"] ?? "";
              String summary = currEvent.data["summary"] ?? "";
              String userId = currEvent.data["user_id"];
              return createCard(topic, summary, userId, currEvent.documentID,
                  context, _proposals.isFavorite(currEvent.documentID));
            },
            itemCount: _proposals.size(),
          ),
        ),
      ],
    );
  }
}

/// Represents an ordered list of proposals that are sorted by
/// `created`. The list can also store data regarding which proposals
/// have been added to favorites by user.
class ListOfProposals {
  List<DocumentSnapshot> _proposals = <DocumentSnapshot>[];
  List<DocumentSnapshot> _favorites = <DocumentSnapshot>[];

  void clear() {
    _proposals.clear();
  }

  /// Higher the timestamp, lower the value
  /// null value is always more
  /// two null values are equal
  int compareProposals(DocumentSnapshot p1, DocumentSnapshot p2) {
    final Timestamp t1 = p1.data['created'];
    final Timestamp t2 = p2.data['created'];
    if (t1 == null && t2 != null) {
      return 1;
    } else if (t1 != null && t2 == null) {
      return -1;
    } else if (t1 == null && t2 == null) {
      return 0;
    } else {
      return -1*t1.compareTo(t2);
    }
  }

  void addProposal(DocumentSnapshot snapshot) {
    _proposals.add(snapshot);
    _proposals.sort(compareProposals);
  }

  int size() {
    return _proposals.length;
  }

  DocumentSnapshot get(int index) {
    if (index >= 0 && index < size()) {
      return _proposals[index];
    } else {
      return null;
    }
  }

  bool proposalExists(String proposalId) {
    for (int i = 0; i < _proposals.length; i++) {
      if (proposalId == _proposals[i].documentID) {
        return true;
      }
    }
    return false;
  }

  void setFavorites(List<DocumentSnapshot> favorites) {
    if (favorites != null) {
      _favorites = favorites;
    }
  }

  bool isFavorite(String proposalId) {
    for (DocumentSnapshot favSnap in _favorites) {
      if (favSnap.documentID == proposalId) {
        return true;
      }
    }
    return false;
  }
}
