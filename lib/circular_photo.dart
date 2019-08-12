import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart';


class CircularPhoto extends StatefulWidget {
  final String userId;
  final double radius;

  CircularPhoto(this.userId, this.radius);
  CircularPhotoState createState() {
    return CircularPhotoState();
  }
}

class CircularPhotoState extends State<CircularPhoto> {

  Future<DocumentSnapshot> userFuture;

  initState() {
    super.initState();
    userFuture = Firestore.instance.collection("users").document(widget.userId).get();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done) {
          print(widget.userId);
          if (widget.userId != null) {
            return GestureDetector(
              child: CircleAvatar(
                radius: widget.radius,
                backgroundImage:
                    NetworkImage(asyncSnapshot.data.data['photo_url']),
                backgroundColor: Colors.transparent,
              ),
              onTap: () {
                Navigator.of(context).push<void>(
                    MaterialPageRoute(
                        builder: (context) => UserProfile(false, userDocumentId : widget.userId),
                        fullscreenDialog: true
                    )
                );
              },
            );
          } else {
            return Text("Error");
          }
        } else {
          return Container(height: 0, width: 0,);
        }
      },
      future: userFuture,
    );
  }
}
