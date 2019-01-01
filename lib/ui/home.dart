import 'package:flutter/material.dart';
import 'no_todo_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: Text('NO TODO APP'), backgroundColor: Colors.black54,),

      body: new NoTodoScreen(),
    );
  }
}