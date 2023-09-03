class ItemCard {
  final int id;
  final String name;
  final int state;
  final String imagePath;

  ItemCard({
    required this.id,
    required this.name,
    required this.state,
    required this.imagePath,
  });

  // Make a factory constructor to create a Card from a map
  factory ItemCard.fromMap(Map<String, dynamic> json) => ItemCard(
        id: json["id"],
        name: json["name"],
        state: json["state"],
        imagePath: json["image_path"],
      );

  // Make a method to convert a Card to a map
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "status": state,
        "imagePath": imagePath,
      };
}
