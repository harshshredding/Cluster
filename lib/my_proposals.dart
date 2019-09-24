import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'proposal_details.dart';
import 'helper.dart';

class MyProposals extends StatefulWidget {
  MyProposalsState createState() {
    return MyProposalsState();
  }
}

/// Page that lists all the favorite events of the user
class MyProposalsState extends State<MyProposals> {
  FirebaseUser currentUser;
  Future<QuerySnapshot> proposalsFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyProposals();
  }

  void getMyProposals() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      currentUser = user;
      proposalsFuture = Firestore.instance
          .collection("kingdoms")
          .document(getUserOrganization(currentUser) ?? "")
          .collection('proposals')
          .where('user_id', isEqualTo: currentUser.uid)
          .getDocuments();
    });
  }

  // Deletes proposal AND all related information.
  void deleteProposal(String proposalId, BuildContext context) async {
    bool decision = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Proposal'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this proposal ?'),
                Text('ALL related information will be deleted'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      },
    );
    if (decision) {
      final DocumentReference proposalInProposalCollection = Firestore.instance
          .collection("kingdoms")
          .document(getUserOrganization(currentUser) ?? "")
          .collection('proposals')
          .document(proposalId);
      final DocumentReference proposalInUsersCollection = Firestore.instance
          .collection("kingdoms")
          .document(getUserOrganization(currentUser) ?? "")
          .collection('users')
          .document(currentUser.uid)
          .collection('proposals')
          .document(proposalId);
      try {
        QuerySnapshot chatsQueryResult = await Firestore.instance
            .collection("kingdoms")
            .document(getUserOrganization(currentUser) ?? "")
            .collection("chats")
            .where("proposal_id", isEqualTo: proposalId)
            .getDocuments();
        List<DocumentSnapshot> chatsToDelete = [];
        chatsToDelete.addAll(chatsQueryResult.documents);
        // We are removing all the chats that don't exist to prevent doing the
        // same check during the transaction because a failure in transaction
        // syntax causes an application CRASH. really bad on Google's part.
        chatsToDelete.retainWhere((DocumentSnapshot chat) {
          return chat.exists;
        });
        await Firestore.instance.runTransaction((Transaction t) async {
          DocumentSnapshot proposalEntry = await t.get(proposalInProposalCollection);
          DocumentSnapshot userEntry = await t.get(proposalInUsersCollection);
          if (proposalEntry != null) {
            await t.delete(proposalInProposalCollection);
          }
          if (userEntry != null) {
            await t.delete(proposalInUsersCollection);
          }
          for (DocumentSnapshot chat in chatsToDelete) {
            await t.delete(chat.reference);
          }
          return null;
        });
        print("Proposal sucessfully deleted");
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("Proposal sucessfully deleted"), backgroundColor: Colors.orange,));
      } catch (error) {
        print(error);
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('There was an error while deleting proposal :('), backgroundColor: Colors.red,));
      }
    }
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
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProposalScreen(
                                                        proposalId)));
                                      }),
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
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProposalScreen(
                                                        proposalId)));
                                      }),
                                ),
                              )
                            ],
                          );
                        }
                      },
                      future: Firestore.instance
                          .collection("kingdoms")
                          .document(getUserOrganization(currentUser) ?? "")
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
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerLeft,
                      child: IconButton(icon: Icon(Icons.delete), color: Colors.redAccent, onPressed: () {deleteProposal(proposalId, context);}),
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

  Widget createDefaultCard() {
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
                       Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 10, top: 10),
                            child:  CircleAvatar(
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
                             "loading",
                              style: TextStyle(fontSize: 15),
                            ),
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 0, bottom: 5),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                onPressed: () {},
                            ),
                            )
                          )
                        ],
                      )
                      ,
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
                      child: Text("Loading",
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
                      child: Text("Loading",
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
        if (currProposal.data != null) {
          return createCard(
              currProposal.data['title'] ?? "",
              currProposal.data['summary'] ?? "",
              currProposal.data['user_id'] ?? "",
              currProposal.documentID ?? "",
              context
          );
        } else {
          return createDefaultCard();
        }
      },
      itemCount: proposals.length,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Proposals"),
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
          future: proposalsFuture),
    );
  }
}
