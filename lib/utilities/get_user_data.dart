
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class GetUserData{
  Future<bool> checkLoggedIn() async{
    //check if there's a user already logged in
    Completer<bool> complete = Completer();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        complete.complete(true);
      }else{
        complete.complete(false);
      }
    });
    //uncomment this once all the pages before main homepage completes
    return complete.future;

  }
}