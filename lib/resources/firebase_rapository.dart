import 'package:firebase_auth/firebase_auth.dart';
import 'package:skypeclone/models/users.dart';
import 'package:skypeclone/resources/firebase_method.dart';

class FirebaseRepository {
  FirebaseMethod firebaseMethod = FirebaseMethod();

  Future<FirebaseUser> getCurrentUser() => firebaseMethod.getCurrentUser();

  Future<AuthResult> signIn() => firebaseMethod.signIn();

  Future<bool> authenticateUser(AuthResult user) =>
      firebaseMethod.authenticateUser(user);

  Future<void> addDataToDb(FirebaseUser user) =>
      firebaseMethod.addDataToDb(user);

  Future<void> signOut() => firebaseMethod.signOut();

  Future<List<User>> fetchAllUser(user) => firebaseMethod.fetchAllUser(user);

  Future<void> addMessageToDb(message, sender, receiver) =>
      firebaseMethod.addMessageToDb(message, sender, receiver);
}
