import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';

import 'dart:async';

typedef ResponseConverter<Data extends Response, Model> = Model Function(
    Response);

class HttpHandler<Data extends Response, Model> extends StatefulWidget {
  final Stream<Data> stream;
  final ResponseConverter converter;
  final AsyncWidgetBuilder<Model> builder;

  HttpHandler(
      {Key key,
      @required this.stream,
      @required this.converter,
      @required this.builder})
      : super(key: key);

  @override
  _HttpHandlerState<Data, Model> createState() =>
      _HttpHandlerState<Data, Model>();
}

class _HttpHandlerState<Data extends Response, Model>
    extends State<HttpHandler<Data, Model>> {
  final _dataController = BehaviorSubject<Model>();
  StreamSubscription<Response> _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Model>(
      stream: _dataController.stream.distinct(),
      builder: widget.builder,
    );
  }

  @override
  void didUpdateWidget(HttpHandler<Response, Model> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      if (_subscription != null) {
        _unsubscribe();
      }
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    _dataController.close();
    super.dispose();
  }

  void _subscribe() {
    if (widget.stream != null) {
      _subscription = widget.stream.listen((Response data) {
        int status = data.statusCode;
        if (status == 200) {
          _dataController.sink.add(widget.converter(data));
        } else {
          _showError();
        }
      }, onError: (e) {
        _showError();

        _dataController.sink.addError(e);
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  _showError() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Error'),
              content: Text('Oppp!! Something went wrong.'),
            ));
  }
}
