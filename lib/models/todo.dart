class Todo {
  Todo();

  int id;
  String title;
  DateTime dueAt;
  DateTime completedAt;
  bool done;

  static final columns = [
    "id", "title", "due_at", "completed_at", "done"
  ];

  static String get CREATE_TABLE => """CREATE TABLE todos (
              id INTEGER PRIMARY KEY, 
              title TEXT NOT NULL,
              due_at DATETIME,
              completed_at DATETIME,
              done boolean
            )""";

  static String get TABLE_NAME => "todos";

  Map toMap() {
    Map map = {
      "title": title,
      "due_at": dueAt.toString(),
      "completed_at": completedAt.toString(),
      "done": done
    };

    if(id != null) {
      map["id"] = id;
    }

    return map;
  }

  static fromMap(Map map) {
    Todo todo = new Todo();
    todo.id    = map["id"];
    todo.title = map["title"];
    todo.dueAt = DateTime.parse(map["due_at"]);
//    todo.completedAt = DateTime.parse(map["completed_at"]);
    todo.done = map["done"];
    return todo;
  }

  String toString() {
    return toMap().toString();
  }
}