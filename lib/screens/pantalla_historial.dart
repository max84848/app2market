import 'package:flutter/material.dart';
import '../models/compra.dart';
import '/database/db_helper.dart';

class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({Key? key}) : super(key: key);

  @override
  _PantallaHistorialState createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  List<Compra> compras = [];

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    final data = await DatabaseHelper.instance.obtenerHistorial();
    setState(() {
      compras = data;
    });
  }

  void eliminar(int id) async {
    await DatabaseHelper.instance.eliminarCompra(id);
    cargarHistorial();
  }

  void editar(Compra compra) {
    final controladorTotal = TextEditingController(text: compra.total.toString());
    final controladorProductos = TextEditingController(text: compra.productos.join(', '));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controladorTotal, decoration: const InputDecoration(labelText: 'Total')),
            TextField(controller: controladorProductos, decoration: const InputDecoration(labelText: 'Productos')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final nuevaCompra = Compra(
                id: compra.id,
                fecha: compra.fecha,
                total: double.tryParse(controladorTotal.text) ?? compra.total,
                productos: controladorProductos.text.split(',').map((e) => e.trim()).toList(),
              );
              await DatabaseHelper.instance.actualizarCompra(nuevaCompra);
              Navigator.pop(ctx);
              cargarHistorial();
            },
            child: const Text('Guardar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de compras')),
      body: ListView.builder(
        itemCount: compras.length,
        itemBuilder: (context, index) {
          final c = compras[index];
          return ListTile(
            title: Text('${c.fecha.toLocal().toString().split(" ")[0]} - \$${c.total.toStringAsFixed(2)}'),
            subtitle: Text(c.productos.join(', ')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => editar(c)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => eliminar(c.id!)),
              ],
            ),
          );
        },
      ),
    );
  }
}
