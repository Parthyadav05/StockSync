import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:stocksync/models/user_model.dart';
import 'package:stocksync/services/firebase_service.dart';
import 'supervisor_dashboard.dart';
import 'employees_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  String? _selectedRole;
  final _formKey = GlobalKey<FormState>();

  Future<void> register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String email = _emailController.text;
      final String password = _passwordController.text;
      final String name = _nameController.text;
      final String? phoneNumber = _phoneController.text;

      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a role')),
        );
        return;
      }

      try {
        final auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final String userId = userCredential.user!.uid;

        final newUser = UserModel(
          id: userId,
          name: name,
          role: _selectedRole!,
          phoneNumber: phoneNumber,
        );
        await firebaseService.addEmployee(newUser);

        navigateToDashboard(newUser);
      } catch (e) {
        if (e is auth.FirebaseAuthException && e.code == 'email-already-in-use') {
          // If email is already in use, attempt to log in
          try {
            final auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            final String userId = userCredential.user!.uid;

            final existingUser = await firebaseService.getUser(userId);
            if (existingUser != null && existingUser.role == _selectedRole) {
              navigateToDashboard(existingUser);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Incorrect role selected for this user.')),
              );
            }
          } catch (e) {
            handleAuthException(e);
          }
        } else {
          handleAuthException(e);
        }
      }
    }
  }

  void navigateToDashboard(UserModel user) {
    if (user.role == 'employee') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmployeeDashboard(user: user)),
      );
    } else if (user.role == 'supervisor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SupervisorDashboard(user: user)),
      );
    }
  }

  void handleAuthException(dynamic e) {
    String message = 'An error occurred. Please try again.';
    if (e is auth.FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email address is already in use by another account.';
          break;
        case 'weak-password':
          message = 'The password must be 6 characters long or more.';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        case 'wrong-password':
          message = 'The password is incorrect.';
          break;
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        default:
          message = 'An undefined error happened.';
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF61C0BF);

    InputDecoration inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white, fontFamily: "Courier", fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/rm222batch3-mind-07.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 600,  // Adjust the height as needed
                      decoration: BoxDecoration(
                        color: Colors.transparent.withOpacity(0.2),  // Semi-transparent background
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.black, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2.5,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      fontFamily: "Courier",
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: inputDecoration('Email', Icons.email),
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(color: Colors.white, fontFamily: "Courier"),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  style: TextStyle(color: Colors.white, fontFamily: "Courier"),
                                  decoration: inputDecoration('Password', Icons.lock),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters long';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _nameController,
                                  style: TextStyle(color: Colors.white, fontFamily: "Courier"),
                                  decoration: inputDecoration('Name', Icons.person),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _phoneController,
                                  style: TextStyle(color: Colors.white, fontFamily: "Courier"),
                                  decoration: inputDecoration('Phone Number', Icons.phone),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedRole = 'employee';
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _selectedRole == 'employee' ? primaryColor : Color(0xFFB2EBF2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(width: 3.0, color: Color(0xFFE0F7FA)),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        minimumSize: Size(100, 40),
                                        elevation: 10,
                                        foregroundColor: Colors.tealAccent,
                                      ),
                                      child: Text(
                                        'Worker',
                                        style: TextStyle(
                                          fontFamily: "Courier",
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text("or", style: TextStyle(
                                      fontFamily: "Courier",
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    )),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedRole = 'supervisor';
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _selectedRole == 'supervisor' ? primaryColor : Color(0xFFB2EBF2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(width: 3.0, color: Color(0xFFE0F7FA)),
                                        ),
                                        minimumSize: Size(100, 40),
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        elevation: 10,
                                        foregroundColor: Colors.tealAccent,
                                      ),
                                      child: Text(
                                        'Supervisor',
                                        style: TextStyle(
                                          fontFamily: "Courier",
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),
                                ElevatedButton(
                                  onPressed: register,
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      fontFamily: "Courier",
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(width: 3.0, color: Color(0xFFE0F7FA)),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    minimumSize: Size(240, 60),
                                    elevation: 10,
                                    foregroundColor: Colors.tealAccent,
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
