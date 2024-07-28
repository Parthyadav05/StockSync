

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stocksync/models/task.dart';
import 'package:stocksync/models/user_model.dart';
import 'package:stocksync/screen/curr_supervisor_dashboard.dart';
import 'package:stocksync/services/firebase_service.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telephony/telephony.dart';

class SupervisorDashboard extends StatefulWidget {
  final UserModel user;

  SupervisorDashboard({required this.user});

  @override
  _SupervisorDashboardState createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final FirebaseService firebaseService = FirebaseService();
  final TextEditingController _taskDescriptionController = TextEditingController();
  final Telephony telephony = Telephony.instance;
  List<UserModel> employees = [];
  List<Tasks> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    FirebaseFirestore.instance.collection('tasks').snapshots().listen((snapshot) {
      setState(() {
        tasks = snapshot.docs.map((doc) => Tasks.fromJson(doc.data() as Map<String, dynamic>)).toList();
      });
    });

    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      setState(() {
        employees = snapshot.docs.map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
      });
    });
  }

  Future<void> _onRefresh() async {
    await _fetchData();
  }

  Future<void> addTask() async {
    String id = Uuid().v4();
    DateTime assignedDate = DateTime.now();
    Tasks newTask = Tasks(
      id: id,
      description: _taskDescriptionController.text,
      assignedTo: '',
      assignedBy: widget.user.id, // Assign the current supervisor ID
      status: 'pending',
      assignedDate: assignedDate,
    );
    try {
      if (newTask.description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task Description is Empty')),
        );
      } else {
        await firebaseService.addTask(newTask);
        _taskDescriptionController.clear();
      }
    } catch (e) {
      print('Error adding task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task.')),
      );
    }
  }

  Future<void> assignTaskToEmployee(String employeeId, Tasks task) async {
    UserModel employee = employees.firstWhere((e) => e.id == employeeId);
    if (employee.isBusy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected employee is currently busy.')),
      );
      return;
    }

    Tasks updatedTask = Tasks(
      id: task.id,
      description: task.description,
      assignedTo: employeeId,
      assignedBy: widget.user.id, // Set the current supervisor ID
      status: 'pending',
      assignedDate: DateTime.now(),
    );

    try {
      await firebaseService.assignTaskToEmployee(updatedTask.id, employeeId);
      await firebaseService.updateEmployeeStatus(employeeId, true);

      if (employee.phoneNumber != null) {
        final message = 'You have been assigned a new task: ${task.description}. Please check your dashboard for details.';
        await sendSms(employee.phoneNumber!, message);
      }
    } catch (e) {
      print('Error assigning task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign task.')),
      );
    }
  }

  Future<void> sendSms(String phoneNumber, String message) async {
    try {
      await telephony.sendSms(
        to: '+91$phoneNumber',
        message: message,
      );
      print('SMS sent successfully.');
    } catch (e) {
      print('Error sending SMS: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send SMS.')),
      );
    }
  }

   Widget _buildEmployeeTile(UserModel employee) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 3.0, style: BorderStyle.solid),
          gradient: LinearGradient(
            colors: employee.isBusy
                ? [Colors.red[800]!, Colors.red[400]!]
                : [Colors.green[600]!, Colors.green[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16.0),
          title: Text(
            employee.name,
            style: TextStyle(color: Colors.white, fontFamily: 'Courier', fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.isBusy ? 'Busy' : 'Available',
                style: TextStyle(color: Colors.white70, fontFamily: 'Courier'),
              ),
              if (employee.isBusy) ...[
                Text(
                  'Assigned: ${tasks.firstWhere((task) => task.assignedTo == employee.id, orElse: () => Tasks(id: '', description: '', assignedTo: '', assignedBy: '', status: '', assignedDate: null)).assignedDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(tasks.firstWhere((task) => task.assignedTo == employee.id, orElse: () => Tasks(id: '', description: '', assignedTo: '', assignedBy: '', status: '', assignedDate: null)).assignedDate!) : 'N/A'}',
                  style: TextStyle(color: Colors.white70, fontFamily: 'Courier'),
                ),
              ],
            ],
          ),
          trailing: employee.isBusy
              ? null
              : Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(width: 2)
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButton<String>(
                value: null,
                borderRadius: BorderRadius.circular(8),
                elevation: 16,

                iconEnabledColor: Colors.white,
                hint: Text('Assign Task', style: TextStyle(color: Colors.black,fontFamily: 'Courier')),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    final task = tasks.firstWhere((t) => t.id == newValue);
                    assignTaskToEmployee(employee.id, task);
                  }
                },
                items: tasks.map<DropdownMenuItem<String>>((Tasks task) {
                  return DropdownMenuItem<String>(
                    value: task.id,
                    child: Text(task.description, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
              ),
            ),
          )
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF61C0BF).withOpacity(0.5),
        title: Text(
          'Supervisor Dashboard',
          style: TextStyle(fontFamily: 'Courier' ,fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(

        child: RefreshIndicator(
          displacement: 200,
          onRefresh: _onRefresh,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    TextField(
                      controller: _taskDescriptionController,
                      style: TextStyle(fontFamily: 'Courier',fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: addTask,
                          icon: Icon(Icons.chevron_right, size: 50),
                        ),
                        prefixIcon: Icon(Icons.add),
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'Task Description',
                        labelStyle: TextStyle(color: Colors.grey, fontFamily: 'Courier' ,fontWeight: FontWeight.bold),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return _buildEmployeeTile(employee);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        elevation: 20,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CurrentSupervisorDashboard(
                supervisorId: widget.user.id, // Pass the supervisor ID
              ),
            ),
          );
        },
        child: FaIcon(FontAwesomeIcons.codePullRequest, color: Colors.black),
      ),
    );
  }
}
