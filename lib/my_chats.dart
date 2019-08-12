import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'circular_photo.dart';
import 'dart:async';
import 'chat.dart';

class MyChats extends StatefulWidget {
  MyChatsState createState() {
    return MyChatsState();
  }
}

/// Page that lists all the favorite events of the user
class MyChatsState extends State<MyChats> {
  FirebaseUser currentUser;
  QuerySnapshot chatSnapshots;
  StreamSubscription<QuerySnapshot> chatsSubscription;

  initState() {
    super.initState();
    getSubscription();
  }

  void getSubscription() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    chatsSubscription = Firestore.instance
        .collection("users")
        .document(currentUser.uid)
        .collection("chats").snapshots().listen((QuerySnapshot snapSnapshot) {
      setState(() {
        chatSnapshots = snapSnapshot;
      });
    }
    );
  }

  Widget buildCard(String proposalId, String photoUserId, String chatId, bool newMessageReceived) {
    print(proposalId);
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 1),
      child: GestureDetector(
        child: Card(
          child: Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            child: FutureBuilder(
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.done) {
                    return ListTile(
                      leading: CircularPhoto(photoUserId, 30),
                      title: Text(asyncSnapshot.data.data['title'], style: TextStyle(fontFamily: "Trajan Pro"),),
                      trailing: newMessageReceived ? Text("NEW", style: TextStyle(color: Colors.lightBlueAccent.shade100),) : Container(width: 0, height: 0,)
                    );
                } else {
                  return CircularProgressIndicator();
                }
              },
              future: Firestore.instance
                  .collection("proposals")
                  .document(proposalId)
                  .get(),
            ),
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId, photoUserId, proposalId)));
        }
        ,
      ),
    );
  }

  int compareChats(DocumentSnapshot snap1, DocumentSnapshot snap2) {
    if ((snap1.data['last_updated'] != null)
        && (snap2.data['last_updated'] != null)) {
      Timestamp t1 = snap1.data['last_updated'];
      Timestamp t2 = snap2.data['last_updated'];
      return -1*t1.compareTo(t2);
    } else if ((snap1.data['last_updated'] != null)) {
      return 1*(-1);
    } else if ((snap2.data['last_updated'] != null)) {
      return -1*(-1);
    } else {
      return snap1.documentID.compareTo(snap2.documentID)*(-1);
    }
  }

  Widget buildCardsList(QuerySnapshot querySnapshot, context) {
    List<DocumentSnapshot> chats = querySnapshot.documents;
    for (DocumentSnapshot chat in chats) {
      print(chat.data['last_updated']);
    }
    chats.sort(compareChats);
    print(chats.length);
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot currChat = chats[index];
        String creatorId = currChat.data['creator_id'];
        String interestedId = currChat.data['interested_id'];
        String chatId = currChat.data['id'];
        String selectedUserId;
        if (interestedId == currentUser.uid) {
          selectedUserId = creatorId;
        } else {
          selectedUserId = interestedId;
        }
        bool newMessageReceived = false;
        // If no message has been sent, don't show the NEW message.
        if (!((currChat['interested_seen'] == null) && (currChat['creator_seen'] == null))) {
          if (interestedId == currentUser.uid) {
            // We are the interested user
            Timestamp seenTimestamp = currChat['interested_seen'];
            Timestamp updateTimestamp = currChat['last_updated'];
            if (updateTimestamp != null) {
              if (seenTimestamp == null || seenTimestamp.compareTo(updateTimestamp) < 0) {
                newMessageReceived = true;
              }
            }
            selectedUserId = creatorId;
          } else {
            // We are the creator user
            Timestamp seenTimestamp = currChat['creator_seen'];
            Timestamp updateTimestamp = currChat['last_updated'];
            if (updateTimestamp != null) {
              if (seenTimestamp == null || seenTimestamp.compareTo(updateTimestamp) < 0) {
                newMessageReceived = true;
              }
            }
            selectedUserId = interestedId;
          }
        }
        return buildCard(currChat.data['proposal_id'], selectedUserId, chatId, newMessageReceived);
      },
      itemCount: chats.length,
    );
  }

  Widget build(BuildContext context) {
    Widget subTree =  (chatSnapshots != null) ?
        buildCardsList(chatSnapshots, context)
    :
        Center(child: CircularProgressIndicator(),);
    return subTree;
  }
}
