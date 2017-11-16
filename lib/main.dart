import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/models/todo_provider.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/presenters/todo_presenter.dart';

final TodoProvider _provider = new TodoProvider();

void main() {
  runApp(new TodoList());
}

Todo _updateTodo;

class TodoList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Todo List',
        theme: new ThemeData(
            platform: TargetPlatform.fuchsia,
            primaryColor: const Color(0xFF373a3c),
            accentColor: const Color(0xFF60b044)
        ),
        home: new TodoListApp(),
        routes: {
          'home': (BuildContext context) => new TodoListApp(),
          TodoForm.routeName:
              (BuildContext context) => new TodoFormState()

        }
    );
  }
}

class TodoListApp extends StatefulWidget {

  TodoListApp({Key key}) : super(key: key);

  State<StatefulWidget> createState() => new TodoListAppState();
}

class TodoListAppState extends State<TodoListApp>
    implements TodoListAppStateView {

  ScrollController scrollController = new ScrollController();
  List<TodoListView> _todos = <TodoListView>[];
  int _limit = 50;
  TodoPresenter _presenter;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_paginateTodos);
    _isLoading = true;
    _presenter = new TodoPresenter(this, _provider);
    _presenter.fetch(_limit);
  }

  @override
  void onLoadTodosComplete(List<Todo> results) {
    results.forEach((todo) {
      _todos.add(_buildListView(todo));
    });

    setState(() {
      _isLoading = false;
      _todos = _todos;
    });
  }

  @override
  void onLoadTodosError(var e) {
    print(e.toString());
    TodoListView listView = new TodoListView(
        text: 'Something went wrong!'
    );
    setState(() {
      _todos.clear();
      _todos.add(listView);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_updateTodo  != null) {
      _todos.insert(0, _buildListView(_updateTodo));
      _updateTodo = null;
    }

    Widget _scrollView = new Scrollbar(
      child: new ListView.builder(
        controller: scrollController,
        itemBuilder: (_, index) => _todos[index],
        itemCount: _todos.length,
      ),
    );

    Widget _progressBar = new Center(
        child: new CircularProgressIndicator(
          backgroundColor: Theme.of(context).accentColor,
        )
    );

    Widget _finalView = _isLoading ? _progressBar : _scrollView;

    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Todo List')
      ),
      body: _finalView,
      floatingActionButton: new FloatingActionButton(
        onPressed: _openDialog,
        backgroundColor: Theme.of(context).accentColor,
        child: new Icon(Icons.add),
      ),
    );
  }

  void _openDialog() {
    Navigator.pushNamed(context, TodoForm.routeName);
  }

  String _todoText(Todo todo) {
    return "${todo.title}";
  }

  String _todoDueDate(Todo todo) {
    var formatter = new DateFormat("'at' h:m a 'on' d, MMM, yyyy ");
    return formatter.format(todo.dueAt);
  }

  TodoListView _buildListView(Todo todo) {
    assert(todo != null);
    return new TodoListView(
      text: _todoText(todo),
      due_at: _todoDueDate(todo),
    );
  }

  Future _paginateTodos() async {
    _limit = _limit + 51;
    await _presenter.fetch(_limit);
  }
}

class TodoListView extends StatelessWidget {
  final String text;
  final String due_at;
  TodoListView({this.text, this.due_at});

  @override
  Widget build(BuildContext context) {
    var colors = [100,200,300,400,500,600,700];
    var random = new Random();
    return  new Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.green[colors[random.nextInt(colors.length)]],
      child: new Column(
        children: <Widget>[
          new Text(text, style: Theme.of(context).textTheme.title),
          new Text(due_at, style: Theme.of(context).textTheme.subhead)
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

class TodoFormState extends StatefulWidget {
  TodoFormState({Key key}) : super(key: key);
  State<StatefulWidget> createState() => new TodoForm();
}

class TodoForm extends State<TodoFormState> {

  final TextEditingController textTitleEditingController =
  new TextEditingController();
  DateTime _fromDate = new DateTime.now();
  TimeOfDay _fromTime = const TimeOfDay(hour: 7, minute: 28);
  static String routeName = "form";

  BuildContext _context;
  Drawer drawer;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return new Scaffold(
      drawer: drawer,
      appBar: new AppBar(title: new Text("Add Todo Task")),
      body: new Container(
          margin: const EdgeInsets.all(16.0),
          child: new Column(children: <Widget>[
            new TextField(
              controller: textTitleEditingController,
              onSubmitted: null,
              autofocus: true,
              decoration: new InputDecoration(
                hintText: "Add Title",
              ),
            ),
            new _DateTimePicker(
              labelText: 'From',
              selectedDate: _fromDate,
              selectedTime: _fromTime,
              selectDate: (DateTime date) {
                setState(() {
                  _fromDate = date;
                });
              },
              selectTime: (TimeOfDay time) {
                setState(() {
                  _fromTime = time;
                });
              },
            ),
            new MaterialButton(
              color: Theme.of(context).accentColor,
                child: new Text(
                    "SUBMIT",
                    style: new TextStyle(
                        color: Colors.white
                    )
                ),
                onPressed: _submitForm
            )
          ],
          )
      ),
    );
  }

  Future _submitForm() async {
    Todo todo = new Todo();
    todo.title = textTitleEditingController.text;
    var dateFormatter = new DateFormat("yyyy-MM-d ");
    String date = dateFormatter.format(_fromDate);
    int h = _fromTime.hour;
    String hours = h < 10 ? "0" + h.toString() : h.toString();
    int m = _fromTime.minute;
    String minutes = m < 10 ? "0" + m.toString() : m.toString();
    todo.dueAt = DateTime.parse(date + hours + ":" + minutes + ":00");
    todo = await _provider.insertTodo(todo);
    _updateTodo = todo;
    Navigator.pop(_context);
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    Key key,
    this.labelText,
    this.selectedDate,
    this.selectedTime,
    this.selectDate,
    this.selectTime
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: new DateTime(2015, 8),
        lastDate: new DateTime(2101)
    );
    if (picked != null && picked != selectedDate)
      selectDate(picked);
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: selectedTime
    );
    if (picked != null && picked != selectedTime)
      selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new _InputDropdown(
            labelText: labelText,
            valueText: new DateFormat.yMMMd().format(selectedDate),
            valueStyle: valueStyle,
            onPressed: () { _selectDate(context); },
          ),
        ),
        const SizedBox(width: 12.0),
        new Expanded(
          flex: 3,
          child: new _InputDropdown(
            valueText: selectedTime.format(context),
            valueStyle: valueStyle,
            onPressed: () { _selectTime(context); },
          ),
        ),
      ],
    );
  }
}

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new InputDecorator(
        decoration: new InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
            new Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70
            ),
          ],
        ),
      ),
    );
  }
}
