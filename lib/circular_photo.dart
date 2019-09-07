import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart';

/// Represents the avatar photo of the user.
/// Takes a userId and the radius of the photo
/// If userId == null, default photo is shown.
/// Clicking on this photo redirects to user profile.
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
            return CircleAvatar(
              radius: widget.radius,
              backgroundImage: AssetImage('images/default_event.jpg'),
              backgroundColor: Colors.transparent,
            );
          }
        } else {
          return CircleAvatar(
            radius: widget.radius,
            backgroundImage: AssetImage('images/default_event.jpg'),
            backgroundColor: Colors.transparent,
          );
        }
      },
      future: userFuture,
    );
  }
}

/// Represents a circular photo with default image.
class DefaultCircularPhoto extends StatelessWidget {
  final double radius;

  DefaultCircularPhoto(this.radius);

  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: this.radius,
      backgroundImage: AssetImage('images/default_event.jpg'),
      backgroundColor: Colors.transparent,
    );
  }
}
