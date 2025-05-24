import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/compra.dart';

class PantallaHistorial extends StatefulWidget {
  final bool refrescar; // Para forzar refresco si quieres (opcional)
  final Key? key;

  const PantallaHistorial({this.refrescar = false, this.key}) : super(key: key);

  @override
  PantallaHistorialState createState() => PantallaHistorialState();
}

// Clase pública para poder usar GlobalKey
class PantallaHistorialState extends State<PantallaHistorial> {
  late Future<List<Compra>> _futureCompras;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  void _cargarHistorial() {
    _futureCompras = DatabaseHelper.instance.obtenerHistorial();
  }

  // Método público para refrescar la lista de historial
  Future<void> refrescarHistorial() async {
    setState(() {
      _cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refrescarHistorial,
      child: FutureBuilder<List<Compra>>(
        future: _futureCompras,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay compras registradas'));
          }

          final compras = snapshot.data!;
          return ListView.builder(
            itemCount: compras.length,
            itemBuilder: (context, index) {
              final compra = compras[index];
              return ListTile(
                title: Text(
                  'Total: \$${compra.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Fecha: ${compra.fecha.toLocal()} \nProductos: ${compra.productos.join(', ')}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
