class UserModel {
  final String name;
  final String email;
  final String? password;
  final int? age;

  UserModel({
    required this.name,
    required this.email,
    this.password,
    this.age,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        if (password != null) 'password': password,
        if (age != null) 'age': age,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        password: map['password'],
        age: map['age'],
      );
}
