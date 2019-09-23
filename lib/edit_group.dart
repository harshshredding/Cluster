import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'colors.dart';
import 'helper.dart';

/// Scaffolding of the add event screen
class EditGroupScreen extends StatelessWidget {
  final String title;
  final String purpose;
  final String rules;
  final String groupId;
  
  EditGroupScreen(this.title, this.purpose, this.rules, this.groupId);
  
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Group'),
        ),
        body: Center(child: EditGroupForm(this.title, this.purpose, this.rules, this.groupId)),
      ),
    );
  }
}

/// The forms user fills out to create an event.
class EditGroupForm extends StatefulWidget {
  final String groupId;
  final String title;
  final String purpose;
  final String rules;

  EditGroupForm(this.title, this.purpose, this.rules, this.groupId);

  @override
  EditGroupFormState createState() {
    return EditGroupFormState();
  }
}

class EditGroupFormState extends State<EditGroupForm> {
  final TextEditingController _controllerTitle = TextEditingController();
  // IMPORTANT !!!!!!!
  // Had to initialize the below controller with empty string for the entire
  // form to work. This is really weird but it seems to be working.
  final TextEditingController _controllerPurpose =
  TextEditingController(text: '');
  final TextEditingController _controllerRules =
  TextEditingController(text: '');
  final Firestore _firestore = Firestore.instance;
  List<String> categoriesSelected = [];
  bool submitting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controllerPurpose.text = widget.purpose;
    _controllerRules.text = widget.rules;
    _controllerTitle.text = widget.title;
  }

  Future<void> sendFormData() async {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = _controllerTitle.text;
    data['purpose'] = _controllerPurpose.text;
    data['rules'] = _controllerRules.text;
    FirebaseUser currentUser =
    await FirebaseAuth.instance.currentUser();
    data['user_id'] = currentUser.uid;
    // start submitting
    setState(() {
      submitting = true;
    });
    try {
      await _firestore
          .collection("kingdoms")
          .document(getUserOrganization(currentUser) ?? "")
          .collection('groups')
          .document(widget.groupId)
          .setData(data);
      var snackbar = SnackBar(
          duration: Duration(seconds: 3),
          content: const Text('Group Updated'),
          backgroundColor: Colors.green,
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } catch (err) {
      Scaffold.of(context).showSnackBar(SnackBar(content: const Text('Error while updating. Try again.'),));
      print(err);
    }
    // end submitting
    setState(() {
      submitting = false;
    });
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
                      labelText: 'Title', hintText: 'Group Title'),
                  controller: _controllerTitle,
                  maxLines: 1,
                  // The validator receives the text that the user has entered.
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Purpose',
                      hintText: 'Tell us why this group is important.'),
                  maxLines: 6,
                  controller: _controllerPurpose,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Rules',
                      hintText: 'Guidelines and restrictions on how to write a proposal.'
                  ),
                  maxLines: 10,
                  controller: _controllerRules,
                  // The validator receives the text that the user has entered.
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: submitting
                    ? SpinKitFadingCircle(
                  itemBuilder: (_, int index) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: index.isEven ? Colors.brown : Colors.grey,
                      ),
                    );
                  },
                )
                    : RaisedButton(
                  color: brownBackground,
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      sendFormData();
                    }
                  },
                  child: const Text('UPDATE'),
                  elevation: 6,
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
