class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  // Make a factory constructor to create an Entry from json
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
      );

  // Make a factory constructor to create an Entry from a map
  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
      );

  // Make a method to convert an Entry to a map
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };

  // Make a method to convert an Entry to json
  Map toJson() => {
        "id": id,
        "name": name,
      };
}
