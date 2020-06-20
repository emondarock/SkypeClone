import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:skypeclone/constants/String.dart';
import 'package:skypeclone/models/message.dart';
import 'package:skypeclone/models/users.dart';
import 'package:skypeclone/resources/firebase_rapository.dart';
import 'package:skypeclone/utils/universal_variables.dart';
import 'package:skypeclone/widgets/appBar.dart';
import 'package:skypeclone/widgets/custom_tile.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = TextEditingController();
  FirebaseRepository _repository = FirebaseRepository();
  ScrollController _listScrollController = ScrollController();
  FocusNode textFieldFocus = FocusNode();
  bool writing = false;
  bool showEmojiPicker = false;
  User sender;
  String currentUserId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _repository.getCurrentUser().then((user) {
      currentUserId = user.uid;
      setState(() {
        sender = User(
            uid: user.uid, name: user.displayName, profilePhoto: user.photoUrl);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      body: Column(
        children: <Widget>[
          Flexible(
            child: messageList(),
          ),
          chatControls(),
          showEmojiPicker
              ? Container(
                  child: emojiContainer(),
                )
              : Container()
        ],
      ),
    );
  }

  emojiContainer() {

    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
      onEmojiSelected: (emoji, category) {
        setState(() {
          writing = true;
        });

        textEditingController.text = textEditingController.text + emoji.emoji;
      },
    );
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(widget.receiver.name),
      action: <Widget>[
        IconButton(
          icon: Icon(Icons.video_call),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.phone),
          onPressed: () {},
        )
      ],
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        writing = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: UniversalVariables.blackColor,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(Icons.close),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content and tools",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Videos",
                        icon: Icons.image,
                      ),
                      ModalTile(
                          title: "File",
                          subtitle: "Share files",
                          icon: Icons.tab),
                      ModalTile(
                          title: "Contact",
                          subtitle: "Share contacts",
                          icon: Icons.contacts),
                      ModalTile(
                          title: "Location",
                          subtitle: "Share a location",
                          icon: Icons.add_location),
                      ModalTile(
                          title: "Schedule Call",
                          subtitle: "Arrange a skype call and get reminders",
                          icon: Icons.schedule),
                      ModalTile(
                          title: "Create Poll",
                          subtitle: "Share polls",
                          icon: Icons.poll)
                    ],
                  ),
                )
              ],
            );
          });
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  shape: BoxShape.circle),
              child: Icon(Icons.add),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                TextField(
                  controller: textEditingController,
                  focusNode: textFieldFocus,
                  style: TextStyle(color: Colors.white),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  onTap: (){
                    hideEmojiContainer();
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(color: UniversalVariables.greyColor),
                    border: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(50.0)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: (){
                    if(!showEmojiPicker){
                      hideKeyboard();
                      showEmojiContainer();
                    }else{
                      hideEmojiContainer();
                      showKeyboard();
                    }
                  },
                  icon: Icon(Icons.face),
                )
              ],
            ),
          ),
          writing
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.record_voice_over),
                ),
          writing ? Container() : Icon(Icons.camera_alt),
          writing
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 25,
                    ),
                    onPressed: () => sendMessage(),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer () {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer () {
    setState(() {
      showEmojiPicker = true;
    });
  }

  Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIME_STAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
//          SchedulerBinding.instance.addPostFrameCallback((_) {
//            _listScrollController.animateTo(
//              _listScrollController.position.maxScrollExtent,
//              duration: Duration(milliseconds: 250),
//              curve: Curves.easeInOut
//            );
//          });
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data.documents.length,
            reverse: true,
            controller: _listScrollController,
            itemBuilder: (context, index) {
              return chatMessageItem(snapshot.data.documents[index]);
            },
          );
        }
      },
    );
  }

  Widget chatMessageItem(document) {
    print("Document ${document.data}");
    Message message = Message.fromMap(document.data);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: message.senderId == currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: message.senderId == currentUserId
            ? senderLayout(message)
            : receiverLayout(message),
      ),
    );
  }

  Widget senderLayout(Message document) {
    Radius messageRadius = Radius.circular(10);
    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
            topLeft: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(document),
      ),
    );
  }

  Widget receiverLayout(Message document) {
    Radius messageRadius = Radius.circular(10);
    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
            bottomRight: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(document),
      ),
    );
  }

  getMessage(Message document) {
    return Text(
      document.message,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
    );
  }

  sendMessage() {
    var text = textEditingController.text;
    Message message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        timestamp: Timestamp.now(),
        type: "text");
    setState(() {
      writing = false;
      textEditingController.clear();
    });

    _repository.addMessageToDb(message, sender, widget.receiver);
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  ModalTile(
      {@required this.title, @required this.subtitle, @required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        leading: Container(
          margin: EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: UniversalVariables.receiverColor),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subTitle: Text(
          subtitle,
          style: TextStyle(color: UniversalVariables.greyColor, fontSize: 14),
        ),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
