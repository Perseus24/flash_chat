
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  CollectionReference messages = FirebaseFirestore.instance.collection('messages');

  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String message = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    try{
      final user = await _auth.currentUser;
      if(user!=null){
        loggedInUser = user;
        print(loggedInUser?.email);
      }
    } on FirebaseAuthException catch(e){
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                 _auth.signOut();
                 Navigator.pop(context);
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
            MyMesssagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      style: TextStyle(
                        color: Colors.white
                      ),
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messages.add({
                        'text': message,
                        'sender': loggedInUser?.email,
                        'time': DateTime.now()
                      });
                      messageTextController.clear();
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

class MyMesssagesStream extends StatelessWidget {
  const MyMesssagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context, snapshots){
          if(!snapshots.hasData){
            return CircularProgressIndicator();
          }
          final messages = snapshots.data?.docs;
              messages?.sort((a,b){
            Timestamp tsA = a['time'];
            Timestamp tsB = b['time'];

            DateTime dtA = tsA.toDate();
            DateTime dtB = tsB.toDate();
            return dtB.compareTo(dtA);
          });
          List<MessageBubble> messageBubbles = [];
          for (var mess in messages!){
            final messageText = mess.get('text');
            final messageSender = mess.get('sender');
            final messageTimeStamp = mess.get('time');

            final currentUser = loggedInUser?.email;

            final messageBubble = MessageBubble(text: messageText, sender: messageSender,
                                                timestamp: messageTimeStamp, isMe: currentUser == messageSender,);
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageBubbles,
            ),
          );
        }
    );
  }
}



class MessageBubble extends StatelessWidget {

  MessageBubble({required this.text, required this.sender, required this.timestamp, required this.isMe});

  final text;
  final sender;
  final timestamp;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              color: Colors.white30,
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(topRight:isMe?Radius.circular(0):Radius.circular(30),
                                            topLeft: isMe?Radius.circular(30):Radius.circular(0), bottomLeft:  Radius.circular(30),
                                            bottomRight: Radius.circular(30)),
            elevation: 5,
            color: isMe?Colors.lightBlueAccent:Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(color: isMe?Colors.white:Colors.black),

                 ),
            )
            ),
        ],
      ),
    );
  }
}

