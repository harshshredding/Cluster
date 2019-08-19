import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'platform_adaptive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'circular_photo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String photoUserId;
  final String proposalId;
  ChatScreen(this.roomId, this.photoUserId, this.proposalId);

  @override
  State createState() => ChatScreenState(roomId);
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  List<ChatMessage> _messages = [];
  TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  var fireBaseSubscription;
  Firestore firestore = Firestore.instance;
  String roomId;
  CollectionReference collectionReference;
  ScrollController _scrollController;
  Function _currentScrollListener;
  ChatScreenState(this.roomId);
  FirebaseUser currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  bool _receivedMessage = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    firestore = Firestore.instance;
    collectionReference =
        firestore.collection('chats').document(roomId).collection('chat_room');
    fireBaseSubscription = collectionReference
        .limit(15)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (DocumentSnapshot snapshot in snapshot.documents.reversed) {
        Timestamp newMessageTimestamp = snapshot.data['timestamp'];
        if (_messages.isNotEmpty) {
          print('hellolalal' + _messages[0].toString());
          Timestamp maxTimestamp = _messages[0].timestamp;
          for (ChatMessage message in _messages) {
            Timestamp currTimeStamp = message.timestamp;
            if (currTimeStamp.compareTo(maxTimestamp) > 0) {
              maxTimestamp = currTimeStamp;
            }
          }
          if (newMessageTimestamp.compareTo(maxTimestamp) > 0) {
            _addMessage(
                name: snapshot.data['sender']['name'],
                senderImageUrl: snapshot.data['sender']['imageUrl'],
                text: snapshot.data['text'],
                timestamp: newMessageTimestamp);
          }
        } else {
          _addMessage(
              name: snapshot.data['sender']['name'],
              senderImageUrl: snapshot.data['sender']['imageUrl'],
              text: snapshot.data['text'],
              timestamp: newMessageTimestamp);
        }
      }
      // Update the 'time_seen' state
      if (_messages.isNotEmpty) {
        _updateTimeSeenState(_messages[0].timestamp);
      }
    });
    getUserDetails();
  }

  // We keep track of when the maximum timestamp message that the user has seen.
  _updateTimeSeenState(Timestamp maxTimestamp) async {
    DocumentReference chatReference = firestore.collection("chats").document(roomId);
    DocumentSnapshot chat = await chatReference.get();
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    DocumentReference creatorReference = firestore.collection("users").document(chat.data['creator_id']).collection("chats").document(roomId);
    DocumentReference interestedReference = firestore.collection("users").document(chat.data['interested_id']).collection("chats").document(roomId);
    if (chat.data['creator_id'] == currentUser.uid) {
      print("running transaction");
      firestore.runTransaction((Transaction t) async {
        await t.update(chatReference, {
          "creator_seen" : maxTimestamp
        });
        await t.update(creatorReference, {
          "creator_seen" : maxTimestamp
        });
        await t.update(interestedReference, {
          "creator_seen" : maxTimestamp
        });
      });
    } else  {
      print("running_transaction");
      firestore.runTransaction((Transaction t) async {
        await t.update(chatReference, {
          "interested_seen" : maxTimestamp
        });
        await t.update(creatorReference, {
          "interested_seen" : maxTimestamp
        });
        await t.update(interestedReference, {
          "interested_seen" : maxTimestamp
        });
      });
    }
  }

  printSomething() {
    print("something yaya");
    setState(() {
      _receivedMessage = true;
    });
  }

  void getUserDetails() async {
    this.currentUser = await FirebaseAuth.instance.currentUser();
  }

  Function getScrollListener(context) {
    return () {
      if ((_scrollController.offset >=
              _scrollController.position.maxScrollExtent) &&
          (!_scrollController.position.outOfRange)) {
        setState(() {
          _getOldMessages();
        });
      }
    };
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    fireBaseSubscription.cancel();
    super.dispose();
  }

  void _handleMessageChanged(String text) {
    setState(() {
      _isComposing = text.length > 0;
    });
  }

  void _addMessage(
      {String name, String text, String senderImageUrl, Timestamp timestamp}) {
    var animationController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    var sender = ChatUser(name: name, imageUrl: senderImageUrl);
    var message = ChatMessage(
        sender: sender,
        text: text,
        animationController: animationController,
        timestamp: timestamp);
    setState(() {
      _messages.insert(0, message);
    });
    animationController?.forward();
  }

  void _addMessageAtEnd(
      {String name, String text, String senderImageUrl, Timestamp timestamp}) {
    var animationController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    var sender = ChatUser(name: name, imageUrl: senderImageUrl);
    var message = ChatMessage(
        sender: sender,
        text: text,
        animationController: animationController,
        timestamp: timestamp);
    setState(() {
      _messages.insert(_messages.length, message);
    });
    animationController?.forward();
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    DocumentSnapshot userDetails = await firestore.collection("users").document(this.currentUser.uid).get();
    Timestamp currentTime = Timestamp.now();
    print("Rick " + widget.photoUserId);
    var message = {
      'sender': {'name': userDetails.data['name'], 'imageUrl': userDetails.data['photo_url']},
      'text': text,
      'timestamp': currentTime,
      "receiver" : widget.photoUserId
    };
    print(collectionReference.path);
    collectionReference.add(message);
    DocumentReference chatReference = firestore.collection('chats').document(roomId);
    DocumentSnapshot chat = await chatReference.get();
    String creatorId = chat.data['creator_id'];
    String interestedId = chat.data['interested_id'];
    DocumentReference creatorReference = firestore.collection("users").document(creatorId).collection("chats").document(roomId);
    DocumentReference interestedReference = firestore.collection("users").document(interestedId).collection("chats").document(roomId);
    firestore.runTransaction((Transaction t) async {
      await t.update(chatReference, {"last_updated": currentTime});
      await t.update(chatReference, {"last_message": text});
      await t.update(creatorReference, {"last_updated": currentTime});
      await t.update(creatorReference, {"last_message": text});
      await t.update(interestedReference, {"last_updated": currentTime});
      await t.update(interestedReference, {"last_message": text});
    }).catchError((error) {print("yo");});
    setState(() {
      _isComposing = false;
    });
  }

  void _getOldMessages() async {
    final snackBar = SnackBar(
      content: Text('Loading old messages'),
      duration: Duration(milliseconds: 800),
    );
    // Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(context).showSnackBar(snackBar);
    Timestamp minTimestamp = _messages.reversed.first.timestamp;
    QuerySnapshot querySnapshot = await collectionReference
        .limit(5)
        .orderBy("timestamp", descending: true)
        .startAfter([minTimestamp]).getDocuments();
    for (DocumentSnapshot docSnapshot in querySnapshot.documents) {
      _addMessageAtEnd(
          name: docSnapshot.data['sender']['name'],
          senderImageUrl: docSnapshot.data['sender']['imageUrl'],
          text: docSnapshot.data['text'],
          timestamp: docSnapshot.data['timestamp']);
    }
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: PlatformAdaptiveContainer(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(children: [
              Flexible(
                child: TextField(
                  controller: _textController,
                  onChanged: _handleMessageChanged,
                  maxLines: null,
                  decoration:
                      InputDecoration.collapsed(hintText: 'Send a message'),
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: PlatformAdaptiveButton(
                    icon: Icon(Icons.send),
                    onPressed: _isComposing
                        ? () {_handleSubmitted(_textController.text);}
                        : null,
                    child: Text('Send'),
                  )),
            ])));
  }

  Widget build(BuildContext context) {
    if (_currentScrollListener != null) {
      _scrollController.removeListener(_currentScrollListener);
    }
    _currentScrollListener = getScrollListener(context);
    _scrollController.addListener(_currentScrollListener);
    return Scaffold(
      appBar: AppBar(
        title: _receivedMessage ? Text("Received Message") : Text("Chat"),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 10, 5),
            child: CircularPhoto(widget.photoUserId, 20),
          )
        ]
      ),
      body: Center(
        child: Column(children: [
          Flexible(
              child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) =>
                ChatMessageListItem(_messages[index]),
            itemCount: _messages.length,
          )),
          Divider(height: 1.0),
          Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer()),
        ]),
      ),
    );
  }
}

class ChatUser {
  ChatUser({this.name, this.imageUrl});
  final String name;
  final String imageUrl;
}

class ChatMessage {
  ChatMessage(
      {this.sender, this.text, this.animationController, this.timestamp});
  final ChatUser sender;
  final Timestamp timestamp;
  final String text;
  final AnimationController animationController;
}

class ChatMessageListItem extends StatelessWidget {
  ChatMessageListItem(this.message);

  final ChatMessage message;

  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor: CurvedAnimation(
            parent: message.animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                    backgroundImage: NetworkImage(message.sender.imageUrl)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.sender.name,
                      style: Theme.of(context).textTheme.subhead),
                  Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: ChatMessageContent(message)),
                ],
              ),
            ],
          ),
        ));
  }
}

class ChatMessageContent extends StatelessWidget {
  ChatMessageContent(this.message);

  final ChatMessage message;

  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.8;
    //80% of screen width
    return new Container(
      width: c_width,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(message.text),
        ],
      ),
    );
  }
}
