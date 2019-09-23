import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// This class represents a data object that
/// contains the logged in user's full name.
class UserId {
  final String userId;
  UserId(this.userId);
}

/// Event Without Image
class Event {
  final String id;
  final GeoPoint geoPoint;
  final String title;
  final String summary;
  final String date;
  final String time;
  final String userDisplayName;
  final String userPhotoUrl;
  final String eventImageUrl;
  final String address;
  final String creatorId;

  Event(this.id, this.geoPoint, this.title, this.summary, this.date, this.time,
    this.userDisplayName, this.userPhotoUrl, this.eventImageUrl, this.address, this.creatorId);
}

/// Use this when you want to show the loading icon.
class LoadingSpinner extends StatelessWidget {
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        itemBuilder: (_, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color:
              index.isEven ? Colors.brown : Colors.grey,
            ),
          );
        },
      ),
    );
  }
}

/// If the field exists in the snapshot result,
/// create a widget using the given "factory" method.
Widget createIfFieldExists(DocumentSnapshot snapshot, List<String> fields, Function factory) {
  for (String field in fields) {
    if (snapshot.data[field] == null) {
      return Container(height: 0, width: 0,);
    }
  }
  return factory(snapshot);
}

/// Returns the given `attribute` from snapshot.
/// If snapshot's data field is null, returns "".
String safeAccess(DocumentSnapshot snapshot, String attribute) {
  if (snapshot.data != null) {
    if (snapshot.data[attribute] != null) {
      return snapshot.data[attribute];
    }
  }
  return "";
}

/// returns the organization of `givenUser`.
/// Returns null when the organization is not found, or an error occurs.
String getUserOrganization(FirebaseUser givenUser) {
  if (givenUser != null) {
    String userEmail = givenUser.email;
    int positionOfAt = userEmail.indexOf("@");
    if (positionOfAt != -1) {
      String organization = userEmail.substring(positionOfAt);
      return organization;
    }
  }
  return null;
}