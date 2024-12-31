
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget{
  final controller;
  final String hintText;
  final bool obscureText;


  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,

  });
      
  @override
  Widget build(BuildContext context){

    return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child:TextFormField(
                controller: controller,
                decoration: InputDecoration(labelText: hintText),
                obscureText: obscureText,
                validator: (value) {
                  if (value?.isEmpty??true) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              )
      );

  } 
}