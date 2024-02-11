
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/utilities/notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../utilities/get_user_data.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
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

  Future<void> sendMessage(String title, String bodyText) async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      'Content-Type': 'application/json',
      'Authorization': 'key=AAAADi5DiQk:APA91bHJb-tFluFevlPEZh09TmzyXwry2_WSAzhrB-jGkj2osq5xo_q0xUPVXEb62PnZAcBl6sACVtZLuwFwTyEfGTCYIkIVOlYhuYb170VtstJ7-LnCERbyFH85_6N196VTw2kxa1sQ'
    };
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    var body = {
      "to": "/topics/group",
      "notification": {
        "title": title,
        "body": bodyText,
        "mutable_content": true,
        "sound": "Tri-tone"
      }
    };

    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);


    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    }
    else {
      print(res.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 677));
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: [
          IconButton(
            icon: Icon(Icons.format_list_bulleted),
            onPressed: (){
              _auth.signOut();
              Navigator.pop(context);
            }
          )
        ],
        backgroundColor: Color(0xFF49BEB7),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 8.w,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cy Jay',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'Poppins'
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Poppins',
                    color: Colors.green,
                  ),
                )
              ],
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyMesssagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 5,
                      controller: messageTextController,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: (){

                    },
                    child: Icon(Icons.image_outlined, color: kMainColor,),
                  ),
                  TextButton(
                    onPressed: () async{
                      //String? token = await FirebaseMessaging.instance.getToken();
                      //print("token here $token");
                      if(messageTextController.text.isNotEmpty){
                        messages.add({
                          'text': messageTextController.text,
                          'sender': loggedInUser?.email,
                          'time': DateTime.now()
                        });
                        String message = messageTextController.text;
                        messageTextController.clear();
                        await sendMessage(loggedInUser!.email.toString(), message);
                      }
                    },
                    child: Icon(Icons.send, color: kMainColor,)
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class sendMessage{

}

class MyMesssagesStream extends StatelessWidget {


  // Future<void> fetchLatestMessagesAndSendNotification() async {
  //   // Fetch latest messages
  //   QuerySnapshot snapshots = await FirebaseFirestore.instance.collection('messages').get();
  //
  //   // Sort messages
  //   List<DocumentSnapshot> messages = snapshots.docs;
  //   messages.sort((a, b) {
  //     Timestamp tsA = a['time'];
  //     Timestamp tsB = b['time'];
  //     return tsB.compareTo(tsA);
  //   });
  //
  //   // Get the latest message
  //   final latest = messages.isNotEmpty ? messages.first : null;
  //   if (latest != null) {
  //     final latestSender = latest['sender'];
  //     final messageText = latest['text'];
  //     if (loggedInUser?.email != latestSender) {
  //       // Send notification
  //       await sendNotif('New Message', messageText);
  //     }
  //   }
  // }
  final userDataControllers = Get.put(MessagingControllers());
  @override
  Widget build(BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('messages').snapshots(),
          builder: (context, snapshots){
            if(!snapshots.hasData){
              return Center(child: CircularProgressIndicator());
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

            bool reset = false;
            String prevSender = 'a';
            for (var i = 0; i<messages!.length-1; i++){
              bool reset = true;
              bool addBelow = true;
              final messageText = messages[i].get('text');
              final messageSender = messages[i].get('sender');
              final Timestamp messageTimeStamp = messages[i].get('time');
              final DateTime messageTime = messageTimeStamp.toDate();

              if(messageSender == prevSender && reset){
                reset = false;
                addBelow = false;
              }else if(messageSender!=prevSender){
                reset = true;
              }else if(messageSender==prevSender){
                reset = false;
              }

              prevSender = messageSender;
              final currentUser = loggedInUser?.email;

              bool showName = false;
              bool showTime = false;
              String sender = 'hi';

              if(messages[i+1].get('sender') != messageSender){
                showName = true;
                Timestamp nextTime = messages[i+1].get('time');
                DateTime nextDateTime = nextTime.toDate();
              }
              Timestamp nextTime = messages[i+1].get('time');
              DateTime nextDateTime = nextTime.toDate();
              DateTime today = DateTime.now();
              Duration diff = messageTime.difference(nextDateTime);
              print(diff.inMinutes);
              if(diff.inMinutes>30){
                showTime = true;
              }
              List<DocumentSnapshot> usersData = userDataControllers.users;
              DocumentSnapshot hes = usersData.firstWhere((doc) => doc['email'] == messageSender);

              sender = hes['username'].toString();

              final messageBubble = MessageBubble(text: messageText, sender: sender,
                                                  timestamp: messageTimeStamp, isMe: currentUser == messageSender,
                                                  addBelow: addBelow,
                                                  showName: showName,
                                                  messageTime: messageTime,
                                                  showTime: showTime);
              //messageBubbles.insert(0, messageBubble);
              messageBubbles.add(messageBubble);
            }
            final latest = messages.last;
            final latestSender = latest.get('sender');
            final messageText = latest.get('text');
            // if(loggedInUser?.email!=latestSender){
            //   sendNotif('$latestSender', '$messageText');
            // }
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

  Future<void> sendNotif(String title, String body) async{
    await ChatNotification.showNotification(title: title, body: body);
  }
}



class MessageBubble extends StatelessWidget {

  MessageBubble({required this.text, required this.sender, required this.timestamp,
    required this.isMe, required this.addBelow, required this.showName, required this.messageTime, required this.showTime});

  final text;
  final sender;
  final timestamp;
  final bool isMe;
  final bool addBelow;
  final bool showName;
  final DateTime messageTime;
  final bool showTime;



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isMe&&showName?10.h:addBelow?0:0, bottom:addBelow?10.h:0, left: 10, right: 0),
      child: Column(
        children: [
          showTime?SizedBox(height: 30.h,):Container(),
          showTime?Center(child: Text("${messageTime.hour}" + ":" + messageTime.minute.toString().padLeft(2,'0') + (messageTime.hour>12?' PM':' AM'))):Container(),
          showTime?SizedBox(height: 30.h,):Container(),
          Row(
            mainAxisAlignment: isMe?MainAxisAlignment.end:MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isMe?Container():
                addBelow?CircleAvatar(
                    radius: 15.w,
                    backgroundColor: Colors.white,
                  )
                    :CircleAvatar(
                      radius: 15.w,
                      backgroundColor: Colors.transparent,
                    ),
              SizedBox(width: 7.w,),
              Column(
                crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isMe?Container():showName?Text(
                        sender,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ):Container(),

                    ],
                  ),
                  SizedBox(height: 3.h,),
                  Row(
                    //mainAxisAlignment: isMe?MainAxisAlignment.start:MainAxisAlignment.end,
                    children: [
                      isMe&&showName&&!showTime?
                        Text("${messageTime.hour}" + ":" + messageTime.minute.toString().padLeft(2,'0'),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp
                          ),
                        ):Container(),
                      isMe&&showName?SizedBox(width: 10.w,):Container(),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 210.w
                        ),
                        child: Material(
                          borderRadius: BorderRadius.only(topLeft: showName?Radius.circular(20.w):!isMe&&!addBelow?Radius.circular(5.w):isMe?Radius.circular(20.w):Radius.circular(0.w),
                                                          topRight: isMe&&showName?Radius.circular(20.w):isMe&&!addBelow?Radius.circular(10.w):isMe&&addBelow?Radius.circular(0.w):!isMe&&!addBelow?Radius.circular(20.w):Radius.circular(20.w),
                                                          bottomLeft: !isMe&&showName?Radius.circular(0):!isMe&&!addBelow?Radius.circular(5.w):isMe?Radius.circular(20.w):Radius.circular(20.w),
                                                          bottomRight: isMe&&showName?Radius.circular(0):isMe&&!addBelow?Radius.circular(5.w):Radius.circular(20.w)),
                          elevation: 3,
                          color: isMe?Color(0xFF49BEB7):Color(0xFFD9D9D9),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                            child: Text(
                              '$text',
                              textWidthBasis: TextWidthBasis.longestLine,
                              style: TextStyle(
                                color: isMe?Colors.white:Colors.black,
                                fontFamily: 'Poppins'
                              ),
                               ),
                          )
                          ),
                      ),
                      SizedBox(width: 10.w,),
                      !isMe&&showName&&!showTime?
                        Text("${messageTime.hour}" + ":" + messageTime.minute.toString().padLeft(2,'0'),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.sp
                          ),
                      ):Container(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// topRight:isMe&&addBelow?Radius.circular(0):Radius.circular(20),
// topLeft: isMe?Radius.circular(20):addBelow?Radius.circular(0):Radius.circular(5), bottomLeft:  isMe||showName?Radius.circular(20):addBelow?Radius.circular(0):Radius.circular(0),
// bottomRight: isMe?Radius.circular(0):Radius.circular(20)),
//
// borderRadius: BorderRadius.only(topLeft: isMe?Radius.circular(20.w):Radius.circular(10.w),
// topRight: isMe&&!addBelow?Radius.circular(10.w):addBelow?Radius.circular(10.w):Radius.circular(20.w),
// bottomRight: isMe?Radius.circular(0.w):Radius.circular(20.w),
// bottomLeft: isMe?Radius.circular(20.w):Radius.circular(0.w)),

// isMe&&showName?Radius.circular(0):

// Row(
// mainAxisSize: MainAxisSize.min,
// children: [
// Text("${messageTime.hour}:${messageTime.minute}",
// style: TextStyle(
// fontSize: 12.sp,
// ),)
// ],
// )

