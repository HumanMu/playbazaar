

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

List<String> splitByUnderscore(String s) {
  return s.split('_');
}

List<String> splitBySpace(String s) {
  return s.split(' ');
}