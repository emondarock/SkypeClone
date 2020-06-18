import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skypeclone/models/users.dart';
import 'package:skypeclone/utils/utilities.dart';

class FirebaseMethod{
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  Firestore firestore = Firestore.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();


  Future<FirebaseUser> getCurrentUser() async{
    FirebaseUser currentUser;
    currentUser = await auth.currentUser();
    await firestore.collection("user").getDocuments().then((value){
      print(value.toString());
    });
    print("User ${currentUser.email}");
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
    QuerySnapshot result = await firestore.collection("user")
        .where("email", isEqualTo: user.user.email)
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
      firestore.collection("user").document(userData.uid).setData(user.toMap(user));
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async{
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    return await auth.signOut();
  }

}