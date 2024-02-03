import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/widgets/welcomeButtons.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {

  static String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  late Animation animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // animation = CurvedAnimation(  for curved animations using the Curves class for future reference
    //   parent: animationController,
    //   curve: Curves.fastOutSlowIn,
    // );

    animation = ColorTween(
      begin: Colors.blueGrey,
      end: Colors.white
    ).animate(animationController);

    animationController.forward(); //animate ~60 steps from 0 to 1
    animationController.addListener(() {
      setState(() {});

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60,
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Flash Chat',
                      textStyle: TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black
                      ),
                      speed: Duration(milliseconds: 150)

                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            WelcomeButtons(
              color: Colors.lightBlueAccent,
              text: 'Log In',
              onPressed: (){
                Navigator.pushNamed(context, LoginScreen.id);
              }),
            WelcomeButtons(
              color: Colors.blueAccent,
              text: 'Register',
              onPressed: (){
                Navigator.pushNamed(context, RegistrationScreen.id);
              }),
          ],
        ),
      ),
    );
  }
}
