import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:stocksync/models/completed_task.dart';
import 'package:stocksync/models/task.dart';
import 'package:stocksync/models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final storage.FirebaseStorage _storage = storage.FirebaseStorage.instance;

  Future<void> registerUser(String email, String password, String name, String role, String phoneNumber) async {
    try {
      final auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String userId = userCredential.user!.uid;
      final UserModel newUser = UserModel(
        id: userId,
        name: name,
        role: role,
        phoneNumber: phoneNumber,
      );
      await _firestore.collection('users').doc(userId).set(newUser.toJson());
    } catch (e) {
      print('Error registering user: $e');
      throw Exception('Error registering user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      throw Exception('Error getting user: $e');
    }
  }

  Future<void> addEmployee(UserModel employee) async {
    try {
      if (employee.id.isEmpty) {
        throw Exception('Employee ID cannot be empty');
      }
      await _firestore.collection('users').doc(employee.id).set(employee.toJson());
    } catch (e) {
      print('Error adding employee: $e');
      throw Exception('Error adding employee: $e');
    }
  }

  Future<List<UserModel>> getEmployees() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting employees: $e');
      throw Exception('Error getting employees: $e');
    }
  }

  Future<void> addTask(Tasks task) async {
    try {
      if (task.id.isEmpty) {
        throw Exception('Task ID cannot be empty');
      }
      await _firestore.collection('tasks').doc(task.id).set(task.toJson());
    } catch (e) {
      print('Error adding task: $e');
      throw Exception('Error adding task: $e');
    }
  }

  Future<List<Tasks>> getTasks() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('tasks').get();
      return snapshot.docs.map((doc) => Tasks.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting tasks: $e');
      throw Exception('Error getting tasks: $e');
    }
  }

  Future<void> updateEmployeeStatus(String employeeId, bool isBusy) async {
    try {
      if (employeeId.isEmpty) {
        throw Exception('Employee ID cannot be empty');
      }
      await _firestore.collection('users').doc(employeeId).update({'isBusy': isBusy});
    } catch (e) {
      print('Error updating employee status: $e');
      throw Exception('Error updating employee status: $e');
    }
  }

  Future<void> assignTaskToEmployee(String taskId, String employeeId) async {
    try {
      if (taskId.isEmpty || employeeId.isEmpty) {
        throw Exception('Task ID and Employee ID cannot be empty');
      }
      await _firestore.collection('tasks').doc(taskId).update({'assignedTo': employeeId, 'status': 'assigned'});
    } catch (e) {
      print('Error assigning task: $e');
      throw Exception('Error assigning task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw Exception('Task ID cannot be empty');
      }
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      throw Exception('Error deleting task: $e');
    }
  }

  Future<String> uploadImage(String path, File image) async {
    final storageRef = _storage.ref().child(path);
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> saveCompletedWork(CompletedWork completedWork) async {
    await _firestore.collection('completedWorks').doc(completedWork.id).set(completedWork.toJson());
  }



  Future<void> reassignTask(String taskId, String employeeId) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(taskId);
      final docSnapshot = await taskRef.get();

      if (!docSnapshot.exists) {
        print('Document does not exist: $taskId');
        throw Exception('Document does not exist: $taskId');
      }

      await taskRef.update({
        'assignedTo': employeeId,
        'status': 'pending',
      });
    } catch (e) {
      print('Error reassigning task: $e');
      throw Exception('Error reassigning task: $e');
    }
  }

  Future<void> deleteCompletedWork(String workId) async {
    try {
      await _firestore.collection('completedWorks').doc(workId).delete();
    } catch (e) {
      print('Error deleting completed work: $e');
      throw Exception('Error deleting completed work: $e');
    }
  }
  Future<UserModel?> getUserById(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<CompletedWork>> getCompletedWorksBySupervisor(String supervisorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('completedWorks')
          .where('supervisorId', isEqualTo: supervisorId)
          .get();

      return snapshot.docs.map((doc) {
        return CompletedWork.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching completed works: $e');
      throw Exception('Error fetching completed works: $e');
    }
  }


  Future<void> updateTaskStatus(String taskId, String status) async {
    await _firestore.collection('tasks').doc(taskId).update({'status': status});
  }
}
