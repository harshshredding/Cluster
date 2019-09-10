import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'tag_selector.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

/// Here we just wrap the form in a scaffold.
/// TODO: Maybe there is no need for this class.
class AddProposalScreen extends StatelessWidget {
  final List<String> preSelectedGroups;

  AddProposalScreen({this.preSelectedGroups});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Proposal'),
      ),
      body: Center(child: AddProposalForm(preSelectedGroups)),
    );
  }
}

/// The forms user fills out to create an event.
/// Forms usually have lots of state :)
class AddProposalForm extends StatefulWidget {
  AddProposalForm(this.preSelectedGroups);
  AddProposalFormState createState() {
    return AddProposalFormState();
  }

  final List<String> preSelectedGroups;
}

enum LIFETIME {
  oneWeek,
  twoWeeks,
  threeWeeks,
  oneMonth,
}

class AddProposalFormState extends State<AddProposalForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerTitle = TextEditingController();

  // IMPORTANT :
  // Had to initialize the below controller with empty string for the entire
  // form to work. This is really weird but it seems to be working.
  final TextEditingController _controllerSummary =
      TextEditingController(text: '');
  final Firestore _firestore = Firestore.instance;
  List<String> groupsSelected = <String>[]; // Represents groups that the user
  // wants to publish to
  bool submitting =
      false; // indicates whether we are in the process of submiting
  LIFETIME _selectedLifeValue = LIFETIME.twoWeeks;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedGroups != null) {
      groupsSelected.addAll(widget.preSelectedGroups);
    }
  }

  /// Here we make chips and wrap them into
  /// Wrap widgets so that they don't overflow the screen.
  /// See what happens when we remove the wrap widget.
  Widget makeChips() {
    List<Widget> allChips = new List();
    for (String group in groupsSelected) {
      allChips.add(createChip(group));
    }
    return Wrap(
      children: allChips,
    );
  }

  /// Here we create a single chips.
  /// Notice the use of the InkWell widget.
  Widget createChip(String group) {
    return InkWell(
      child: Container(
          margin: EdgeInsets.all(5),
          child: Chip(
            label: Text(group),
            backgroundColor: Colors.blueGrey,
            elevation: 4,
          )),
      onTap: () {
        setState(() {
          if (groupsSelected.contains(group)) {
            groupsSelected.remove(group);
          } else {
            groupsSelected.add(group);
          }
        });
      },
    );
  }
  
  Timestamp getExpiry(Timestamp now, LIFETIME life) {
    switch (life) {
      case LIFETIME.oneWeek: {
        return Timestamp.fromDate(now.toDate().add(Duration(days: 7)));
      }
      break;
      case LIFETIME.twoWeeks: {
        return Timestamp.fromDate(now.toDate().add(Duration(days: 14)));
      }
      break;
      case LIFETIME.threeWeeks: {
        return Timestamp.fromDate(now.toDate().add(Duration(days: 21)));
      }
      break;
      case LIFETIME.oneMonth: {
        return Timestamp.fromDate(now.toDate().add(Duration(days: 31)));
      }
    }
  }

  /// we upload our proposal using the following method
  /// we pass in context to show the snackbar
  void submitProposal(BuildContext context) async {
    setState(() {
      submitting = true;
    });
    Map<String, dynamic> dataToSend = <String, dynamic>{};
    for (String group in groupsSelected) {
      dataToSend[group] = true;
    }
    dataToSend['title'] = _controllerTitle.text;
    dataToSend['summary'] = _controllerSummary.text;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    dataToSend['user_id'] = user.uid;
    final String proposalId = Uuid().v1() + user.uid;
//    final Timestamp timeNow = Timestamp.now();
////    final Timestamp expiryTime = getExpiry(timeNow, _selectedLifeValue);
////    dataToSend['expiry'] = expiryTime;
////    dataToSend['created'] = timeNow;
    DocumentReference userProposal = _firestore
        .collection('users')
        .document(user.uid)
        .collection('proposals')
        .document(proposalId);
    DocumentReference proposalEntry =
        _firestore.collection('proposals').document(proposalId);
    await _firestore.runTransaction((Transaction t) async {
      await t.set(proposalEntry, dataToSend);
      await t.set(userProposal, <String, dynamic>{'id': proposalId});
      return null;
    });
    setState(() {
      submitting = false;
    });
    // Show a snackbar
    var snackbar = SnackBar(
      duration: Duration(seconds: 5),
      content: const Text('Proposal Sucessfully Published!'),
      backgroundColor: Colors.green,
    );
    Scaffold.of(context).showSnackBar(snackbar);
  }

  String getStringFromEnum(LIFETIME enumValue) {
    if (enumValue == LIFETIME.oneWeek) {
      return 'one week';
    }
    if (enumValue == LIFETIME.twoWeeks) {
      return 'two weeks';
    }
    if (enumValue == LIFETIME.threeWeeks) {
      return 'three weeks';
    }
    if (enumValue == LIFETIME.oneMonth) {
      return 'one month';
    }
    throw const FormatException('Encoutered a lifetime which has not been registered');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      maxLines: 5,
                      controller: _controllerTitle,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      }),
                ),
                ListTile(
                  title: TextFormField(
                      decoration: InputDecoration(labelText: 'Summary'),
                      maxLines: 20,
                      controller: _controllerSummary,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      }),
                ),
//                ListTile(
//                  title: const Text('Choose Lifetime'),
//                  subtitle: const Text('You can always renew life later'),
//                  trailing: DropdownButton<LIFETIME>(
//                    value: _selectedLifeValue,
//                    onChanged: (LIFETIME newLifeTime) {
//                      setState(() {
//                        _selectedLifeValue = newLifeTime;
//                      });
//                    },
//                    items: <LIFETIME>[LIFETIME.oneWeek, LIFETIME.twoWeeks, LIFETIME.threeWeeks, LIFETIME.oneMonth]
//                        .map<DropdownMenuItem<LIFETIME>>((LIFETIME value) {
//                      return DropdownMenuItem<LIFETIME>(
//                        value: value,
//                        child: Text(getStringFromEnum(value)),
//                      );
//                    }).toList(),
//                  ),
//                ),
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 15, left: 12),
                  child: Row(children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        List<String> result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    TagSelector(groupsSelected)));
                        if (result != null) {
                          setState(() {
                            groupsSelected = result;
                          });
                        }
                      },
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text("choose groups to publish to",
                            style: TextStyle(color: Colors.grey))),
                  ]),
                ),
                makeChips(),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: submitting
                      ? SpinKitFadingCircle(
                          itemBuilder: (_, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    index.isEven ? Colors.brown : Colors.grey,
                              ),
                            );
                          },
                        )
                      : RaisedButton(
                          color: brownBackground,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              submitProposal(context);
                            }
                          },
                          child: Text("CREATE"),
                          elevation: 6,
                          shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                ),
              ],
            )),
      ),
    );
  }
}
