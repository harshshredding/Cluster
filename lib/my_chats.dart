import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'circular_photo.dart';
import 'chat.dart';

class MyChats extends StatefulWidget {
  MyChatsState createState() {
    return MyChatsState();
  }
}

/// Page that lists all the favorite events of the user
class MyChatsState extends State<MyChats> {
  FirebaseUser currentUser;

  Future<QuerySnapshot> getChats() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    return Firestore.instance
        .collection("users")
        .document(currentUser.uid)
        .collection("chats")
        .getDocuments();
  }

  Widget buildCard(String proposalId, String photoUserId, String chatId) {
    print(proposalId);
    return Container(
      margin: EdgeInsets.only(top: 3, bottom: 3),
      child: GestureDetector(
        child: Card(
          child: Container(
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: FutureBuilder(
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.done) {
                    return ListTile(
                      leading: CircularPhoto(photoUserId),
                      title: Text(asyncSnapshot.data.data['title'], style: TextStyle(fontFamily: "Trajan Pro"),),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId)));
        }

        ,
      ),
    );
  }

  Widget buildCardsList(QuerySnapshot querySnapshot, context) {
    List<DocumentSnapshot> chats = querySnapshot.documents;
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
        return buildCard(currChat.data['proposal_id'], selectedUserId, chatId);
      },
      itemCount: chats.length,
    );
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              return buildCardsList(asyncSnapshot.data, context);
              break;
            case ConnectionState.active:
            case ConnectionState.waiting:
            case ConnectionState.none:
            default:
              return CircularProgressIndicator();
              break;
          }
        },
        future: getChats());
  }
}
