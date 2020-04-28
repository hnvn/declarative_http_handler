import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class ImperativePage extends StatefulWidget {
  @override
  _ImperativePageState createState() => _ImperativePageState();
}

class _ImperativePageState extends State<ImperativePage> {
  final _apiUrl = 'https://api.github.com/repositories?since=364';
  final _reposList = [];
  bool _loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imperative example'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.get_app),
        onPressed: () {
          setState(() {
            _loading = true;
          });
          _fetchGithubRepos();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading == null) {
      return _buildPlaceholder();
    } else if (_loading) {
      return _buildLoading();
    } else {
      return _buildReposList();
    }
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Click button '),
          Icon(Icons.get_app),
          Text(' to start')
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildReposList() {
    return ListView.builder(
      itemBuilder: (_, index) {
        final name = _reposList[index]['full_name'] as String;
        final description = _reposList[index]['description'] as String;
        final owner = _reposList[index]['owner'] as Map;
        final avatarUrl =
            owner != null ? (owner['avatar_url'] as String) : null;
        return ListTile(
          leading: Image.network(
            avatarUrl,
            width: 32.0,
            height: 32.0,
          ),
          title: Text(name ?? "..."),
          subtitle: Text(description ?? "..."),
        );
      },
      itemCount: _reposList.length,
    );
  }

  _fetchGithubRepos() {
    http.get(_apiUrl).then((response) {
      if (response.statusCode == 200) {
        final body = response.body;
        final data = json.decode(body) as List;
        _reposList.clear();
        _reposList.addAll(data);
        setState(() {
          _loading = false;
        });
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Oppp!! Something went wrong.'),
                ));
      }
    });
  }
}
