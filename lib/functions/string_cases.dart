

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

String capitalizeFirstName(String input) {
  if (input.isEmpty) return input;
  String name = input.split(' ')[0];
  return name[0].toUpperCase() + name.substring(1);
}

String capitalizeFullname(String name) {
  if (name.isEmpty) return name;

  List<String> fullname = name.split(' ').where((word) => word.isNotEmpty).toList();

  List<String> capitalizedFullname = fullname.map((word) {
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).toList();

  return capitalizedFullname.join(' ');
}

List<String> splitByUnderscore(String s) {
  return s.split('_');
}

List<String> splitBySpace(String s) {
  return s.split(' ');
}