class MiscItem {
  final int id;
  final String name;
  final int closet;
  final int basket;
  final int wash;
  final int total;

  MiscItem({
    required this.id,
    required this.name,
    required this.closet,
    required this.basket,
    required this.wash,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'closet': closet,
      'basket': basket,
      'wash': wash,
      'total': total,
    };
  }

  factory MiscItem.fromMap(Map<String, dynamic> map) {
    return MiscItem(
      id: map['id'],
      name: map['name'],
      closet: map['closet'],
      basket: map['basket'],
      wash: map['wash'],
      total: map['total'],
    );
  }
}
