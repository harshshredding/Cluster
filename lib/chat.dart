import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'platform_adaptive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String eventId;
  ChatScreen(this.eventId);

  @override
  State createState() => ChatScreenState(eventId);
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  List<ChatMessage> _messages = [];
  TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  var fireBaseSubscription;
  Firestore firestore = Firestore.instance;
  String eventId;
  CollectionReference collectionReference;
  ScrollController _scrollController;
  Function _currentScrollListener;
  ChatScreenState(this.eventId);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _googleSignIn.signInSilently();
    firestore = Firestore.instance;
    collectionReference = firestore
        .collection('events')
        .document(eventId)
        .collection('chat_room');
    fireBaseSubscription =
        collectionReference.limit(15).orderBy("timestamp", descending: true).snapshots().listen((QuerySnapshot snapshot) {
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
    });
  }


  Function getScrollListener(context) {
    return () {
      if ((_scrollController.offset >= _scrollController.position.maxScrollExtent )&&
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

  void _handleSubmitted(String text) {
    _textController.clear();
    _googleSignIn.signIn().then((user) {
      var message = {
        'sender': {'name': user.displayName, 'imageUrl': user.photoUrl},
        'text': text,
        'timestamp': Timestamp.now()
      };
      collectionReference.add(message);
    });
    setState(() {
      _isComposing = false;
    });
  }
  
  void _getOldMessages() async {
    final snackBar = SnackBar(
        content: Text('Loading old messages'),
        duration: Duration(milliseconds: 800),);

    // Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(context).showSnackBar(snackBar);
    Timestamp minTimestamp = _messages.reversed.first.timestamp;
    QuerySnapshot querySnapshot = await collectionReference.limit(5).orderBy("timestamp", descending: true).startAfter([minTimestamp]).getDocuments();
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
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: null,
                ),
              ),
              Flexible(
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  onChanged: _handleMessageChanged,
                  decoration:
                      InputDecoration.collapsed(hintText: 'Send a message'),
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: PlatformAdaptiveButton(
                    icon: Icon(Icons.send),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(_textController.text)
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
    return Column(children: [
      Flexible(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => ChatMessageListItem(_messages[index]),
            itemCount: _messages.length,
          )),
      Divider(height: 1.0),
      Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer()),
    ]);
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
    double c_width = MediaQuery.of(context).size.width*0.8;
    //80% of screen width
    return new Container (
      width: c_width,
      child: new Column (
        children: <Widget>[
          new Text (message.text),
        ],
      ),
    );
  }
}
