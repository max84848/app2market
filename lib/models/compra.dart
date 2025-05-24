class Compra {
  int? id;
  DateTime fecha;
  double total;
  List<String> productos;

  Compra({
    this.id,
    required this.fecha,
    required this.total,
    required this.productos,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'total': total,
      'productos': productos.join(','), // guardamos como CSV
    };
  }

  factory Compra.fromMap(Map<String, dynamic> map) {
    return Compra(
      id: map['id'],
      fecha: DateTime.parse(map['fecha']),
      total: map['total'],
      productos: (map['productos'] as String).split(','),
    );
  }
}
