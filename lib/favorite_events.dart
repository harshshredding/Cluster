import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'helper.dart';
import 'event_details.dart';

/// Page that lists all the favorite events of the user
class FavoritesList extends StatelessWidget {
  Future<QuerySnapshot> getEvents() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return Firestore.instance
        .collection("users")
        .document(user.uid)
        .collection("interested_in_going")
        .getDocuments();
  }

  Widget buildCard(String title, String summary, context, String documentId) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: GestureDetector(child: Card(
        child: Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(title),
                subtitle: Text(summary),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).push<void>(CupertinoPageRoute(
            builder: (context) => DetailsScreen(documentId, Firestore.instance),
            fullscreenDialog: true));
      },),
      decoration: new BoxDecoration(boxShadow: [
        new BoxShadow(
          color: Colors.grey,
          blurRadius: 10.0,
        ),
      ]),
    );
  }

  Widget buildCardsList(QuerySnapshot querySnapshot, context) {
    List<DocumentSnapshot> events = querySnapshot.documents;
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        Future<DocumentSnapshot> eventFuture = Firestore.instance
            .collection("events")
            .document(events[index].data["event_id"])
            .get();
        return FutureBuilder(
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> asyncSnap) {
            switch (asyncSnap.connectionState) {
              case ConnectionState.done:
                {
                  return buildCard(asyncSnap.data.data["title"],
                      asyncSnap.data.data["summary"], context, asyncSnap.data.documentID);
                }
                break;
              case ConnectionState.active:
              case ConnectionState.waiting:
              case ConnectionState.none:
              default:
                return CircularProgressIndicator();
                break;
            }
          },
          future: eventFuture,
        );
      },
      itemCount: events.length,
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
        future: getEvents());
  }
}
