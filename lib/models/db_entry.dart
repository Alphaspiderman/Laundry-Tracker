import 'package:clothes_tracker/models/state.dart';

class DbEntry {
  final int id;
  final String name;
  final States state;
  final String imagePath;

  DbEntry({
    required this.id,
    required this.name,
    required this.state,
    required this.imagePath,
  });

  // Make a factory constructor to create a Card from a map
  factory DbEntry.fromMap(Map<String, dynamic> json) => DbEntry(
        id: json["id"],
        name: json["name"],
        state: States.values[json["state"]],
        imagePath: json["prepend"].toString() + json["image_path"].toString(),
      );

  // Make a method to convert a Card to a map
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "status": state,
        "imagePath": imagePath,
      };
}
