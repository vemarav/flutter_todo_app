import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/todo.dart';

class TodoProvider {
  Database _db;

  Future create() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbPath = join(path.path, 'todo_list.db');

    _db = await openDatabase(dbPath, version: 1, onCreate: this._create);
  }

  Future _create(Database db, int version) async {
    print(Todo.CREATE_TABLE);
    db.execute(Todo.CREATE_TABLE);
  }

  Future<Todo> insertTodo(Todo todo) async {
    if (_db == null) {
      Directory path = await getApplicationDocumentsDirectory();
      String dbPath = join(path.path, 'todo_list.db');

      _db = await openDatabase(dbPath, version: 1, onCreate: this._create);
    }

    todo.id = await _db.insert(Todo.TABLE_NAME, todo.toMap());
    return todo;
  }

  Future<List> fetchTodos(int limit) async {
    if (_db == null) {
      Directory path = await getApplicationDocumentsDirectory();
      String dbPath = join(path.path, 'todo_list.db');

      _db = await openDatabase(dbPath, version: 1, onCreate: this._create);
    }

    List results = await _db.query(
        Todo.TABLE_NAME,
        columns: Todo.columns,
        limit: limit, offset: limit - 50, orderBy: "id DESC");
    List<Todo> _todos = <Todo>[];
    results.forEach((result) {
      Todo todo = Todo.fromMap(result);
      _todos.add(todo);
    });
//    print("LIMIT " + limit.toString() + " OFFSET "
//        + (limit - 50).toString());
    return _todos;
  }

  Future<Todo> fetchTodo(Todo todo) async {
    if (_db == null) {
      Directory path = await getApplicationDocumentsDirectory();
      String dbPath = join(path.path, 'todo_list.db');

      _db = await openDatabase(dbPath, version: 1, onCreate: this._create);
    }
    List results = await _db.query(Todo.TABLE_NAME,
        columns: Todo.columns, where: "title = ?", whereArgs: [todo.title]);

    todo = Todo.fromMap(results[0]);

    return todo;
  }

  Future close() async {
    _db.close();
  }
}