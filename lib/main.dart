import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_list/models/database_client.dart';
import 'package:todo_list/models/todo.dart';

void main() {
  DatabaseClient db = new DatabaseClient();
  db.create();
  _loadTodoListView(db);
}

final List<TodoListView> _loadedTodos = <TodoListView>[];

Future _loadTodoListView(db) async {
  List<Todo> _todoObjects = await db.fetchTodos(100);
  _todoObjects.forEach((todo) {
    TodoListView listView = new TodoListView(
        text: todo.toString()
    );
    _loadedTodos.add(listView);
  });
  runApp(new TodoList(db));
}

class TodoList extends StatelessWidget {

  final DatabaseClient db;
  TodoList(this.db);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Todo List',
        theme: new ThemeData(
            platform: TargetPlatform.fuchsia,
            primaryColor: const Color(0xFF373a3c),
            accentColor: const Color(0xFF60b044)
        ),
        home: new TodoListApp(db)
    );
  }
}

class TodoListApp extends StatefulWidget {
  final DatabaseClient db;
  TodoListApp(this.db);

  State<StatefulWidget> createState() => new TodoListAppState(db);
}

class TodoListAppState extends State<TodoListApp>
    with TickerProviderStateMixin {
  List<TodoListView> _todos = <TodoListView>[];
  final DatabaseClient db;
  int _counter = 0;
  TodoListAppState(this.db);

  @override
  Widget build(BuildContext context) {
    this._todos = _loadedTodos;
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Todo List')
      ),
      body: new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        itemBuilder: (_, index) => _todos[index],
        itemCount: _todos.length,
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Theme.of(context).accentColor,
        child: new Icon(Icons.add),
      ),
    );
  }

  Future _addTodo() async {
    Todo todo = new Todo();
    _counter++;
    todo.title = 'Task $_counter';
    todo.dueAt = new DateTime.now();

    todo = await db.insertTodo(todo);

    TodoListView todoListView = new TodoListView(
        text: todo.toString()
    );

    setState(() {
      _todos.insert(0, todoListView);
    });

  }
}

class TodoListView extends StatelessWidget {
  final String text;
  TodoListView({this.text});

  @override
  Widget build(BuildContext context) {
    return  new Container(
        margin: const EdgeInsets.all(8.0),
        child: new Text(text, style: Theme.of(context).textTheme.subhead)
    );
  }
}