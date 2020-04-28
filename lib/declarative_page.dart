import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'dart:convert';
import 'dart:async';

import 'http_handler.dart';

class DeclarativePage extends StatefulWidget {
  @override
  _DeclarativePageState createState() => _DeclarativePageState();
}

class _DeclarativePageState extends State<DeclarativePage> {
  final _apiUrl = 'https://api.github.com/repositories?since=364';

  bool _hasStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Declarative example'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.get_app),
        onPressed: () {
          setState(() {
            _hasStarted = true;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_hasStarted) {
      return HttpHandler<Response, List<GitRepository>>(
        stream: Stream.fromFuture(_fetchGithubRepos()),
        converter: (response) {
          final body = response.body;
          final data = json.decode(body) as List;
          return data.map((item) {
            final name = item['full_name'] as String;
            final description = item['description'] as String;
            final owner = item['owner'] as Map;
            final avatar =
            owner != null ? (owner['avatar_url'] as String) : null;
            return GitRepository(
                name: name, description: description, avatar: avatar);
          }).toList(growable: false);
        },
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final list = snapshot.data;
            return _buildReposList(list);
          } else {
            return _buildLoading();
          }
        },
      );
    } else {
      return _buildPlaceholder();
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

  Widget _buildReposList(List<GitRepository> list) {
    return ListView.builder(
      itemBuilder: (_, index) => ListTile(
        leading: Image.network(
          list[index].avatar,
          width: 32.0,
          height: 32.0,
        ),
        title: Text(list[index].name ?? '...'),
        subtitle: Text(list[index].description ?? '...'),
      ),
      itemCount: list.length,
    );
  }

  Future<Response> _fetchGithubRepos() {
    return get(_apiUrl);
  }
}

class GitRepository {
  final String name;
  final String description;
  final String avatar;

  GitRepository({this.name, this.description, this.avatar});
}
