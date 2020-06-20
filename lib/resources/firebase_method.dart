import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skypeclone/constants/String.dart';
import 'package:skypeclone/models/message.dart';
import 'package:skypeclone/models/users.dart';
import 'package:skypeclone/utils/utilities.dart';


class FirebaseMethod {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  Firestore firestore = Firestore.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();


  Future<FirebaseUser> getCurrentUser() async{
    FirebaseUser currentUser;
    currentUser = await auth.currentUser();
    await firestore.collection(USER_COLLECTION).getDocuments().then((value){
      print(value.toString());
    });
    print("User ${currentUser}");
    return currentUser;
  }

  Future<AuthResult> signIn() async{
    GoogleSignInAccount _signInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication = await _signInAccount.authentication;


    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken
    );

    AuthResult user = await auth.signInWithCredential(credential);
    return user;
  }

  Future<bool> authenticateUser(AuthResult user) async{
    QuerySnapshot result = await firestore.collection(USER_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.user.email)
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;
    print("Docs. $docs");
    return docs.length == 0 ? true:false;
  }

  Future<void> addDataToDb(FirebaseUser userData) async{

    String userName = Utils.getUserName(userData.email);

    user = User(
        uid: userData.uid,
        name: userData.displayName,
        email: userData.email,
        profilePhoto: userData.photoUrl,
        username: userName
    );

    print("CurrentUser, ${userData.uid}");

    try {
      firestore.collection(USER_COLLECTION).document(userData.uid).setData(user.toMap(user));
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async{
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    return await auth.signOut();
  }


  Future<List<User>> fetchAllUser(currentUser) async{
    List<User> userList = List<User>();

    QuerySnapshot querySnapshot = await firestore.collection(USER_COLLECTION)
        .getDocuments();
    print("FetchData ${querySnapshot.documents[0].data}");
    for(int i = 0; i < querySnapshot.documents.length; i++){
      if(querySnapshot.documents[i].documentID != currentUser.uid){
        userList.add(User.fromMap(querySnapshot.documents[i].data));
      }
    }
    return userList;
  }

  Future<void> addMessageToDb(Message message, sender, receiver) async{
    var map = message.toMap();

    await firestore
    .collection(MESSAGES_COLLECTION)
    .document(message.senderId)
    .collection(message.receiverId)
    .add(map);

    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }
}