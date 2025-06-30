class UserProfileModel {
  final String email;
  final String? fullname;
  final String? aboutMe;
  final int? userPoint;

  UserProfileModel({
    required this.email,
    this.fullname,
    this.aboutMe,
    this.userPoint,
  });
}
