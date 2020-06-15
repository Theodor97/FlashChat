import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:flash_chat/components/button_with_padding.dart';
class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController
      controller; //variable that gonna hold data animationController type
  //we initialize it when our StateObject gets initialized aka initState method
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    animation =
        ColorTween(begin: Colors.grey, end: Colors.white).animate(controller);
    controller.forward(); //forward will proceed our animation
    // animation.addStatusListener((status) {
    //   // status == AnimationStatus.completed?
    // });
    controller.addListener(() {
      setState(() {});
    });
  
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
                    height: 60.0,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  speed: Duration(milliseconds: 500),
                  isRepeatingAnimation: true,
                  text: ['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            ButtonWithPadding(
              text: Text('Log In'),
              color: Colors.lightBlueAccent,
              buttonFunction: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            ButtonWithPadding(
              text: Text('Register'),
              color: Colors.blueAccent,
              buttonFunction: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
