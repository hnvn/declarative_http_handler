import 'package:flutter/material.dart';

class DeclarativePage extends StatefulWidget {
  @override
  _DeclarativePageState createState() => _DeclarativePageState();
}

class _DeclarativePageState extends State<DeclarativePage> {
  final _apiUrl = 'https://api.github.com/repositories?since=364';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Declarative example'),
      ),
      body: Center(
        child: Text('Hey guy, you are in the declarative example'),
      ),
    );
  }
}
