class Compra {
  final int? id;
  final DateTime fecha;
  final double total;
  final List<String> productos;

  Compra({
    this.id,
    required this.fecha,
    required this.total,
    required this.productos,
  });

  // Para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'total': total,
      'productos': productos.join(','),
    };
  }

  // Para leer desde SQLite
  factory Compra.fromMap(Map<String, dynamic> map) {
    return Compra(
      id: map['id'],
      fecha: DateTime.parse(map['fecha']),
      total: map['total'],
      productos: map['productos'].split(','),
    );
  }
}
