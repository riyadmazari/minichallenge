import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Model for Task
class Task {
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });
}

// TaskProvider to manage state
class TaskProvider with ChangeNotifier {
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];

  List<Task> get pendingTasks => _pendingTasks;
  List<Task> get completedTasks => _completedTasks;

  void addTask(Task task) {
    _pendingTasks.add(task);
    notifyListeners();
  }

  void completeTask(Task task) {
    _pendingTasks.remove(task);
    task.isCompleted = true;
    _completedTasks.add(task);
    notifyListeners();
  }

  void uncompleteTask(Task task) {
    _completedTasks.remove(task);
    task.isCompleted = false;
    _pendingTasks.add(task);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MiniChallenge(),
    ),
  );
}

class MiniChallenge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Challenge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isBigScreen = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            title: Text('Mini Challenge'),
          ),
          body: Row(
            children: [
              if (isBigScreen) _buildNavigationRail(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
          bottomNavigationBar: isBigScreen ? null : _buildBottomNavigationBar(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openCreateTaskDialog(context),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.selected,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.list),
          label: Text('Pending'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.check),
          label: Text('Completed'),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Pending',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check),
          label: 'Completed',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return PendingTasksScreen();
    } else {
      return CompletedTasksScreen();
    }
  }

  void _openCreateTaskDialog(BuildContext context) {
    String title = '';
    String description = '';
    DateTime dueDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ),
              TextButton(
                child: Text('Select Due Date'),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != dueDate) {
                    dueDate = pickedDate;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty && description.isNotEmpty) {
                  Provider.of<TaskProvider>(context, listen: false).addTask(
                    Task(title: title, description: description, dueDate: dueDate),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

// Pending Tasks Screen
class PendingTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return ListView.builder(
          itemCount: taskProvider.pendingTasks.length,
          itemBuilder: (context, index) {
            Task task = taskProvider.pendingTasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text('Due: ${task.dueDate.toLocal()}'),
              trailing: IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  taskProvider.completeTask(task);
                },
              ),
            );
          },
        );
      },
    );
  }
}

// Completed Tasks Screen
class CompletedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return ListView.builder(
          itemCount: taskProvider.completedTasks.length,
          itemBuilder: (context, index) {
            Task task = taskProvider.completedTasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text('Completed: ${task.dueDate.toLocal()}'),
              trailing: IconButton(
                icon: Icon(Icons.undo),
                onPressed: () {
                  taskProvider.uncompleteTask(task);
                },
              ),
            );
          },
        );
      },
    );
  }
}
