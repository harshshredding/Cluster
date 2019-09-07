import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'colors.dart';


/// Scaffolding of the add event screen
class AddGroupScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Group'),
        ),
        body: Center(child: AddGroupForm()),
      ),
    );
  }
}

/// The forms user fills out to create an event.
class AddGroupForm extends StatefulWidget {
  @override
  AddGroupFormState createState() {
    return AddGroupFormState();
  }
}

class AddGroupFormState extends State<AddGroupForm> {
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

  Future<void> sendFormData() async {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = _controllerTitle.text;
    data['purpose'] = _controllerPurpose.text;
    data['rules'] = _controllerRules.text;
    FirebaseUser user =
        await FirebaseAuth.instance.currentUser();
    data['user_id'] = user.uid;
    // start submitting
    setState(() {
      submitting = true;
    });
    try {
      await _firestore.collection("groups").add(data);
      var snackbar = SnackBar(
          duration: Duration(seconds: 3),
          content: const Text('Group Added To Universe'));
      Scaffold.of(context).showSnackBar(snackbar);
    } catch (err) {
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
                  child: const Text('CREATE'),
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
