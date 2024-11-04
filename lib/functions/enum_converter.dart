import '../constants/enums.dart';

UserRole string2UserRole(String s) {
  UserRole role = UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == s,
    orElse: () => UserRole.normal,
  );
  return role;
}

String userRole2String(UserRole ur){
  return ur.toString().split('.').last;
}

AccountCondition string2AccountCondition(String s) {
  AccountCondition condition = AccountCondition.values.firstWhere(
        (e) => e.toString().split('.').last == s,
    orElse: () => AccountCondition.good,
  );
  return condition;
}

String accountConditionToString(AccountCondition condition) {
  return condition.toString().split('.').last;
}

FriendshipStatus string2FriendshipState(String s) {
  FriendshipStatus condition = FriendshipStatus.values.firstWhere(
        (e) => e.toString().split('.').last == s,
    orElse: () => FriendshipStatus.good,
  );
  return condition;
}

String friendShipState2String(FriendshipStatus state) {
  return state.toString().split('.').last;
}

String groupUserRole2String(GroupUserRole state) {
  return state.toString().split('.').last;
}