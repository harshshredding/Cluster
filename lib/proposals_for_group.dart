import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';
import 'proposals.dart';

class ProposalsForOneGroup extends StatefulWidget {
  final String group;

  ProposalsForOneGroup(this.group);

  ProposalsForOneGroupState createState() {
    return ProposalsForOneGroupState();
  }
}

class ProposalsForOneGroupState extends State<ProposalsForOneGroup> {

  Widget build(BuildContext context) {
    return Proposals.withoutFilter(widget.group);
  }
}
