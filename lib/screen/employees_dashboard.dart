import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:stocksync/models/completed_task.dart';
import 'package:stocksync/models/task.dart';
import 'package:stocksync/models/user_model.dart';
import 'package:stocksync/services/firebase_service.dart';
import 'package:google_gemini/google_gemini.dart';

class EmployeeDashboard extends StatefulWidget {
  final UserModel user;

  EmployeeDashboard({required this.user});

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> with SingleTickerProviderStateMixin {
  final FirebaseService firebaseService = FirebaseService();
  final gemini = GoogleGemini(
    apiKey: "", // Replace with your actual API key
  );
  Tasks? currentTask;
  List<File> selectedImages = [];
  String aiReview = '';
  bool isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> refreshTasks() async {
    _controller.repeat(reverse: true); // Start animation
    await _fetchAssignedTask(); // Your function to fetch tasks
    _controller.reset(); // Reset animation
  }

  Future<void> _fetchAssignedTask() async {
    try {
      _controller.forward(from: 0.0);
      final tasks = await firebaseService.getTasks();
      final assignedTask = tasks.firstWhere(
            (task) => task.assignedTo == widget.user.id && task.status != 'completed',
        orElse: () => Tasks(
          id: '',
          description: '',
          assignedTo: '',
          assignedBy: '',
          status: '',
          assignedDate: null,
        ),
      );
      setState(() {
        currentTask = assignedTask.id.isNotEmpty ? assignedTask : null;
      });
    } catch (e) {
      _handleError('Error fetching assigned task: $e');
    } finally {
      _controller.stop();
    }
  }

  Future<void> _selectImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        selectedImages = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> generateAIReview() async {
    if (currentTask != null) {
      try {
        final response = await gemini.generateFromText(
          "Analyze the following task description and provide insights under 40 words: ${currentTask!.description}. Do not include the question in the response.",
        );

        setState(() {
          aiReview = response != null ? response.text : 'No review available';
        });
        _showSnackBar('AI review generated successfully.');
      } catch (e) {
        _handleError('Error generating AI review: $e');
      }
    } else {
      _showSnackBar('Please ensure a task is assigned.');
    }
  }

  Future<void> reportTaskCompleted() async {
    if (currentTask != null) {
      setState(() {
        isLoading = true;
      });
      try {
        List<String> imageUrls = [];
        for (var image in selectedImages) {
          final imageUrl = await firebaseService.uploadImage(
            'tasks/${currentTask!.id}/${image.path.split('/').last}',
            image,
          );
          imageUrls.add(imageUrl);
        }

        final completedWork = CompletedWork(
          id: Uuid().v4(),
          taskId: currentTask!.id,
          taskName: currentTask!.description,
          employeeId: widget.user.id,
          supervisorId: currentTask!.assignedBy,
          imageUrls: imageUrls,
          completedDate: DateTime.now(),
        );

        await firebaseService.saveCompletedWork(completedWork);
        await firebaseService.updateTaskStatus(currentTask!.id, 'completed');
        await firebaseService.updateEmployeeStatus(widget.user.id, false);

        setState(() {
          currentTask = null;
          selectedImages = [];
          aiReview = '';
        });
        await _fetchAssignedTask();

        _showSnackBar('Task reported as completed.');
      } catch (e) {
        _handleError('Error reporting task: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleError(String message) {
    print(message);
    _showSnackBar(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF61C0BF).withOpacity(0.5),
        title: Text(
          'Worker Dashboard',
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: AnimatedIcon(
              size: 30,
              icon: AnimatedIcons.search_ellipsis,
              progress: _controller,
            ),
            onPressed: _fetchAssignedTask,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: currentTask == null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No current task assigned',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
                fontFamily: 'Courier',
              ),
            ),
          ),
        )
            : ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/ggfyjy24.jpg'), // Replace with your image path
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF61C0BF).withOpacity(0.6),
                    spreadRadius: 4,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    spreadRadius: -4,
                    blurRadius: 12,
                    offset: Offset(-4, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Description:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Courier',
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Color(0xFFE0F7FA),
                            offset: Offset(0, 0),
                          ),
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.blueAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      currentTask!.description,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.blueAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Assigned Date: ${currentTask!.assignedDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(currentTask!.assignedDate!) : 'N/A'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Color(0xFF61C0BF).withOpacity(0.5),
                            offset: Offset(0, 0),
                          ),
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.blueAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: _selectImages,
                  icon: Icon(Icons.file_upload_outlined, size: 40,),
                  color: Colors.black,
                ),
                SizedBox(width: 16),
                isLoading
                    ? CircularProgressIndicator()
                    : SwipeButton.expand(
                  thumb: Icon(
                    Icons.double_arrow_rounded,
                    color: Colors.white,
                  ),
                  child: Text(
                    "Swipe to Confirm",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  activeThumbColor: Colors.cyan,
                  activeTrackColor: Colors.grey.shade300,
                  width: 250,
                  onSwipe: () async {
                    await reportTaskCompleted();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Task Completed"),
                        backgroundColor: Colors.greenAccent,
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            if (selectedImages.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedImages.map((image) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: 16),
            if (aiReview.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFB2EBF2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '✨ AI Task Review: $aiReview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: generateAIReview,
        child: FaIcon(FontAwesomeIcons.wandMagicSparkles, color: Colors.black87),
        backgroundColor: Color(0xFF61C0BF).withOpacity(0.5),
        tooltip: 'Get AI Help',
      ),
    );
  }
}
