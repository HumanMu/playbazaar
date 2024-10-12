
/*
Future<void> _storeUserLocallyRegister(String fullname, String email) async {
  await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, true);
  await SharedPreferencesManager.setString(SharedPreferencesKeys.userNameKey, capitalizeFirstLetter(splitBySpace(fullname)[0]));
  await SharedPreferencesManager.setString(SharedPreferencesKeys.userLastNameKey, splitBySpace(fullname)[1]);
  await SharedPreferencesManager.setString(SharedPreferencesKeys.userEmailKey, email);
}
_storeUserLocallyLogin(String email) async {
  QuerySnapshot snapshot = await FirestoreGroups(userId: FirebaseAuth.instance.currentUser!.uid).getUserByEmail(email.toLowerCase());
  await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, true);
  await SharedPreferencesManager.setString(SharedPreferencesKeys.userEmailKey, email);
  await SharedPreferencesManager.setString(SharedPreferencesKeys.userNameKey, snapshot.docs[0]['fullname']);
  await SharedPreferencesManager.setInt(SharedPreferencesKeys.userCoinsKey, snapshot.docs[0]['coins']);
  await SharedPreferencesManager.setString(SharedPreferencesKeys.userAboutMeKey, snapshot.docs[0]['aboutme']);
  await SharedPreferencesManager.setString(SharedPreferencesKeys.userRoleKey,snapshot.docs[0]['role']);
  await SharedPreferencesManager.setDouble(SharedPreferencesKeys.userPointKey,snapshot.docs[0]['userpoints']);
}

 */