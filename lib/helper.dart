import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This class represents a data object that
/// contains the logged in user's full name.
class UserId {
  final String userId;
  UserId(this.userId);
}

/// If the field exists in the snapshot result,
/// create a widget using the given "factory" method.
Widget createIfFieldExists(DocumentSnapshot snapshot, List<String> fields, factory) {
  for (String field in fields) {
    if (snapshot.data[field] == null) {
      return Container(height: 0, width: 0,);
    }
  }
  return factory(snapshot);
}

/// Checks if the attribute exists. If not, return empty string.
String notNull(DocumentSnapshot snapshot, String attribute) {
  String result = (snapshot.data[attribute] != null) ? snapshot.data[attribute] : "";
  return result;
}