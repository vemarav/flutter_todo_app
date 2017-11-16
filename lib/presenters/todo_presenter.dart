import 'dart:async';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/models/todo_provider.dart';

abstract class TodoListAppStateView {
  void onLoadTodosComplete(List<Todo> results);
  void onLoadTodosError(var e);
}

class TodoPresenter {
  TodoListAppStateView _view;
  TodoProvider _provider;

  TodoPresenter(this._view, this._provider);

  Future fetch(limit) async {
    assert(_view != null);
    _provider.fetchTodos(limit)
        .then((todos) => _view.onLoadTodosComplete(todos))
        .catchError((error) => _view.onLoadTodosError(error));
  }
}