class UserModel {
  final String id;
  final String name;
  final String role;
  final String? phoneNumber; // Added phoneNumber field
  final bool isBusy;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.phoneNumber, // Added phoneNumber to constructor
    this.isBusy = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      phoneNumber: json['phoneNumber'], // Updated to read phoneNumber
      isBusy: json['isBusy'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber, // Updated to include phoneNumber
      'isBusy': isBusy,
    };
  }
}
