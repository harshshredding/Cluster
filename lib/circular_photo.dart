import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CircularPhoto extends StatelessWidget {
  final String userId;

  CircularPhoto(this.userId);

  Widget build(BuildContext context) {
    return FutureBuilder(builder:
      (BuildContext context, AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done) {
          print(userId);
          if (userId != null) {
            return CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(asyncSnapshot.data.data['photo_url']),
              backgroundColor: Colors.transparent,
            );
          } else {
            return Text("Error");
          }
        } else {
          return CircularProgressIndicator();
        }
      },
      future: Firestore.instance.collection("users").document(userId).get(),
    );
  }
}