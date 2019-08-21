import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';
import 'proposals.dart';

class ProposalsForOneGroup extends StatefulWidget {
  final List<String> _filters;

  ProposalsForOneGroup(this._filters);

  ProposalsForOneGroupState createState() {
    return ProposalsForOneGroupState();
  }
}

class ProposalsForOneGroupState extends State<ProposalsForOneGroup> {
  final Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _proposals = new List();
  List<StreamSubscription<QuerySnapshot>> _subscriptions = new List();
  List<String> _filters = List<String>();

  void initState() {
    super.initState();
    _filters = widget._filters;
    getProposals();
  }

  void getProposals() {
    _proposals.clear();
    _subscriptions.clear();
    if (_filters.isEmpty) {
      var subscription = _firestore
          .collection("proposals")
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        List<DocumentSnapshot> newDocuments = snapshot.documents;
        List<DocumentSnapshot> thingsToAdd = List();
        for (DocumentSnapshot proposal in newDocuments) {
          bool proposalDoesntExist =
              _proposals.every((DocumentSnapshot oldProposal) {
            return (oldProposal.documentID != proposal.documentID);
          });
          if (proposalDoesntExist) {
            thingsToAdd.add(proposal);
          }
        }
        setState(() {
          _proposals.addAll(thingsToAdd);
        });
      });
      _subscriptions.add(subscription);
    } else {
      for (String filter in _filters) {
        var subscription = _firestore
            .collection("proposals")
            .where(filter, isEqualTo: true)
            .snapshots()
            .listen((QuerySnapshot snapshot) {
          List<DocumentSnapshot> newDocuments = snapshot.documents;
          List<DocumentSnapshot> thingsToAdd = List();
          for (DocumentSnapshot proposal in newDocuments) {
            bool proposalDoesntExist =
                _proposals.every((DocumentSnapshot oldProposal) {
              return (oldProposal.documentID != proposal.documentID);
            });
            if (proposalDoesntExist) {
              thingsToAdd.add(proposal);
            }
          }
          setState(() {
            _proposals.addAll(thingsToAdd);
          });
        });
        _subscriptions.add(subscription);
      }
    }
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot currEvent = _proposals[index];
              String topic = currEvent.data["title"] ?? "";
              String summary = currEvent.data["summary"] ?? "";
              String userId = currEvent.data["user_id"];
              return ProposalsState.createCard(
                  topic, summary, userId, currEvent.documentID, context);
            },
            itemCount: _proposals.length,
          ),
        ),
      ],
    );
  }
}
