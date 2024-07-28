import 'package:flutter/material.dart';
import 'package:stocksync/models/completed_task.dart';
import 'package:stocksync/services/firebase_service.dart';
import 'package:intl/intl.dart';

class CurrentSupervisorDashboard extends StatefulWidget {
  final FirebaseService firebaseService = FirebaseService();
  final String supervisorId;

  CurrentSupervisorDashboard({required this.supervisorId});

  @override
  _CurrentSupervisorDashboardState createState() => _CurrentSupervisorDashboardState();
}

class _CurrentSupervisorDashboardState extends State<CurrentSupervisorDashboard> {
  late Future<List<CompletedWork>> _completedWorksFuture;

  @override
  void initState() {
    super.initState();
    _completedWorksFuture = _fetchCompletedWorks();
  }

  Future<void> _refuseCompletion(BuildContext context, CompletedWork completedWork) async {
    try {
      await widget.firebaseService.deleteCompletedWork(completedWork.id);

      // Debug log for reassign task parameters
      print('Reassigning task: ${completedWork.taskId} to employee: ${completedWork.employeeId}');

      await widget.firebaseService.reassignTask(completedWork.taskId, completedWork.employeeId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task reassigned to employee.')),
      );
      _refreshCompletedWorks();
    } catch (e) {
      print('Error refusing completion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refusing completion: $e')),
      );
    }
  }

  Future<List<CompletedWork>> _fetchCompletedWorks() async {
    try {
      print('Fetching completed works for supervisor ID: ${widget.supervisorId}');
      List<CompletedWork> completedWorks = await widget.firebaseService.getCompletedWorksBySupervisor(widget.supervisorId);
      print('Fetched ${completedWorks.length} completed works');
      return completedWorks;
    } catch (e) {
      print('Error fetching completed works: $e');
      throw Exception('Error fetching completed works: $e');
    }
  }

  Future<void> _refreshCompletedWorks() async {
    setState(() {
      _completedWorksFuture = _fetchCompletedWorks();
    });
  }

  Future<void> _confirmCompletion(BuildContext context, CompletedWork completedWork) async {
    try {
      await widget.firebaseService.deleteCompletedWork(completedWork.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task confirmed as completed.')),
      );
      _refreshCompletedWorks();
    } catch (e) {
      print('Error confirming completion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming completion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF61C0BF).withOpacity(0.5),
        title: Text(
          'Personal Dashboard',
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: FutureBuilder<List<CompletedWork>>(
        future: _completedWorksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching completed works: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No completed works.'));
          }

          final completedWorks = snapshot.data!;

          return RefreshIndicator(
            displacement: 200,
            onRefresh: _refreshCompletedWorks,
            child: ListView.builder(
              itemCount: completedWorks.length,
              itemBuilder: (context, index) {
                final completedWork = completedWorks[index];

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    return Card(
                      margin: EdgeInsets.all(width * 0.02),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/9019808.jpg'), // Replace with your image path
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(width * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    completedWork.taskName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Courier',
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.blueAccent,
                                          offset: Offset(0, 0),
                                        ),
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.white,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Completed by: ${completedWork.employeeId}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: 'Courier',
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.blueAccent,
                                          offset: Offset(0, 0),
                                        ),
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.white,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Completed on: ${DateFormat('yyyy-MM-dd HH:mm').format(completedWork.completedDate)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: 'Courier',
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.blueAccent,
                                          offset: Offset(0, 0),
                                        ),
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.white,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  if (completedWork.imageUrls.isNotEmpty)
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: completedWork.imageUrls.map((url) {
                                        return Container(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                                            width: width * 0.3,
                                            height: width * 0.3,
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                            ),

                                        );
                                      }).toList(),
                                    ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await _confirmCompletion(context, completedWork);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            side: BorderSide(width: 3,color: Colors.white),
                                            foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                                          ),
                                          child: Text('Approve'),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await _refuseCompletion(context, completedWork);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            side: BorderSide(width: 3,color: Colors.white),
                                            foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                                          ),
                                          child: Text('Reject'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
