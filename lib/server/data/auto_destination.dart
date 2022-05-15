class AutoDestination {
  final String description;
  final String name;
  final String icon;

  const AutoDestination({
    required this.description,
    required this.name,
    required this.icon,
  });

  factory AutoDestination.fromJson(Map<String, dynamic> json) {
    return AutoDestination(
      description: json['description'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class AutoDestinations {
  final List<AutoDestination> autoDestinations;

  const AutoDestinations({required this.autoDestinations});

  factory AutoDestinations.fromJson(dynamic json) {
    var result = json
        .map<AutoDestination>((json) => AutoDestination.fromJson(json))
        .toList();
    return AutoDestinations(autoDestinations: result);
  }
}
