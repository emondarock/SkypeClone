import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skypeclone/resources/firebase_rapository.dart';
import 'package:skypeclone/screens/HomeScreen.dart';
import 'package:skypeclone/utils/universal_variables.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseRepository _repository = FirebaseRepository();
  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        body: Stack(
          children: <Widget>[
            Center(
              child: loginButton(),
            ),
            isLoginPressed
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ],
        ));
  }

  Widget loginButton() {
    return Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: UniversalVariables.senderColor,
        child: FlatButton(
          padding: EdgeInsets.all(35),
          child: Text(
            "LOGIN",
            style: TextStyle(
                fontSize: 45, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          onPressed: () {
            print("Clicked Here");
            performLogin();
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
  }

  void performLogin() {
    print("Clicked");
    setState(() {
      isLoginPressed = true;
    });
    _repository.signIn().then((AuthResult user) {
      if (user != null) {
        authenticateUser(user);
      } else {
        print("There was an error");
      }
    });
  }

  void authenticateUser(AuthResult user) {
    setState(() {
      isLoginPressed = false;
    });
    _repository.authenticateUser(user).then((isNewUser) {
      if (isNewUser) {
        _repository.addDataToDb(user.user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}
