import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore
    .instance; //_firestore object which allows access to Firebase Database
FirebaseUser loggedInUser;
final _auth = FirebaseAuth
    .instance; //_auth object which allows access to Firebase Authentification

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();

  String userMessage;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    //it will check to see if there's a current user who is signed in and we get its email and password
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {}
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').getDocuments();
  //   for (var message in messages.documents) {
  //     print(message.data);
  //   }
  // }
  // void messsagesStream() async {
  //   //we are gonna use this method to listen for the Stream of Firebase querySnapshot
  //   await for (var snapshot in _firestore
  //       .collection('messages')
  //       .orderBy('created_at', descending: true)
  //       .snapshots()) {
  //     print(snapshot);
  //     for (var messages in snapshot.documents) {
  //       print(messages.data);
  //     }
  //   }
  //   // snapshots instead of a future of querySnapshots it returns a stream of querySnapshots
  //   //a stream of snapshots is almost like a list of Futures of snapshots, a whole bunch of future. So we subscribe to that stream.
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // _auth.signOut();
                // Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        userMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      messageTextController.clear();
                      //userMessage + loggedInUser.email
                      //It's important to remind what we called the collection and the field
                      //to push data we already added the project with a specific JSON that manages that transaction so we can push data like this below. :)
                      await _firestore.collection('messages').add(
                          {'senders': loggedInUser.email, 'text': userMessage});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  MessageBubble({this.text, this.sender, this.isMe});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(fontSize: 12.0, color: Colors.black),
          ),
          Material(
            elevation: 5.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            color: isMe ? Colors.lightBlue : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                '$text',
                style: isMe
                    ? TextStyle(color: Colors.white)
                    : TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      /*Our StreamBuilder subscribes to the following stream:, so knows when new data comes in to rebuild itself*/
      stream: _firestore
          .collection("messages").snapshots(),
      /*The logic for what the StreamBuilder should do*/
      /*our chat messages are buried somewhere in the asyncSnapshot */
      /*async snapshot is the most recent interaction with the Stream*/
      /*the snapshot from flutter contains the querySnapshot from Firebase*/
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var i in messages) {
          final messageText = i.data['text'];
          final messageSender = i.data['senders'];
          final currentUser = loggedInUser.email;
          final messageBubble = MessageBubble(
              isMe: currentUser == messageSender,
              text: messageText,
              sender: messageSender);
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

//cambiar en vez de dos constructores a propiedades con operadores ternarios.
