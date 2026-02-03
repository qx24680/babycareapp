class User {
  final int? id;
  final String email;
  final String passwordHash;
  final String fullName;
  final String? phoneNumber;
  final String createdAt;

  User({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.fullName,
    this.phoneNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      fullName: map['full_name'] as String,
      phoneNumber: map['phone_number'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  // Create user without sensitive data
  User copyWithoutPassword() {
    return User(
      id: id,
      email: email,
      passwordHash: '',
      fullName: fullName,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
    );
  }
}
