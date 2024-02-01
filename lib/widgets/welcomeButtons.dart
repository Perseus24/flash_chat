

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';

class WelcomeButtons extends StatelessWidget{
  WelcomeButtons({required this.onPressed, required this.text, required this.color});

  final Color color;
  final Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}