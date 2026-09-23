class Products {
  final int id;
  final String name;
  final double price;
  final int? userId;

  Products({
    required this.id,
    required this.name,
    required this.price,
    this.userId,
  });

  factory Products.fromMap(Map<String, dynamic> map) {
    return Products(
      id: map['id'] as int,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      userId: map['user_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'user_id': userId,
    };
  }
}
