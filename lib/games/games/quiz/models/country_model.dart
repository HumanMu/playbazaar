
class CountryModel {
  final String name;
  final String capital;
  final List<String> wrongCapitals;
  final String? description;

  const CountryModel({
    required this.name,
    required this.capital,
    required this.wrongCapitals,
    this.description,
  });
}
