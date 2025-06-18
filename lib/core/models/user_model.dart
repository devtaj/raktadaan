// core/models/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final String bloodGroup;
  final String phone;
  final String location;
  final DateTime lastDonated;

  UserModel({
    required this.uid,
    required this.name,
    required this.bloodGroup,
    required this.phone,
    required this.location,
    required this.lastDonated,
  });
}
