import 'package:flutter/material.dart';
import '../../../models/DTO/search_group_dto.dart';

class SearchFriendTile extends StatelessWidget {
  final SearchGroupDto searchData;

  const SearchFriendTile({
    super.key,
    required this.searchData
  });

  @override
  Widget build(BuildContext context) {
    // Check friendship status
    if (searchData.userId == searchData.foreignId) {
      return const Text(""); // Do not show self in the list
    }

   return Text("Check me");
  }


}