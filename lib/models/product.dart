class Product {
  int? id;
  String name;
  double price;

  Product({this.id, required this.name, required this.price});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'price': price,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Product.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        price = map['price'];
}
