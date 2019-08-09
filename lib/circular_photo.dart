import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart';

class CircularPhoto extends StatelessWidget {
  final String userId;
  final double radius;

  CircularPhoto(this.userId, this.radius);

  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done) {
          print(userId);
          if (userId != null) {
            return GestureDetector(
              child: CircleAvatar(
                radius: this.radius,
                backgroundImage:
                    NetworkImage(asyncSnapshot.data.data['photo_url']),
                backgroundColor: Colors.transparent,
              ),
              onTap: () {
                Navigator.of(context).push<void>(
                    MaterialPageRoute(
                        builder: (context) => UserProfile(false, userDocumentId : this.userId),
                        fullscreenDialog: true
                    )
                );
              },
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
